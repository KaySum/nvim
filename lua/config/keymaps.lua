-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function ctrl(keys)
	-- Cmd on macOS, Ctrl on Windows/Linux
	local mod = vim.fn.has("mac") == 1 and "D" or "C"
	return "<" .. mod .. "-" .. keys .. ">"
end

vim.keymap.set({ "n", "i", "v" }, ctrl("s"), "<cmd>w<cr>", { desc = "Save file" })

vim.keymap.set({ "n", "i" }, ctrl("z"), "u", { desc = "Undo" })
vim.keymap.set("n", ctrl("S-z"), "<C-r>", { desc = "Redo" })
vim.keymap.set("i", ctrl("S-z"), "<C-o><C-r>", { desc = "Redo" })

vim.keymap.set("i", ctrl("v"), "<C-r>+", { desc = "Paste" })
