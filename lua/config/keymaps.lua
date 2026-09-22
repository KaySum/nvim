-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set({ "n", "v" }, "<C-d>", "<C-d>zz", { desc = "Half-page down and center cursor" })
vim.keymap.set({ "n", "v" }, "<C-u>", "<C-u>zz", { desc = "Half-page up and center cursor" })

vim.keymap.set({ "n", "i", "v" }, "<D-s>", "<cmd>w<cr>", { desc = "Save file" })

Snacks.toggle({
  name = "Custom Root Spec",
  get = function()
    return vim.g.root_spec ~= nil
  end,
  set = function(state)
    vim.g.root_spec = state and vim.g.custom_root_spec or nil
    LazyVim.root.cache = {} -- roots are cached per buffer, so the current one would keep the old value
  end,
}):map("<leader>uR")
