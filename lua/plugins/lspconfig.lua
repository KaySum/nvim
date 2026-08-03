return {
  {
    "neovim/nvim-lspconfig",
    init = function()
      require("config.overrides.diagnostic_priority").setup()
    end,
  },
}
