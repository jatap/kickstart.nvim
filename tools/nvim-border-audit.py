#!/usr/bin/env python3
"""Audit border style of every type-triggered overlay in this Neovim config.

Development helper, not part of the runtime configuration: Neovim never loads
anything from `tools/`. Run it after touching 'winborder', 'pumborder', the
`on_highlights` border links, or any mini.nvim `window`/`border` option.

It drives a real TUI inside a pty, opens each surface, and counts border glyphs
in the raw output. The expected style is read from Neovim itself ('winborder'
for floating windows, 'pumborder' for popup menus), so it stays correct when the
style changes. Each run uses its own temporary directory and kills its `nvim`.

    tools/nvim-border-audit.py              # 9 surfaces, no language server needed
    tools/nvim-border-audit.py --lsp        # + 4 pylsp surfaces (needs pylsp on PATH)
    tools/nvim-border-audit.py --only clue  # filter by probe id or title
    tools/nvim-border-audit.py --list       # probe ids only
    tools/nvim-border-audit.py --config /path/to/init.lua

Exit status: 0 if every probed surface matches the configured style.
"""

import argparse
import fcntl
import os
import pty
import re
import select
import shutil
import struct
import subprocess
import sys
import tempfile
import termios
import time

CORNERS = {
    "rounded": "╭╮╰╯",
    "single": "┌┐└┘",
    "double": "╔╗╚╝",
    "bold": "┏┓┗┛",
}
ALL_CORNERS = "".join(CORNERS.values())
# CSI, OSC, charset-designation and keypad sequences; anything printable is content.
ANSI = re.compile(
    rb"\x1b\[[0-9;?]*[ -/]*[@-~]|\x1b\][^\x07]*\x07|\x1b[()][A-Za-z0-9]|\x1b[=>]|\x1b[#][0-9]"
)
WORDS = "word\nwork\nworker\nworld\nworkflow\n"
PYTHON = "import os\n\n\ndef demo():\n    os.path.join('a', 'b')\n    return os.sep\n"


def option_values(config):
    """Ask Neovim which border style the config actually sets."""
    out = subprocess.run(
        ["nvim", "--headless", "-u", config, "-c",
         'lua io.write(vim.o.winborder .. "\\n" .. vim.o.pumborder)', "-c", "qall"],
        capture_output=True, text=True, check=True,
    ).stdout.split()
    return {"float": out[0], "pum": out[1]}


def run_nvim(config, target, steps, rows=28, cols=90, budget=120):
    """Open `target`, then send each entry of `steps` after sleeping its length.

    A step is either ("sleep", seconds) or ("keys", "<literal text to send>").
    """
    master, slave = pty.openpty()
    fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack("HHHH", rows, cols, 0, 0))
    pid = os.fork()
    if pid == 0:
        os.close(master)
        os.setsid()
        fcntl.ioctl(slave, termios.TIOCSCTTY, 0)
        for fd in (0, 1, 2):
            os.dup2(slave, fd)
        os.close(slave)
        os.chdir(os.path.dirname(target))
        os.execvpe("nvim", ["nvim", "-n", "-u", config, target], dict(os.environ, TERM="xterm-256color"))
    os.close(slave)

    buf = bytearray()

    def drain(until):
        while time.time() < until:
            if not select.select([master], [], [], 0.1)[0]:
                continue
            try:
                chunk = os.read(master, 65536)
            except OSError:
                return False
            if not chunk:
                return False
            buf.extend(chunk)
        return True

    deadline = time.time() + budget
    for kind, payload in steps:
        if kind == "sleep":
            if not drain(min(time.time() + payload, deadline)):
                break
        else:
            os.write(master, payload.encode())
    drain(min(time.time() + 0.8, deadline))
    try:
        os.kill(pid, 9)
        os.waitpid(pid, 0)
    except OSError:
        pass
    os.close(master)
    return ANSI.sub(b"", bytes(buf)).decode("utf-8", "replace")


def classify(screen, expected_style, expected_from):
    """Return (verdict, detail) for one captured screen against the expected style."""
    corners = {c: screen.count(c) for c in ALL_CORNERS}
    seen = {style: sum(corners[c] for c in chars) for style, chars in CORNERS.items()}
    expected = seen.get(expected_style, 0)
    other = sum(v for k, v in seen.items() if k != expected_style)
    boxes = sum(seen.values()) // 4
    if expected_style not in CORNERS:  # solid / shadow / custom: glyphs carry no signal
        return "CHECK", f"style '{expected_style}' has no corner glyphs; eyeball it ({expected_from})"
    if expected and not other:
        return "OK", f"{boxes} box(es) with {expected_style} corners ({expected_from}='{expected_style}')"
    if not expected and not other:
        return "FAIL", f"no border drawn at all ({expected_from}='{expected_style}')"
    return "FAIL", f"expected {expected_style} only, got {seen} ({expected_from})"


def default_config():
    """init.lua next to this tools/ directory, falling back to the XDG config."""
    here = os.path.dirname(os.path.abspath(__file__))
    candidate = os.path.join(os.path.dirname(here), "init.lua")
    return candidate if os.path.exists(candidate) else os.path.expanduser("~/.config/nvim/init.lua")


def surfaces(workdir):
    words = os.path.join(workdir, "words.txt")
    with open(words, "w") as f:
        f.write(WORDS)
    pydir = os.path.join(workdir, "src")
    os.makedirs(pydir, exist_ok=True)
    pyfile = os.path.join(pydir, "t.py")
    with open(pyfile, "w") as f:
        f.write(PYTHON)
    listing = os.path.join(workdir, "listing")
    os.makedirs(listing, exist_ok=True)
    for name in ("alpha.c", "beta.c", "gamma.c"):
        open(os.path.join(listing, name), "w").close()

    return [
        dict(id="pum-keyword", title="native <C-N> completion menu", kind="pum",
             target=words, steps=[("sleep", 4), ("keys", "iwor"), ("sleep", 1), ("keys", "\x0e"), ("sleep", 2)]),
        dict(id="pum-line", title="native <C-X><C-L> line completion menu", kind="pum",
             target=words, steps=[("sleep", 4), ("keys", "iwork"), ("sleep", 1), ("keys", "\x18\x0c"), ("sleep", 2)]),
        dict(id="pum-spell", title="native <C-X><C-S> spelling menu (text filetype)", kind="pum",
             target=words, steps=[("sleep", 4), ("keys", "iwordvd"), ("sleep", 1), ("keys", "\x18\x13"), ("sleep", 2)]),
        dict(id="cmdline", title="command-line <Tab> list (wildoptions=pum)", kind="pum",
             target=words, steps=[("sleep", 4), ("keys", ":e "), ("sleep", 1), ("keys", "\t\t"), ("sleep", 2)]),
        dict(id="clue", title="mini.clue <Leader> menu", kind="float",
             target=words, steps=[("sleep", 4), ("keys", " "), ("sleep", 1), ("keys", "g"), ("sleep", 3)]),
        dict(id="pick", title="mini.pick files (<leader>sf)", kind="float",
             target=words, steps=[("sleep", 4), ("keys", " sf"), ("sleep", 3)]),
        dict(id="ui-select", title="vim.ui.select -> MiniPick", kind="float",
             target=words, steps=[("sleep", 4),
                                  ("keys", ':lua vim.ui.select({"one","two","three"},{prompt="Pick: "},function() end)\r'),
                                  ("sleep", 3)]),
        dict(id="diagnostic", title="diagnostic float (grd / <C-W>d)", kind="float",
             target=words, steps=[("sleep", 4),
                                  ("keys", ':lua vim.diagnostic.set(0,0,{ { bufnr=0, lnum=0, col=0, message="probe message" } })\r'),
                                  ("keys", ":lua vim.diagnostic.open_float()\r"), ("sleep", 3)]),
        dict(id="files", title="mini.files explorer (<leader>e)", kind="float",
             target=words, steps=[("sleep", 4), ("keys", " e"), ("sleep", 3)]),
        dict(id="lsp-completion", title="LSP completion menu (pylsp)", kind="pum", lsp=True,
             target=pyfile, steps=[("sleep", 14), ("keys", "G$"), ("keys", "o"), ("keys", "os."), ("sleep", 8)]),
        dict(id="lsp-info", title="mini.completion documentation window", kind="float", lsp=True,
             target=pyfile, steps=[("sleep", 14), ("keys", "G$"), ("keys", "o"), ("keys", "os.pa"), ("sleep", 10)]),
        dict(id="lsp-hover", title="LSP hover (K)", kind="float", lsp=True,
             target=pyfile, steps=[("sleep", 14), ("keys", "jjww"), ("keys", "K"), ("sleep", 8)]),
        dict(id="lsp-signature", title="LSP signature help (auto on '(')", kind="float", lsp=True,
             target=pyfile, steps=[("sleep", 14), ("keys", "G$"), ("keys", "o"), ("keys", "os.path.join("), ("sleep", 8)]),
    ]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", default=default_config())
    ap.add_argument("--only", help="run ids/titles containing this substring")
    ap.add_argument("--lsp", action="store_true", help="include language-server surfaces (slow)")
    ap.add_argument("--list", action="store_true", help="list probe ids and exit")
    args = ap.parse_args()

    opts = option_values(args.config)
    workdir = tempfile.mkdtemp(prefix="nvim-border-audit-")
    try:
        probes = surfaces(workdir)
        if args.list:
            for p in probes:
                print(f"{p['id']:16s} {p['title']}")
            return 0
        results = []
        for p in probes:
            if p.get("lsp") and not args.lsp:
                continue
            if args.only and args.only not in p["id"] and args.only.lower() not in p["title"].lower():
                continue
            screen = run_nvim(args.config, p["target"], p["steps"])
            style = opts[p["kind"]]
            source = "pumborder" if p["kind"] == "pum" else "winborder"
            verdict, detail = classify(screen, style, source)
            results.append((p["id"], verdict))
            print(f"  {verdict:6s} {p['title']:46s} {detail}")
        bad = [i for i, v in results if v == "FAIL"]
        print(f"\n{len(results) - len(bad)}/{len(results)} surfaces match; "
              f"winborder='{opts['float']}' pumborder='{opts['pum']}'")
        if any(v == "CHECK" for _, v in results):
            print("Note: 'CHECK' = that style has no distinguishing corner glyphs; look at Neovim.")
        return 1 if bad else 0
    finally:
        shutil.rmtree(workdir, ignore_errors=True)


if __name__ == "__main__":
    sys.exit(main())
