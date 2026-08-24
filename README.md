# Neovim configuration

A minimal, dependency-light configuration: everything lives in a single
`init.lua`, there is no plugin manager, and three native packages are installed —
the Modus colorscheme, fzf-lua for fuzzy finding, and mini.nvim for key clues.

## Approach

- **No plugin manager.** Packages are native Vim packages (`pack/*/start`) and
  load automatically from `~/.local/share/nvim/site/pack/theme/start/` and
  `~/.local/share/nvim/site/pack/ui/start/`.
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
| [mini.nvim](https://github.com/nvim-mini/mini.nvim)                  | `mini.clue` shows next-key clues             | Built-in generators for common prefixes; existing mapping `desc` values are preferred     |

## Installation on a new machine

```sh
# 1. The config itself
git clone <your-config-repo> ~/.config/nvim

# 2. The three packages (native packs, no manager)
git clone https://github.com/miikanissi/modus-themes.nvim \
  ~/.local/share/nvim/site/pack/theme/start/modus-themes.nvim
git clone https://github.com/ibhagwan/fzf-lua \
  ~/.local/share/nvim/site/pack/theme/start/fzf-lua
git clone --branch stable https://github.com/nvim-mini/mini.nvim \
  ~/.local/share/nvim/site/pack/ui/start/mini.nvim

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
- Visible whitespace (`list` + `listchars`, dimmed to a subtle theme-derived
  tone via `NonText`/`SpecialKey` overrides that follow light/dark), `confirm`
  before quitting with unsaved changes
- 2-space indentation with `expandtab` and `smartindent`
- `formatoptions` adds `n` (numbered lists keep their indent);
  `sidescrolloff = 3`; `wildmode = 'longest:full,full'`
- Folding: treesitter `foldexpr` where a parser exists (indent fallback),
  `foldlevelstart = 99` (open by default), custom `»··[Nℓ]·····` fold label
- Bilingual spell checking (`en,es` incl. the custom word list), enabled only
  for prose filetypes (gitcommit, markdown, text)
- `scrolloff = 8` keeps cursor context; `smoothscroll` for wheel scrolling
- `splitkeep = 'screen'` keeps the view stable when splitting; `title` sets
  the terminal title
- `path += **` enables recursive `:find`; `wildignore` skips build/dependency
  noise; `fillchars` hides the `~` filler below EOF
- Diagnostics: rounded float border, signs, `[d`/`]d` navigation

### Native file browser (netrw)

`<leader>e` opens `:Explore` with the banner hidden and tree-style listing
(`netrw_banner = 0`, `netrw_liststyle = 3`).

### Global keymaps

| Key                                              | Action                                         |
| ------------------------------------------------ | ---------------------------------------------- |
| `<Esc>`                                          | Clear search highlight                         |
| `<leader>q`                                      | Open diagnostics in the location/quickfix list |
| `[d` / `]d`                                      | Previous / next diagnostic                     |
| `<leader>e`                                      | Netrw file explorer (`:Explore`)               |
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
The same autocommand enables treesitter-based folding (`foldtext` shows a
`»··[Nℓ]·····` label); buffers without a parser keep the indent-based
fallback.

## Key clues

`mini.clue` opens a delayed popup after a configured prefix such as `<Space>`,
`g`, `z`, `[`, `]`, or `<C-w>`. It uses descriptions from existing mappings,
so the popup stays aligned with this config's `desc` metadata, expands its
width automatically to fit its content, and adds built-in clues for common Vim
key families.

## Updating packages

There is no update command — pull each pack individually:

```sh
git -C ~/.local/share/nvim/site/pack/theme/start/modus-themes.nvim pull
git -C ~/.local/share/nvim/site/pack/theme/start/fzf-lua pull
git -C ~/.local/share/nvim/site/pack/ui/start/mini.nvim pull
```

## Layout

```
~/.config/nvim
├── init.lua      # the entire configuration
└── .gitignore
```
