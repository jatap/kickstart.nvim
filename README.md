# Neovim configuration

A small, dependency-light Neovim configuration built around two native
packages: the Modus colorscheme and mini.nvim. Everything lives in `init.lua`,
there is no plugin manager, and packages load automatically from Vim's native
`pack/*/start` directories.

## Approach

- **No plugin manager.** Install and update each native package with Git.
- **mini.nvim owns overlapping workflows.** Its explorer, picker, diff,
  navigation, editing, and UI modules take precedence over duplicate built-in or
  external configuration.
- **Arrow-first navigation.** Configured movement uses arrows, modified arrows,
  and Page Up/Down where practical. Vim's built-in `h`, `j`, `k`, and `l` keys
  are not disabled, but this configuration does not require them.
- **Use built-ins first.** Treesitter highlighting uses Neovim's built-in API,
  provider hosts are auto-detected, and diagnostics use `vim.diagnostic`.
- **Degrade gracefully.** Missing native packages produce a warning rather than
  preventing startup.

## Requirements

- Neovim ≥ 0.10; `mini.cmdline` needs ≥ 0.11 and works best on ≥ 0.12
- Git
- [ripgrep](https://github.com/BurntSushi/ripgrep) for fast file and live-grep
  pickers
- Optional: `fd` as another file-search backend
- A [Nerd Font](https://www.nerdfonts.com/) for mini.icons glyphs

On Arch Linux:

```sh
sudo pacman -S git neovim ripgrep fd
```

## Installation on a new machine

```sh
# 1. Configuration
git clone <your-config-repo> ~/.config/nvim

# 2. Native packages
mkdir -p ~/.local/share/nvim/site/pack/theme/start
mkdir -p ~/.local/share/nvim/site/pack/ui/start

git clone https://github.com/miikanissi/modus-themes.nvim \
  ~/.local/share/nvim/site/pack/theme/start/modus-themes.nvim

git clone --branch stable https://github.com/nvim-mini/mini.nvim \
  ~/.local/share/nvim/site/pack/ui/start/mini.nvim
```

Start Neovim. There is no install or compile command to run.

## Installed packages and modules

| Package or module   | Role                                                                          |
| ------------------- | ----------------------------------------------------------------------------- |
| `modus-themes.nvim` | Automatic light/dark Modus theme with inactive-window dimming                 |
| `mini.ai`           | Extended `a`/`i` text objects                                                 |
| `mini.animate`      | Cursor, scroll, resize, and window animations                                 |
| `mini.basics`       | Common option defaults, option toggles, terminal setup, and yank highlighting |
| `mini.bracketed`    | Consistent previous/next navigation with `[` and `]`                          |
| `mini.bufremove`    | Delete buffers without destroying the window layout                           |
| `mini.clue`         | Discoverable key-prefix popup                                                 |
| `mini.cmdline`      | Command-line completion, range preview, and externalized UI                   |
| `mini.comment`      | Comment operators and text objects                                            |
| `mini.completion`   | Two-stage LSP and fallback insert completion                                  |
| `mini.cursorword`   | Highlight the word under the cursor                                           |
| `mini.diff`         | Git-index hunks, hunk operators, and hunk navigation                          |
| `mini.files`        | Editable, floating file explorer                                              |
| `mini.git`          | Git metadata, `:Git`, and context-aware Git inspection                        |
| `mini.icons`        | Filetype, file, and LSP-kind icons                                            |
| `mini.indentscope`  | Active indentation scope and scope text objects                               |
| `mini.jump`         | Repeatable `f`/`F`/`t`/`T` motions                                            |
| `mini.jump2d`       | Label-based jump to visible text                                              |
| `mini.operators`    | Evaluate, exchange, multiply, replace, and sort operators                     |
| `mini.pairs`        | Automatic bracket and quote pairs                                             |
| `mini.pick`         | Files, grep, buffers, help, and extensible pickers                            |
| `mini.splitjoin`    | Split or join bracketed argument lists                                        |
| `mini.statusline`   | Statusline with diagnostics, Git, diff, and file information                  |
| `mini.surround`     | Add, delete, find, highlight, and replace surroundings                        |
| `mini.extra`        | Bundled support pickers used by the mini.pick workflows                       |

## Keymap quick reference

Leader is `<Space>`.

### Navigation, files, buffers, and Git

| Key                        | Action                                                      |
| -------------------------- | ----------------------------------------------------------- |
| `<PageDown>` / `<PageUp>`  | Scroll half a page and center the cursor                    |
| `<C-Left>` / `<C-Right>`   | Focus the split to the left/right                           |
| `<C-Down>` / `<C-Up>`      | Focus the split below/above                                 |
| `<leader>e`                | Toggle mini.files at the current file                       |
| `<leader>E`                | Toggle a fresh mini.files explorer at the working directory |
| `<leader>bd`               | Delete the current buffer while preserving the layout       |
| `<leader>bw`               | Wipe out the current buffer while preserving the layout     |
| `<leader>j`                | Start a mini.jump2d jump                                    |
| `<leader>gs`               | Show Git data for the item under the cursor                 |
| `<leader>gh`               | Pick a Git hunk                                             |
| `<leader>q`                | Put current-buffer diagnostics in the location list         |
| `<Esc><Esc>` in a terminal | Return to Normal mode                                       |

### mini.pick

| Key                | Picker                             |
| ------------------ | ---------------------------------- |
| `<leader>sf`       | Files                              |
| `<leader>sg`       | Live grep                          |
| `<leader>sw`       | Literal word under the cursor      |
| `<leader>ss`       | All registered pickers             |
| `<leader>sd`       | Current-buffer diagnostics         |
| `<leader>sr`       | Resume the previous picker         |
| `<leader>s.`       | Recent files                       |
| `<leader><leader>` | Open buffers                       |
| `<leader>sh`       | Help tags                          |
| `<leader>sk`       | Keymaps                            |
| `<leader>sn`       | Files in this Neovim configuration |
| `<leader>/`        | Lines in the current buffer        |

Inside a picker, use `<Up>`/`<Down>` to select, Page Up/Down to scroll,
`<Left>`/`<Right>` to edit the query, `<Tab>` to preview, `<S-Tab>` for mapping
help, `<CR>` to choose, `<C-s>` for a split, `<C-v>` for a vertical split, and
`<C-t>` for a tab.

## Plugin playbook

A per-module reference for everything configured in `init.lua`. Each section
shows the exact **Configuration** the config uses and the essential **How to
use** keys. All modules come from two native packages — `modus-themes.nvim`
and `mini.nvim` (see Installation); if a package is missing, the config warns
and skips only the affected modules instead of failing to start.

For every option, run `:help <Module>` — for example `:help MiniPick`, `:help
MiniFiles`, or `:help mini.nvim`.

### modus-themes.nvim

The Modus colorscheme (light "Operandi" / dark "Vivendi"), kept in sync with
Neovim's `background`.

**Configuration**

```lua
require("modus-themes").setup({
  style = "auto", -- follow vim.o.background (light/dark)
  dim_inactive = true,
  styles = { functions = { italic = true } },
})
vim.cmd.colorscheme("modus")
```

`init.lua` additionally dims the whitespace markers (`tab`, `trail`, `nbsp`)
toward the background to a subtle theme-derived tone, re-applied whenever the
theme reloads or switches light/dark.

**How to use**

- Switch themes with `:set background=light` or `:set background=dark`;
  `style = "auto"` updates the colorscheme automatically.
- Inactive windows are dimmed; function names are italic.

### mini.icons

Filetype, file, and LSP-kind icons used across the UI.

**Configuration**

```lua
require("mini.icons").setup()
require("mini.icons").tweak_lsp_kind() -- nicer glyphs for LSP completion kinds
```

**How to use**

Icons appear in mini.pick, mini.files, mini.statusline, and completion windows.
If glyphs render as boxes, install a [Nerd Font](https://www.nerdfonts.com/)
and use it in the terminal.

### mini.ai

Extended `a`/`i` text objects that compose with normal operators.

**Configuration**

```lua
require("mini.ai").setup({ n_lines = 100 }) -- search up to 100 lines for an object
```

**How to use**

- `daf` deletes around a function call, `ciq` changes inside a quote.
- `an` / `in` select the next object; `al` / `il` the previous one.
- See `:help MiniAI` for the full object list (`af`, `a{`, `aq`, ...).

### mini.animate

Animations for cursor motion, scrolling, split resizing, and window
open/close.

**Configuration**

```lua
require("mini.animate").setup() -- defaults
```

**How to use**

- Runs automatically; no keys to learn (it replaces the native `smoothscroll`
  configuration this setup used before).
- Disable everywhere with `vim.g.minianimate_disable = true`, or per buffer
  with `vim.b.minianimate_disable = true`.

### mini.basics

Saner option defaults, per-option toggles, and yank highlighting.

**Configuration**

```lua
require("mini.basics").setup({
  options = { basic = true, extra_ui = false, win_borders = "auto" },
  mappings = {
    basic = false, -- don't remap keys; keep the native h/j/k/l defaults
    option_toggle_prefix = "<leader>t",
    windows = false, -- split focus is mapped to <C-Arrows> in init.lua
    move_with_alt = false,
  },
  autocommands = { basic = true, relnum_in_visual_mode = false },
})
```

**How to use**

- `<leader>t` is the toggle prefix (Normal mode): `tl` whitespace, `ts` spell,
  `tw` wrap, `tn` line numbers, `td` diagnostics, `tb` background, `tc`
  cursorline, `tC` cursorcolumn, `th` search highlight, `ti` ignorecase, `tr`
  relative line numbers. A message confirms the new value.
- Yanked text is highlighted briefly after every yank (`autocommands.basic`).
- `basic = false` leaves Vim's own `j`/`k` and `<C-h>`/`<C-j>`/`<C-k>`/`<C-l>`
  window mappings untouched — this config simply never relies on them.

### mini.bracketed

Consistent previous/next navigation with `[` and `]`.

**Configuration**

```lua
require("mini.bracketed").setup({ indent = { suffix = "" } }) -- [i/]i belong to mini.indentscope
```

**How to use**

Lowercase goes to the previous/next item; the uppercase variant jumps to the
first/last. For example `]d` is the next diagnostic, `[D` the first.

| Keys        | Target          |
| ----------- | --------------- |
| `[b` / `]b` | Buffer          |
| `[c` / `]c` | Comment         |
| `[x` / `]x` | Conflict marker |
| `[d` / `]d` | Diagnostic      |
| `[f` / `]f` | File            |
| `[l` / `]l` | Location list   |
| `[q` / `]q` | Quickfix list   |
| `[o` / `]o` | Old file        |
| `[t` / `]t` | Treesitter node |
| `[u` / `]u` | Undo history    |
| `[w` / `]w` | Window          |
| `[y` / `]y` | Yanked text     |

The indent target (`[i`/`]i`) is disabled because mini.indentscope owns those
keys. Git-hunk navigation is handled by mini.diff (`[g`/`]g`, `[G`/`]G`).

### mini.bufremove

Delete or wipe buffers without destroying the window layout.

**Configuration**

```lua
require("mini.bufremove").setup() -- defaults
```

The `<leader>bd` / `<leader>bw` mappings are defined in `init.lua`.

**How to use**

- `<leader>bd` deletes the current buffer and keeps the window.
- `<leader>bw` wipes it out (removes it from the buffer list entirely).

### mini.clue

A delayed popup listing the keys available after a prefix — discoverability
for all those mappings.

**Configuration**

```lua
require("mini.clue").setup({
  window = { config = { width = "auto" } },
  triggers = {
    { mode = { "n", "x" }, keys = "<Leader>" },
    { mode = { "n", "x" }, keys = "g" },
    { mode = { "n", "x" }, keys = "z" },
    { mode = "n", keys = "[" },
    { mode = "n", keys = "]" },
    { mode = "i", keys = "<C-x>" },
    { mode = { "n", "x" }, keys = "'" },
    { mode = { "n", "x" }, keys = "`" },
    { mode = { "n", "x" }, keys = '"' },
    { mode = { "i", "c" }, keys = "<C-r>" },
    { mode = "n", keys = "<C-w>" },
  },
  clues = {
    mini.clue.gen_clues.square_brackets(),
    mini.clue.gen_clues.builtin_completion(),
    mini.clue.gen_clues.g(),
    mini.clue.gen_clues.marks(),
    mini.clue.gen_clues.registers(),
    mini.clue.gen_clues.windows(),
    mini.clue.gen_clues.z(),
  },
})
```

**How to use**

Pause after a prefix — `<Space>`, `g`, `z`, `[`, `]`, `<C-w>`, `"`, `'`, `` ` ``,
`<C-r>`, `<C-x>` — to see what comes next. Clue text comes from the mapping
`desc` values, so it matches exactly what this config defines.

### mini.cmdline

Improved command-line: completion as you type, range preview, externalized UI.

**Configuration**

```lua
require("mini.cmdline").setup() -- defaults (needs Neovim ≥ 0.11)
```

**How to use**

- `:` (and `/`, `?`, `:!`) gets a completion popup as you type; all built-in
  command-line completion keys still work.
- Typing a range (e.g. `:2,8delete` or `:/foo/,/bar/s/x/y/`) shows an autopeek
  floating window with the affected lines before you commit.
- On Neovim ≥ 0.12 completion is fuzzy; see `:help MiniCmdline`.

### mini.comment

Comment and uncomment with motions and operators.

**Configuration**

```lua
require("mini.comment").setup() -- defaults
```

**How to use**

- `gcc` toggles the comment on the current line.
- `gc{motion}` toggles on a motion (e.g. `gcip` comments inside a paragraph);
  in Visual mode `gc` toggles the selection.
- `gc` also works as a text object: `dgc` deletes the whole comment block.

### mini.completion

Two-stage (LSP-then-fallback) insert completion.

**Configuration**

```lua
require("mini.completion").setup({
  mappings = { scroll_down = "<PageDown>", scroll_up = "<PageUp>" },
})
```

**How to use**

- Completion opens automatically as you type. Keys behave natively
  (arrows to move through the popup, `<CR>` to accept).
- `<C-Space>` forces the LSP-then-fallback sequence; `<A-Space>` forces
  fallback (dictionary/keyword) completion.
- Page Down / Page Up scroll the completion documentation or signature-help
  window without moving the caret.

### mini.cursorword

Highlights other occurrences of the word under the cursor.

**Configuration**

```lua
require("mini.cursorword").setup() -- defaults
```

**How to use**

All visible matches of the word under the cursor get an underline, updated as
you move. No keys; see `:help MiniCursorword` for the configurable delay and
per-buffer disable options.

### mini.diff

Shows the diff between each file and the Git index, with hunk
stage/reset operators.

**Configuration**

```lua
require("mini.diff").setup({
  mappings = {
    goto_first = "[G", goto_prev = "[g",
    goto_next = "]g",  goto_last = "]G",
  },
})
```

**How to use**

- Changed lines get add/change/delete signs in the gutter.
- `[g` / `]g` move to the previous / next hunk; `[G` / `]G` jump to the first /
  last hunk.
- `gh{motion}` stages hunks under the motion; `gH{motion}` resets them. Both
  work on visual selections (e.g. `ghip` stages the inner paragraph).
- There is no unstage operator — use `:Git restore --staged <path>` or a
  terminal Git client.
- `<leader>gh` opens a picker of hunks (provided by mini.extra).

### mini.files

A floating, editable file explorer.

**Configuration**

```lua
require("mini.files").setup({
  mappings = {
    go_in = "<Right>",        -- enter directory / open file
    go_in_plus = "<S-Right>", -- open file and close the explorer
    go_out = "<Left>",        -- go to the parent directory
    go_out_plus = "<S-Left>", -- go out and trim the child branch
  },
  options = {
    permanent_delete = false, -- deletes go to trash instead
    use_as_default_explorer = true, -- :Explore and :e <dir> use it
  },
  windows = { preview = true, width_focus = 40, width_preview = 40 },
})
```

**How to use**

- `<leader>e` toggles the explorer at the current file; `<leader>E` opens a
  fresh one at the working directory.
- `:Explore` (and opening a directory with `:edit`) now routes to mini.files.
- Navigate with the arrows above; the preview pane updates as you move.
- Directory and file names are editable text: change them and press `=` to
  review and apply the filesystem changes. Deleted entries land in the trash
  (`permanent_delete = false`) rather than being removed for good.
- `g?` shows the complete explorer help.

### mini.git

Git integration: run Git commands and inspect the repository.

**Configuration**

```lua
require("mini.git").setup() -- defaults
```

**How to use**

- `:Git status`, `:Git log`, `:Git diff`, ... run Git and show the output in a
  split (the same pattern as `:Man`).
- `<leader>gs` (`MiniGit.show_at_cursor`) on a commit hash, a diff entry, or a
  visual range opens the context-sensitive Git view. See `:help MiniGit` for
  the full command set.

### mini.indentscope

Visualizes and selects the current indentation scope.

**Configuration**

```lua
require("mini.indentscope").setup() -- defaults
```

**How to use**

- The current indentation chunk is outlined as you move through code.
- `ii` selects the scope body (without its leading border); `ai` includes the
  border.
- `[i` / `]i` move to the previous / next scope edge. mini.bracketed's indent
  target is disabled so these keys stay with mini.indentscope.

### mini.jump

Repeatable `f`/`F`/`t`/`T` motions.

**Configuration**

```lua
require("mini.jump").setup() -- defaults
```

**How to use**

- `f{char}`, `F{char}`, `t{char}`, `T{char}` behave like in Vim, but pressing
  the same key again jumps to the next/previous match instead of doing nothing.
- A stand-in view highlights all matching targets as you type the character.
  See `:help MiniJump`.

### mini.jump2d

Label-based jump to anywhere visible on screen.

**Configuration**

```lua
require("mini.jump2d").setup({
  labels = "abcdefgimnopqrstuvwxyz", -- h/j/k/l omitted: friendly to arrow-first movement
  mappings = { start_jumping = "<leader>j" },
})
```

**How to use**

Press `<leader>j`, then the letter overlaid on the target line to jump there.
The labels deliberately omit `h`, `j`, `k`, `l` so jumps never collide with
movement intent in an arrow-first setup.

### mini.operators

Operators for common text manipulation.

**Configuration**

```lua
require("mini.operators").setup({ replace = { prefix = "gR" } })
```

**How to use**

- `g={motion}` evaluates, `gx{motion}` exchanges two regions, `gm{motion}`
  duplicates, `gR{motion}` replaces from a register, `gs{motion}` sorts lines.
- Replace intentionally uses `gR` (not the default `gr`) so Neovim's built-in
  `gr` mapping (LSP rename) stays available.

### mini.pairs

Automatic bracket and quote pairs.

**Configuration**

```lua
require("mini.pairs").setup() -- defaults
```

**How to use**

- Typing `(` / `[` / `{` / `"` / `'` etc. inserts the matching closer.
- Typing a closing character steps over an existing closer instead of
  inserting a duplicate; `<BS>` removes both partners at once.

### mini.pick

Fast, extensible fuzzy pickers (files, buffers, grep, ...). Replaces fzf-lua.

**Configuration**

```lua
local minipick = require("mini.pick")
minipick.setup({
  mappings = {
    move_down = "<Down>", move_up = "<Up>",
    scroll_down = "<PageDown>", scroll_up = "<PageUp>",
    scroll_left = "<S-Left>", scroll_right = "<S-Right>",
  },
  options = { use_cache = true },
  window = { config = { border = "rounded" } },
})
```

**How to use**

The trigger keys live in the mini.pick quick reference above (`<leader>sf`
files, `<leader>sg` live grep, `<leader><leader>` buffers, `<leader>sr` resume,
...). Inside a picker:

- Arrow up/down select, Page Up/Down scroll, `<Left>`/`<Right>` move the
  caret, `Tab` toggles the preview, `<S-Tab>` shows the keymap help.
- `<CR>` opens; `<C-s>`/`<C-v>`/`<C-t>` open in a split / vertical split /
  new tab. `<C-Space>` refines the query.
- Type a path substring or regex to filter, then `<CR>` to choose.
- `MiniPick.ui_select()` is wired up automatically, so LSP/code-action menus
  and other `vim.ui.select` calls use the same picker.

### mini.splitjoin

Split or join bracketed argument lists.

**Configuration**

```lua
require("mini.splitjoin").setup() -- defaults
```

**How to use**

Put the cursor inside a bracketed region and press `gS` to toggle between one
line and the multiline form, with correct indentation. See `:help
MiniSplitjoin` for hooks such as trailing commas.

### mini.statusline

The statusline.

**Configuration**

```lua
require("mini.statusline").setup({ use_icons = true })
```

**How to use**

Shows filetype (with icon), mode, diagnostics, Git branch, diff hunks, filename,
and line/column, truncated to fit the window width. Inactive windows get a
dimmed variant automatically.

### mini.surround

Add, delete, find, highlight, and replace surroundings (`"`, `'`, `(`, tags,
...).

**Configuration**

```lua
require("mini.surround").setup() -- defaults
```

**How to use**

- `sa{motion}{char}` adds a surround, `sd{char}` deletes one.
- `sr{old}{new}` replaces one surround with another (no motion needed).
- `sf` / `sF` find a surround on the same / previous lines; `sh` temporarily
  highlights them.

### mini.extra

Bundled extra modules and pickers that back the mini.pick workflows.

**Configuration**

```lua
require("mini.extra").setup() -- defaults
```

**How to use**

Provides the pickers behind these mappings: `<leader>sd` (buffer diagnostics),
`<leader>s.` (recent files), `<leader>sk` (keymaps), `<leader>gh` (Git hunks),
`<leader>/` (current-buffer lines). See `:help MiniExtra`.

## Core behavior

- Absolute line numbers, sign column, cursor line, mouse, and delayed system
  clipboard integration
- Smart-case search, live substitution preview, persistent undo, and confirmation
  before abandoning unsaved changes
- Two-space indentation, recursive `:find`, visible whitespace, and bilingual
  English/Spanish spell checking in prose buffers
- Treesitter highlighting and folding when an installed parser is available,
  with regex highlighting and indent folding as fallbacks
- Rounded diagnostic floats and automatically opened quickfix windows after
  `:grep` or `:make`

## Removed duplicate workflows

The following configuration was deleted because a mini.nvim module now owns the
same workflow:

- **fzf-lua configuration, package instructions, and `fzf` requirement:**
  mini.pick plus mini.extra now provides files, grep, buffers, diagnostics,
  history, help, keymaps, Git hunks, and `vim.ui.select`.
- **netrw explorer settings and `<leader>e` mapping:** mini.files is the default
  directory editor and explorer.
- **Custom `TextYankPost` autocommand:** mini.basics supplies yank highlighting.
- **Native `smoothscroll` configuration:** mini.animate owns animated scrolling.
- **mini.bracketed indent navigation:** disabled because mini.indentscope owns
  `[i` and `]i`.

Keeping these removals explicit prevents old workflows from silently returning
and competing with the mini.nvim configuration.

## Updating packages

```sh
git -C ~/.local/share/nvim/site/pack/theme/start/modus-themes.nvim pull
git -C ~/.local/share/nvim/site/pack/ui/start/mini.nvim pull
```

## Layout

```text
~/.config/nvim
├── init.lua
├── README.md
├── .gitignore
└── .luarc.json
```
