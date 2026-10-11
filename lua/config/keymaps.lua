-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set({ "n", "v" }, "<C-d>", "<C-d>zz", { desc = "Half-page down and center cursor" })
vim.keymap.set({ "n", "v" }, "<C-u>", "<C-u>zz", { desc = "Half-page up and center cursor" })

-- NOTE: LazyVim's n/N always search forward/backward regardless of / or ?; keep that and its fold-opening zv
vim.keymap.set(
  { "n", "x" },
  "n",
  "'Nn'[v:searchforward].'zvzz'",
  { expr = true, desc = "Next search result and center cursor" }
)
vim.keymap.set(
  { "n", "x" },
  "N",
  "'nN'[v:searchforward].'zvzz'",
  { expr = true, desc = "Prev search result and center cursor" }
)
vim.keymap.set("n", "*", "*zz", { desc = "Search word forward and center cursor" })
vim.keymap.set("n", "#", "#zz", { desc = "Search word backward and center cursor" })
vim.keymap.set("n", "<C-o>", "<C-o>zz", { desc = "Jump back and center cursor" })
vim.keymap.set("n", "<C-i>", "<C-i>zz", { desc = "Jump forward and center cursor" })

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
