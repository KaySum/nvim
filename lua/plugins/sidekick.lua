return {
  -- Disable NES so the sidekick extra doesn't register the copilot LSP server
  {
    "folke/sidekick.nvim",
    opts = {
      nes = { enabled = false },
    },
  },

  -- Belt and suspenders: make sure the copilot server is never enabled
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        copilot = { enabled = false },
      },
    },
  },
}
