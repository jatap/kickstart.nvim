# Neovim configuration
A minimal, dependency-light configuration: everything lives in a single
`init.lua`, there is no plugin manager, and only two packages are installed —
the Modus colorscheme and fzf-lua for fuzzy finding.

## Approach

- **No plugin manager.** Packages are native Vim packages (`pack/*/start`) and
  load automatically from `~/.local/share/nvim/site/pack/theme/start/`.
- **Use built-in features first.** Treesitter highlighting runs through
  Neovim's built-in API; the provider hosts (Node, Python) are auto-detected;
  diagnostics are plain built-in `vim.diagnostic` mappings.
- **Degrade gracefully.** If a package is missing, the config warns instead of
  failing to start.
- Originally started from kickstart.nvim and stripped down to the essentials.

## Requirements

- Neovim ≥ 0.10 (developed on 0.12)
- The `fzf` binary ≥ 0.36 (or `skim`), e.g. on Arch: `sudo pacman -S fzf`
- Optional, auto-detected if present: `rg` (grep), `fd` (file search),
  `bat` (previews)

## Packages

| Package                                                              | What it does                                 | How it is configured                                                                      |
| -------------------------------------------------------------------- | -------------------------------------------- | ----------------------------------------------------------------------------------------- |
| [modus-themes.nvim](https://github.com/miikanissi/modus-themes.nvim) | Colorscheme (Modus Operandi/Vivendi)         | `style = 'auto'` (follows `background`), `dim_inactive`, italic functions                 |
| [fzf-lua](https://github.com/ibhagwan/fzf-lua)                       | Fuzzy finder: files, buffers, grep, LSP, git | `setup { ui_select = {} }` routes `vim.ui.select` (LSP pickers, code actions) through fzf |

## Installation on a new machine

```sh
# 1. The config itself
git clone <your-config-repo> ~/.config/nvim

# 2. The two packages (native packs, no manager)
git clone https://github.com/miikanissi/modus-themes.nvim \
  ~/.local/share/nvim/site/pack/theme/start/modus-themes.nvim
git clone https://github.com/ibhagwan/fzf-lua \
  ~/.local/share/nvim/site/pack/theme/start/fzf-lua

# 3. The fzf binary (Arch example; use your distro's package manager)
sudo pacman -S fzf
```

Start Neovim. Done — no setup step to run.

## Configuration

Leader key is `<Space>`.

### Core options

- Absolute line numbers, sign column, `cursorline`
- Mouse enabled, `unnamedplus` clipboard (set after `UiEnter` for startup speed)
- Case-insensitive search with `smartcase`; live substitution preview
  (`inccommand = 'split'`)
- Persistent undo (`undofile`), break-indent, split to the right/below
- Visible whitespace (`list` + `listchars`), `confirm` before quitting with
  unsaved changes

### Global keymaps

| Key                                              | Action                                         |
| ------------------------------------------------ | ---------------------------------------------- |
| `<Esc>`                                          | Clear search highlight                         |
| `<leader>q`                                      | Open diagnostics in the location/quickfix list |
| `<Esc><Esc>` (terminal)                          | Exit terminal mode                             |
| `<C-Left>` / `<C-Right>` / `<C-Down>` / `<C-Up>` | Move between splits                            |

### fzf-lua keymaps

| Key                | Picker                                                  |
| ------------------ | ------------------------------------------------------- |
| `<leader>sf`       | Files                                                   |
| `<leader>sg`       | Live grep (project)                                     |
| `<leader>sw`       | Grep word under cursor; visual selection in visual mode |
| `<leader>ss`       | Pick a picker from the built-in list                    |
| `<leader>sd`       | Document diagnostics                                    |
| `<leader>sr`       | Resume last picker                                      |
| `<leader>s.`       | Recent files                                            |
| `<leader><leader>` | Buffers                                                 |
| `<leader>sh`       | Help tags                                               |
| `<leader>sk`       | Keymaps                                                 |
| `<leader>sn`       | Files inside the Neovim config                          |
| `<leader>/`        | Lines of the current buffer                             |

## Treesitter

Syntax highlighting uses the parsers installed in
`~/.local/share/nvim/site/parser/` (bash, c, diff, html, lua, luadoc, markdown,
query, vim, vimdoc). A `FileType` autocommand starts the parser when one is
available and silently falls back to the built-in regex highlighter otherwise.

## Updating packages

There is no update command — pull each pack individually:

```sh
git -C ~/.local/share/nvim/site/pack/theme/start/modus-themes.nvim pull
git -C ~/.local/share/nvim/site/pack/theme/start/fzf-lua pull
```

## Layout

```
~/.config/nvim
├── init.lua      # the entire configuration
└── .gitignore
```
