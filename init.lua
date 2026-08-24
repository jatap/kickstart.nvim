-- Minimal Neovim configuration: core settings, keymaps, and the packages of
-- choice (Modus theme, fzf-lua). No plugin manager; packages are native packs
-- in ~/.local/share/nvim/site/pack/theme/start/ and load automatically:
--
--   git clone https://github.com/miikanissi/modus-themes.nvim \
--     ~/.local/share/nvim/site/pack/theme/start/modus-themes.nvim
--   git clone https://github.com/ibhagwan/fzf-lua \
--     ~/.local/share/nvim/site/pack/theme/start/fzf-lua

-- Resolve provider hosts when available so discovery is deterministic but optional.
local node_host_prog = vim.fn.exepath 'neovim-node-host'
if node_host_prog ~= '' then
  vim.g.node_host_prog = node_host_prog
end

local python3_host_prog = vim.fn.exepath 'pynvim-python'
if python3_host_prog ~= '' then
  vim.g.python3_host_prog = python3_host_prog
end

-- Set <space> as the leader key
-- See `:help mapleader`
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Options ]]
-- See `:help option-list`
vim.o.number = true -- line numbers
vim.o.mouse = 'a' -- mouse in all modes
vim.o.showmode = false -- mode is already shown in the statusline
vim.o.breakindent = true
vim.o.undofile = true -- persistent undo history
vim.o.ignorecase = true -- case-insensitive search, unless a capital is typed
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300 -- mapped sequence wait time
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true -- show whitespace
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split' -- preview substitutions live
vim.o.cursorline = true
vim.o.confirm = true -- :q with unsaved changes asks instead of failing

-- Indentation: 2-space, expand tabs (matches this config's modeline style)
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.smartindent = true

-- Keep cursor context when scrolling / jumping
vim.o.scrolloff = 8

-- Smooth wheel scrolling (mouse is enabled)
vim.o.smoothscroll = true

-- Keep the view stable when splitting
vim.o.splitkeep = 'screen'

-- Show the file name in the terminal title
vim.o.title = true

-- Native `:find` searches recursively, ignoring common noise dirs
vim.o.path = vim.o.path .. '**'
vim.opt.wildignore:append { '*/node_modules/*', '*/target/*', '*/.git/*' }

-- Hide '~' filler below the end of the buffer
vim.opt.fillchars = { eob = ' ' }

-- Sync clipboard between OS and Neovim.
-- Scheduled after `UiEnter` because it can increase startup time.
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- [[ Keymaps ]]
-- See `:help vim.keymap.set()`

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>') -- clear search highlight
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Split navigation with CTRL+<hjkl>
vim.keymap.set('n', '<C-Left>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-Right>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-Down>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-Up>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Diagnostics ]]
-- Rounded float border and previous/next navigation (feeds from LSP, :make, ...)
vim.diagnostic.config { float = { border = 'rounded' }, signs = true }
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })

-- [[ Native file browser (netrw) ]]
vim.g.netrw_banner = 0 -- no banner header
vim.g.netrw_liststyle = 3 -- tree view
vim.keymap.set('n', '<leader>e', vim.cmd.Explore, { desc = 'File browser [E]xplore' })

-- [[ Autocommands ]]
-- See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    if vim.hl.hl_op then
      vim.hl.hl_op()
    else
      vim.hl.on_yank()
    end
  end,
})

-- Open the quickfix window automatically after :grep / :make
vim.api.nvim_create_autocmd('QuickFixCmdPost', {
  pattern = 'grep*',
  command = 'cwindow',
})

-- Treesitter syntax highlighting using the parsers already installed in
-- ~/.local/share/nvim/site/parser (builtin, no plugin needed).
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'bash', 'sh', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'query', 'vim', 'vimdoc', 'help' },
  callback = function(args)
    local language = vim.treesitter.language.get_lang(args.match)
    if not language or not vim.treesitter.language.add(language) then
      return
    end
    vim.treesitter.start(args.buf, language)
  end,
})

-- [[ Colorscheme: Modus ]]
-- The only package; loaded from the native pack directory (see header).
local ok, modus = pcall(require, 'modus-themes')
if ok then
  ---@diagnostic disable-next-line: missing-fields
  modus.setup {
    style = 'auto',
    dim_inactive = true,
    styles = {
      functions = { italic = true }, -- Enable italics for functions
    },
  }

  vim.cmd.colorscheme 'modus'
else
  vim.notify(
    'modus-themes.nvim not found. Install it with:\n  git clone https://github.com/miikanissi/modus-themes.nvim ~/.local/share/nvim/site/pack/theme/start/modus-themes.nvim',
    vim.log.levels.WARN
  )
end

-- [[ Fuzzy finder: fzf-lua ]]
-- Uses the fzf binary already installed on the system (no extra deps).
local ok_fzf, fzf = pcall(require, 'fzf-lua')
if ok_fzf then
  -- Let Neovim's vim.ui.select (LSP pickers, etc.) use fzf-lua too.
  fzf.setup { ui_select = {} }

  vim.keymap.set('n', '<leader>sf', fzf.files, { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>sg', fzf.live_grep, { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader>sw', fzf.grep_cword, { desc = '[S]earch current [W]ord' })
  vim.keymap.set('v', '<leader>sw', fzf.grep_visual, { desc = '[S]earch [W]ord (visual)' })
  vim.keymap.set('n', '<leader>ss', fzf.builtin, { desc = '[S]earch [S]elect picker' })
  vim.keymap.set('n', '<leader>sd', fzf.diagnostics_document, { desc = '[S]earch [D]iagnostics' })
  vim.keymap.set('n', '<leader>sr', fzf.resume, { desc = '[S]earch [R]esume' })
  vim.keymap.set('n', '<leader>s.', fzf.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
  vim.keymap.set('n', '<leader><leader>', fzf.buffers, { desc = '[ ] Find existing buffers' })
  vim.keymap.set('n', '<leader>sh', fzf.helptags, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sk', fzf.keymaps, { desc = '[S]earch [K]eymaps' })
  vim.keymap.set('n', '<leader>sn', function()
    fzf.files { cwd = vim.fn.stdpath 'config' }
  end, { desc = '[S]earch [N]eovim files' })
  vim.keymap.set('n', '<leader>/', fzf.blines, { desc = '[/] Fuzzily search in current buffer' })
end

-- vim: ts=2 sts=2 sw=2 et
