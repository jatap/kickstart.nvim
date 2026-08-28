-- Minimal Neovim configuration: core settings plus Modus and mini.nvim.
-- There is no plugin manager; native packages in
-- ~/.local/share/nvim/site/pack/*/start/ load automatically:
--
--   git clone https://github.com/miikanissi/modus-themes.nvim \
--     ~/.local/share/nvim/site/pack/theme/start/modus-themes.nvim
--   git clone --branch stable https://github.com/nvim-mini/mini.nvim \
--     ~/.local/share/nvim/site/pack/ui/start/mini.nvim
--   git clone https://github.com/nvim-mini/mini.statuscolumn \
--     ~/.local/share/nvim/site/pack/ui/start/mini.statuscolumn

-- Resolve provider hosts when available so discovery is deterministic but optional.
local node_host_prog = vim.fn.exepath("neovim-node-host")
if node_host_prog ~= "" then
	vim.g.node_host_prog = node_host_prog
end

local python3_host_prog = vim.fn.exepath("pynvim-python")
if python3_host_prog ~= "" then
	vim.g.python3_host_prog = python3_host_prog
end

-- Set <space> as the leader key
-- See `:help mapleader`
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- [[ Borders ]]
-- One border style for every overlay, set through Neovim's own options:
--   'winborder' - default for floating windows that do not pick a border of
--                 their own (mini.nvim modules, LSP hover and signature help,
--                 vim.ui.select menus such as code actions).
--   'pumborder' - the completion and command-line candidate menus, which are
--                 drawn by the popup menu and are not floating windows, so
--                 'winborder' does not reach them.
-- mini.basics' options.win_borders = 'auto' reads 'winborder' during setup to
-- pick matching fillchars for split windows, so this has to come first.
-- "single" = square corners (┌ ┐ └ ┘). Other values: "rounded", "double",
-- "bold", "solid", "shadow", "none", or 8 custom characters.
-- Ordinary (non-floating) windows have no border slot at all: their frame is
-- the 'fillchars' separator line, colored by 'WinSeparator' (matched to
-- FloatBorder in the theme hook below), and dim_inactive marks the active one.
vim.o.winborder = "single"
vim.o.pumborder = "single"

-- mini.basics owns common defaults and autocommands. Its j/k, Ctrl-hjkl, and
-- Alt-hjkl presets stay disabled so this config can favor arrow and page keys.
local ok_minibasics, minibasics = pcall(require, "mini.basics")
if ok_minibasics then
	minibasics.setup({
		options = { basic = true, extra_ui = false, win_borders = "auto" },
		mappings = {
			basic = false,
			option_toggle_prefix = "<leader>t",
			windows = false,
			move_with_alt = false,
		},
		autocommands = { basic = true, relnum_in_visual_mode = false },
	})
end

-- [[ Options ]]
-- See `:help option-list`
vim.o.number = true -- line numbers
vim.o.mouse = "a" -- mouse in all modes
vim.o.showmode = false -- mode is already shown in the statusline
vim.o.breakindent = true
vim.o.undofile = true -- persistent undo history
vim.o.ignorecase = true -- case-insensitive search, unless a capital is typed
vim.o.smartcase = true
vim.o.signcolumn = "yes"
vim.o.updatetime = 250
vim.o.timeoutlen = 300 -- mapped sequence wait time
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true -- show whitespace
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.o.inccommand = "split" -- preview substitutions live
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

-- Keep the view stable when splitting
vim.o.splitkeep = "screen"

-- Show the file name in the terminal title
vim.o.title = true

-- Native `:find` searches recursively, ignoring common noise dirs
vim.o.path = vim.o.path .. "**"
vim.opt.wildignore:append({ "*/node_modules/*", "*/target/*", "*/.git/*" })

-- Hide '~' filler below the end of the buffer
vim.opt.fillchars:append({ eob = " " })

-- Formatting: numbered lists re-indent on <CR> (also used by gq)
vim.opt.formatoptions:append("n")
-- Keep 3 columns of context when scrolling horizontally
vim.o.sidescrolloff = 3
-- Shell-like completion to the longest unambiguous match
vim.o.wildmode = "longest:full,full"

-- Folding: everything unfolded by default; fold with zc/zo/zM/zR
vim.o.foldmethod = "indent" -- fallback where no treesitter parser exists
vim.o.foldlevelstart = 99
vim.o.foldminlines = 1
-- Fold label: »··[Nℓ]·····: first line (adapted from the old vimscript setup)
-- 'foldtext' needs a v:lua reference, hence the global function.
_G.nvim_foldtext = function()
	local lines = vim.v.foldend - vim.v.foldstart + 1
	local first = vim.trim(vim.fn.getline(vim.v.foldstart))
	local dashes = vim.fn.substitute(vim.v.folddashes, "-", "·", "g")
	return "»··[" .. lines .. "ℓ]" .. dashes .. ": " .. first
end
vim.o.foldtext = "v:lua.nvim_foldtext()"

-- Sync clipboard between OS and Neovim.
-- Scheduled after `UiEnter` because it can increase startup time.
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

-- [[ Keymaps ]]
-- See `:help vim.keymap.set()`

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>") -- clear search highlight
vim.keymap.set("n", "<leader>w", "<cmd>write<CR>", { desc = "[W]rite current file" })
vim.keymap.set("n", "<leader>q", "<cmd>qa<CR>", { desc = "[Q]uit Neovim" })
vim.keymap.set("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "[D]iagnostics to location list" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Arrow-first movement and split navigation
vim.keymap.set({ "n", "x" }, "<PageDown>", "<C-d>zz", { desc = "Scroll half-page down and center" })
vim.keymap.set({ "n", "x" }, "<PageUp>", "<C-u>zz", { desc = "Scroll half-page up and center" })
vim.keymap.set("n", "<C-Left>", "<C-w><Left>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-Right>", "<C-w><Right>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-Down>", "<C-w><Down>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-Up>", "<C-w><Up>", { desc = "Move focus to the upper window" })

-- Window cycling. `<C-W>w` visits every window in the tab, including the
-- quickfix/location list and floating windows, so it reaches buffers that the
-- directional maps above cannot. Normal mode only: insert-mode `<C-X>`
-- completion and `:terminal` input are untouched. `<C-X>` is also Vim's
-- decrement-number operator, so a lone `<C-X>` now waits `timeoutlen` (300 ms
-- in this config) for a possible second key.
vim.keymap.set("n", "<C-X>o", "<C-W>w", { desc = "Next window (incl. quickfix)" })
vim.keymap.set("n", "<C-X>O", "<C-W>W", { desc = "Previous window (incl. quickfix)" })

-- [[ Diagnostics ]]
-- Borders come from 'winborder' (see above); navigation feeds from LSP, :make, ...
vim.diagnostic.config({ signs = true })

-- [[ Autocommands ]]
-- See `:help lua-guide-autocommands`

-- Open the quickfix window automatically after :grep / :make
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
	pattern = { "grep*", "make" },
	command = "cwindow",
})

-- [[ Spell checking ]]
-- Bilingual (en + es); on only for prose filetypes. Dictionary files
-- (incl. the custom word list) live in ~/.local/share/nvim/spell.
vim.o.spelllang = "en,es"
vim.api.nvim_create_autocmd("FileType", {
	-- Explicit on/off per filetype: prevents spell sticking after switching
	-- from a prose buffer to a code buffer in the same window.
	pattern = "*",
	callback = function(args)
		vim.wo.spell = vim.tbl_contains({ "gitcommit", "markdown", "text" }, args.match)
	end,
})

-- [[ Treesitter ]]
-- Syntax highlighting using the parsers already installed in
-- ~/.local/share/nvim/site/parser (builtin, no plugin needed).
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "bash", "sh", "c", "diff", "html", "lua", "luadoc", "markdown", "query", "vim", "vimdoc", "help" },
	callback = function(args)
		local language = vim.treesitter.language.get_lang(args.match)
		if not language or not vim.treesitter.language.add(language) then
			return
		end
		vim.treesitter.start(args.buf, language)

		-- Treesitter folding (window-local; other buffers keep the indent fallback)
		vim.wo.foldmethod = "expr"
		vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
	end,
})

-- [[ LSP ]]
-- Native LSP client (vim.lsp.enable, Neovim 0.11+) with server configs from
-- nvim-lspconfig, installed as a third native package:
--
--   git clone https://github.com/neovim/nvim-lspconfig \
--     ~/.local/share/nvim/site/pack/lsp/start/nvim-lspconfig
--
-- The list mirrors the eglot setup in Emacs (minus Java). When a buffer's
-- filetype matches, its server attaches automatically; nothing is installed
-- behind the scenes, so every server must already be on PATH. Builtin
-- keymaps on attach: gra code action, gri implementation, grn rename,
-- grr references, grt type definition, grx codelens, gO document symbols,
-- K hover, <C-S> signature help, CTRL-] definition, gq format, [d / ]d and
-- <C-W>d diagnostics. Status: :checkhealth vim.lsp (or :LspInfo).
if vim.api.nvim_get_runtime_file("lsp/gopls.lua", false)[1] then
	vim.lsp.enable({
		"bashls", -- bash and sh
		"clangd", -- C and C++
		"cssls", -- CSS, SCSS, and Less
		"dockerls", -- Dockerfile
		"gopls", -- Go
		"html", -- HTML
		"intelephense", -- PHP
		"jsonls", -- JSON
		"lua_ls", -- Lua
		"marksman", -- Markdown
		"pylsp", -- Python
		"ruby_lsp", -- Ruby
		"rust_analyzer", -- Rust
		"terraformls", -- Terraform
		"ts_ls", -- JavaScript and TypeScript
		"yamlls", -- YAML
	})
else
	vim.notify(
		"nvim-lspconfig not found. Install it with:\n  git clone https://github.com/neovim/nvim-lspconfig ~/.local/share/nvim/site/pack/lsp/start/nvim-lspconfig",
		vim.log.levels.WARN
	)
end

-- [[ Colorscheme: Modus ]]
-- Loaded from the native pack directory (see header).
local ok, modus = pcall(require, "modus-themes")
if ok then
	---@diagnostic disable-next-line: missing-fields
	modus.setup({
		style = "auto",
		dim_inactive = true,
		styles = {
			functions = { italic = true }, -- Enable italics for functions
		},
		-- Keep every mini.nvim highlight on the Modus palette: this hook runs
		-- after the theme is assembled, with the exact colors of the active
		-- style (light/dark), and re-runs on every colorscheme load — so the
		-- overrides below always use the current theme colors.
		on_highlights = function(h, c)
			-- Neovim renders every floating window's backdrop through 'NormalFloat'
			-- (a float's 'Normal' defaults to it), and several mini modules link
			-- their popup groups to it — e.g. MiniClueDescSingle. Pointing it at the
			-- main background makes ALL popups blend with the editor (pure black on
			-- the dark theme, white on the light one) instead of Modus' grey
			-- bg_active. The module-specific overrides below keep each surface
			-- black even if a module stops linking to NormalFloat.
			h.NormalFloat = { fg = c.fg_main, bg = c.bg_main }
			h.MiniPickNormal = { fg = c.fg_main, bg = c.bg_main }
			h.MiniFilesNormal = { fg = c.fg_main, bg = c.bg_main }
			h.MiniCmdlinePeekNormal = { fg = c.fg_main, bg = c.bg_main }
			h.MiniClueDescSingle = { fg = c.fg_main, bg = c.bg_main } -- clue rows & body

			-- Completion / command-line popup menu: same theme background, with a
			-- fully inverted, high-contrast selected item.
			h.Pmenu = { fg = c.fg_main, bg = c.bg_main }
			h.PmenuSel = { fg = c.bg_main, bg = c.fg_main }
			-- Popup-menu border ('pumborder'); same color as float borders.
			h.PmenuBorder = { link = "FloatBorder" }
			-- Window separators: the only frame an ordinary window can have, so
			-- they get the border color too ('winborder' does not apply to them).
			h.WinSeparator = { link = "FloatBorder" }

			-- mini.cursorword: replace the dim gray chip (bg = fg_dim) with a
			-- clearly visible, theme-derived fg+bg. Text on the subtle
			-- backgrounds keeps strong contrast on both Modus styles.
			h.MiniCursorword = { fg = c.fg_main, bg = c.bg_cyan_subtle }
			h.MiniCursorwordCurrent = { fg = c.fg_main, bg = c.bg_blue_subtle }

			-- mini.pick: fuzzy-matched characters reuse the search highlight
			-- (hint-colored by default is too subtle). Modus itself links picker
			-- matches to CurSearch, e.g. SnacksPickerMatch.
			h.MiniPickMatchRanges = { link = "CurSearch" }

			-- mini.statuscolumn: the '▏' between the column and the buffer text is a
			-- window frame, so it gets the border color (the module links it to
			-- LineNr by default). MiniStatuscolumnSepCursor is left alone on purpose:
			-- the module links it to CursorLineNr, which keeps the current line's
			-- separator visible. MiniStatuscolumnDim is also left alone: the module
			-- computes it from the active Modus LineNr on every colorscheme reload.
			h.MiniStatuscolumnSep = { link = "FloatBorder" }
		end,
	})

	vim.cmd.colorscheme("modus")

	-- Dim listchars (tab/trail → NonText, nbsp → SpecialKey) to a subtle,
	-- theme-derived tone instead of the theme's mid-gray.
	local function rgb_color(n)
		return { math.floor(n / 65536), math.floor(n / 256) % 256, n % 256 }
	end
	local function blend(fore, back, t)
		local f, b = rgb_color(fore), rgb_color(back)
		local ch = function(i)
			return math.floor(f[i] * (1 - t) + b[i] * t + 0.5)
		end
		return ch(1) * 65536 + ch(2) * 256 + ch(3)
	end
	local function dim_listchars()
		local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
		local nontext = vim.api.nvim_get_hl(0, { name = "NonText" })
		local special = vim.api.nvim_get_hl(0, { name = "SpecialKey" })
		if not (normal.bg and nontext.fg and special.fg) then
			return
		end
		local t = 0.6 -- 0 = theme color, 1 = invisible (matches the background)
		vim.api.nvim_set_hl(0, "NonText", { fg = blend(nontext.fg, normal.bg, t) })
		vim.api.nvim_set_hl(0, "SpecialKey", { fg = blend(special.fg, normal.bg, t) })
	end
	dim_listchars()
	-- Re-apply when the theme reloads or switches light/dark (style = 'auto').
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = vim.api.nvim_create_augroup("modus-listchars", { clear = true }),
		callback = dim_listchars,
	})
else
	vim.notify(
		"modus-themes.nvim not found. Install it with:\n  git clone https://github.com/miikanissi/modus-themes.nvim ~/.local/share/nvim/site/pack/theme/start/modus-themes.nvim",
		vim.log.levels.WARN
	)
end

-- [[ mini.nvim workflows ]]
-- All of these modules come from the single mini.nvim native package (the one
-- exception is mini.statuscolumn, see its own section below). If mini.nvim is
-- absent, warn once rather than failing startup halfway through configuration.
local ok_mini, miniicons = pcall(require, "mini.icons")
if ok_mini then
	miniicons.setup()
	miniicons.tweak_lsp_kind()

	require("mini.ai").setup({ n_lines = 100 })
	require("mini.comment").setup()
	require("mini.completion").setup({
		mappings = { scroll_down = "<PageDown>", scroll_up = "<PageUp>" },
	})
	require("mini.operators").setup({ replace = { prefix = "gR" } })
	require("mini.pairs").setup()
	require("mini.splitjoin").setup()
	require("mini.surround").setup()

	-- mini.indentscope owns [i/]i, so mini.bracketed's indent target is disabled.
	require("mini.bracketed").setup({ indent = { suffix = "" } })
	require("mini.bufremove").setup()
	require("mini.cmdline").setup()
	require("mini.diff").setup({
		mappings = { goto_first = "[G", goto_prev = "[g", goto_next = "]g", goto_last = "]G" },
	})
	require("mini.files").setup({
		mappings = {
			go_in = "<Right>",
			go_in_plus = "<S-Right>",
			go_out = "<Left>",
			go_out_plus = "<S-Left>",
		},
		options = { permanent_delete = false, use_as_default_explorer = true },
		windows = { preview = true, width_focus = 40, width_preview = 40 },
	})

	-- <CR> opens the entry under the cursor and closes the explorer after a
	-- file is opened, matching <S-Right>. Set buffer-locally (per explorer
	-- buffer) so the arrow mappings keep working unchanged everywhere else.
	vim.api.nvim_create_autocmd("User", {
		group = vim.api.nvim_create_augroup("mini-files-cr", { clear = true }),
		pattern = "MiniFilesBufferCreate",
		callback = function(args)
			vim.keymap.set("n", "<CR>", function()
				MiniFiles.go_in({ close_on_file = true })
			end, {
				buffer = args.data.buf_id,
				desc = "Open file or directory and close explorer",
			})
		end,
	})
	require("mini.git").setup()
	require("mini.jump").setup()
	require("mini.jump2d").setup({
		labels = "abcdefgimnopqrstuvwxyz",
		mappings = { start_jumping = "<leader>j" },
	})

	local minipick = require("mini.pick")
	minipick.setup({
		mappings = {
			move_down = "<Down>",
			move_up = "<Up>",
			scroll_down = "<PageDown>",
			scroll_up = "<PageUp>",
			scroll_left = "<S-Left>",
			scroll_right = "<S-Right>",
		},
		options = { use_cache = true },
		-- No 'window.config.border': mini.pick follows 'winborder' like every
		-- other overlay, so all candidate lists keep the same border.
	})

	-- mini.extra is bundled with mini.nvim and supplies feature-parity pickers.
	local miniextra = require("mini.extra")
	miniextra.setup()

	require("mini.animate").setup()
	require("mini.cursorword").setup()
	require("mini.indentscope").setup()
	require("mini.statusline").setup({ use_icons = true })

	-- Explorer and buffer lifecycle
	vim.keymap.set("n", "<leader>e", function()
		if not MiniFiles.close() then
			MiniFiles.open(vim.api.nvim_buf_get_name(0))
		end
	end, { desc = "Toggle file [E]xplorer at current file" })
	vim.keymap.set("n", "<leader>E", function()
		if not MiniFiles.close() then
			MiniFiles.open(nil, false)
		end
	end, { desc = "Toggle file explorer at working directory" })
	vim.keymap.set("n", "<leader>bd", function()
		MiniBufremove.delete(0, false)
	end, { desc = "[B]uffer [D]elete without closing layout" })
	vim.keymap.set("n", "<leader>bw", function()
		MiniBufremove.wipeout(0, false)
	end, { desc = "[B]uffer [W]ipeout without closing layout" })

	-- Search and selection (mini.pick replaces fzf-lua)
	vim.keymap.set("n", "<leader>sf", MiniPick.builtin.files, { desc = "[S]earch [F]iles" })
	vim.keymap.set("n", "<leader>sg", MiniPick.builtin.grep_live, { desc = "[S]earch by live [G]rep" })
	vim.keymap.set("n", "<leader>sw", function()
		MiniPick.builtin.grep({ pattern = vim.fn.expand("<cword>"), method = "plain" })
	end, { desc = "[S]earch current [W]ord" })
	vim.keymap.set("n", "<leader>ss", function()
		local names = vim.tbl_keys(MiniPick.registry)
		table.sort(names)
		local name = MiniPick.start({ source = { items = names, name = "Pickers", choose = function() end } })
		if name then
			MiniPick.registry[name]()
		end
	end, { desc = "[S]earch [S]elect picker" })
	vim.keymap.set("n", "<leader>sd", function()
		MiniExtra.pickers.diagnostic({ scope = "current" })
	end, { desc = "[S]earch [D]iagnostics in buffer" })
	vim.keymap.set("n", "<leader>sr", MiniPick.builtin.resume, { desc = "[S]earch [R]esume" })
	vim.keymap.set("n", "<leader>s.", MiniExtra.pickers.oldfiles, { desc = "[S]earch recent files" })
	vim.keymap.set("n", "<leader><leader>", MiniPick.builtin.buffers, { desc = "Find existing buffers" })
	vim.keymap.set("n", "<leader>sh", MiniPick.builtin.help, { desc = "[S]earch [H]elp" })
	vim.keymap.set("n", "<leader>sk", MiniExtra.pickers.keymaps, { desc = "[S]earch [K]eymaps" })
	vim.keymap.set("n", "<leader>sn", function()
		MiniPick.builtin.files(nil, { source = { cwd = vim.fn.stdpath("config") } })
	end, { desc = "[S]earch [N]eovim files" })
	vim.keymap.set("n", "<leader>/", function()
		MiniExtra.pickers.buf_lines({ scope = "current" })
	end, { desc = "Search lines in current buffer" })

	-- Git inspection; editing hunks uses mini.diff's gh/gH operators.
	vim.keymap.set("n", "<leader>gs", MiniGit.show_at_cursor, { desc = "[G]it [S]how at cursor" })
	vim.keymap.set("n", "<leader>gh", MiniExtra.pickers.git_hunks, { desc = "[G]it [H]unks" })
else
	vim.notify(
		"mini.nvim not found. Install it with:\n  git clone --branch stable https://github.com/nvim-mini/mini.nvim ~/.local/share/nvim/site/pack/ui/start/mini.nvim",
		vim.log.levels.WARN
	)
end

-- [[ Statuscolumn: mini.statuscolumn ]]
-- Fold, line number, sign and separator column, drawn as one 'statuscolumn'.
-- The module is NOT part of mini.nvim v0.18.0 (the newest stable release), so it
-- is installed as its own native package from the standalone repository:
--
--   git clone https://github.com/nvim-mini/mini.statuscolumn \
--     ~/.local/share/nvim/site/pack/ui/start/mini.statuscolumn
--
-- Once the stable mini.nvim checkout contains `lua/mini/statuscolumn.lua`,
-- delete the standalone clone: two copies mean Neovim loads whichever comes
-- first in 'runtimepath' and never sees the other.
local ok_statuscolumn, ministatuscolumn = pcall(require, "mini.statuscolumn")
if ok_statuscolumn then
	local stc_copies = vim.api.nvim_get_runtime_file("lua/mini/statuscolumn.lua", true)
	if #stc_copies > 1 then
		vim.notify(
			"Duplicate mini.statuscolumn (also shipped by mini.nvim). Remove the standalone clone:\n  rm -rf ~/.local/share/nvim/site/pack/ui/start/mini.statuscolumn",
			vim.log.levels.WARN
		)
	end

	-- Defaults, and why they fit this configuration:
	--   content       per line `%=%l%C%s▏`, i.e. line number, fold, signs, separator.
	--                 'foldcolumn' is 0, so the fold slot stays empty and only shows
	--                 up if folding gets a column; signs keep working with
	--                 'signcolumn' = 'yes' unchanged.
	--                 Wrapped lines draw '↳' and virtual lines '•' instead of a
	--                 number; inactive windows drop the '▏' separator.
	--   dim_inactive  true - matches modus-themes' dim_inactive. The module dims via
	--                 window-local 'winhighlight', modus via NormalNC, so they do not
	--                 compete for the same groups.
	-- Mouse clicks here go to MiniStatuscolumn.default_click(): focus the clicked
	-- window, jump to that line, and center the line on a double click.
	ministatuscolumn.setup()
else
	vim.notify(
		"mini.statuscolumn not found. Install it with:\n  git clone https://github.com/nvim-mini/mini.statuscolumn ~/.local/share/nvim/site/pack/ui/start/mini.statuscolumn",
		vim.log.levels.WARN
	)
end

-- [[ Key clues: mini.clue ]]
-- mini.clue reads descriptions from existing mappings and adds clues for
-- common built-in key prefixes without creating a separate mapping catalog.
local ok_miniclue, miniclue = pcall(require, "mini.clue")
if ok_miniclue then
	miniclue.setup({
		window = { config = { width = "auto" } },
		triggers = {
			-- Leader mappings
			{ mode = { "n", "x" }, keys = "<Leader>" },

			-- Common Normal/Visual prefixes
			{ mode = { "n", "x" }, keys = "g" },
			{ mode = { "n", "x" }, keys = "z" },
			{ mode = "n", keys = "[" },
			{ mode = "n", keys = "]" },

			-- Other built-in key families
			{ mode = "i", keys = "<C-x>" },
			{ mode = "n", keys = "<C-x>" },
			{ mode = { "n", "x" }, keys = "'" },
			{ mode = { "n", "x" }, keys = "`" },
			{ mode = { "n", "x" }, keys = '"' },
			{ mode = { "i", "c" }, keys = "<C-r>" },
			{ mode = "n", keys = "<C-w>" },
		},
		clues = {
			miniclue.gen_clues.square_brackets(),
			miniclue.gen_clues.builtin_completion(),
			miniclue.gen_clues.g(),
			miniclue.gen_clues.marks(),
			miniclue.gen_clues.registers(),
			miniclue.gen_clues.windows(),
			miniclue.gen_clues.z(),
		},
	})
end

-- vim: ts=2 sts=2 sw=2 et
