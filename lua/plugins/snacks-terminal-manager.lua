local keys = {
  { "<c-/>", "<cmd>SnacksTerminalToggle<cr>", mode = { "n", "t" }, desc = "Terminal (Root Dir)" },
  { "<c-_>", "<cmd>SnacksTerminalToggle<cr>", mode = { "n", "t" }, desc = "which_key_ignore" },
  { "<leader>tt", "<cmd>SnacksTerminalPick<cr>", desc = "Switch Terminal" },
  { "<leader>tr", "<cmd>SnacksTerminalRename<cr>", desc = "Rename Terminal" },
  { "<leader>td", "<cmd>SnacksTerminalClose<cr>", desc = "Close Terminal" },
}
for i = 1, 9 do
  keys[#keys + 1] = { "<leader>t" .. i, "<cmd>" .. i .. "SnacksTerminalToggle<cr>", desc = "Terminal #" .. i }
end

return {
  "KaySum/snacks-terminal-manager.nvim",
  dependencies = { "folke/snacks.nvim" },
  lazy = false,
  opts = {
    root = function()
      return LazyVim.root()
    end,
  },
  keys = keys,
}
