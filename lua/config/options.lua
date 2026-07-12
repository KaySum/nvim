-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local tab_width = 4

vim.opt.expandtab = false -- Use tabs instead of spaces
vim.opt.tabstop = tab_width -- Number of spaces tabs count for
vim.opt.shiftwidth = tab_width -- Size of an indent
vim.opt.softtabstop = tab_width -- Number of spaces tabs count for while editing

vim.opt.wrap = true -- Wrap long lines
vim.opt.linebreak = true -- Wrap at word boundaries, not mid-word
vim.opt.breakindent = true -- Wrapped lines continue at the same indent (VS Code style)
vim.opt.breakindentopt = "shift:" .. tab_width -- Indent wrapped lines one extra level, like VS Code's wrappingIndent: "indent"

vim.opt.swapfile = false
