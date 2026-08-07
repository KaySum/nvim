local disabled = {
  "nvim-mini/mini.pairs",
  "rafamadriz/friendly-snippets",
  "catppuccin",
  "MagicDuck/grug-far.nvim",
  "folke/flash.nvim",
}

return vim.tbl_map(function(plugin)
  return { plugin, enabled = false }
end, disabled)
