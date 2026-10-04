return {
  -- Disable NES so the sidekick extra doesn't register the copilot LSP server
  {
    "folke/sidekick.nvim",
    opts = {
      nes = { enabled = false },
    },
  },
}
