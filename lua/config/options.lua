vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt

-- Indentation
opt.expandtab = true -- use spaces instead of tabs
opt.tabstop = 2
opt.shiftwidth = 2
opt.shiftround = true
opt.smartindent = true

-- UI
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.scrolloff = 4
opt.sidescrolloff = 8
opt.laststatus = 3 -- one global statusline instead of one per window
opt.pumheight = 10
opt.pumblend = 10
opt.winminwidth = 5
opt.list = true
-- Fold glyphs are omitted: they only render in 'foldcolumn', which LazyVim's statuscolumn drew.
opt.fillchars = { fold = " ", foldsep = " ", diff = "╱", eob = " " }
opt.conceallevel = 2
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "screen"

-- Editing
opt.wrap = false
opt.linebreak = true -- when wrap is on, break at word boundaries rather than mid-word
opt.clipboard = "unnamedplus"
opt.virtualedit = "block"
opt.formatoptions = "jcroqlnt"
opt.completeopt = "menu,menuone,noselect"
opt.confirm = true -- prompt to save instead of failing on unsaved changes
opt.autowrite = true
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200
opt.timeoutlen = 300
opt.jumpoptions = "view"
opt.wildmode = "longest:full,full"
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.spelllang = { "en" }

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"

opt.foldlevel = 99

-- Add any additional options here

-- Factor applied to shiftwidth for the wrapped-line indent (VS Code deepIndent = 2).
-- Global so a re-detecting plugin (vim-sleuth) can reuse it when it recomputes breakindentopt.
vim.g.wrap_indent_multiplier = 2

local tab_width = 4

opt.expandtab = false -- use tabs instead of spaces
opt.tabstop = tab_width
opt.shiftwidth = tab_width
opt.softtabstop = tab_width

opt.wrap = true
opt.breakindent = true -- wrapped lines continue at the same indent (VS Code style)
opt.breakindentopt = "shift:" .. vim.g.wrap_indent_multiplier * tab_width

opt.swapfile = false
