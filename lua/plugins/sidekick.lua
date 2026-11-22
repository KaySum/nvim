return {
  -- Disable NES so the sidekick extra doesn't register the copilot LSP server
  {
    "folke/sidekick.nvim",
    opts = {
      nes = { enabled = false },
      cli = { win = { keys = { prompt = false } } },
    },
    keys = {
      {
        "<c-.>",
        function()
          -- sidekick opens as a split, so a focused float (e.g. lazygit) would cover it
          if vim.api.nvim_win_get_config(0).relative ~= "" then
            vim.api.nvim_win_close(0, false)
          end
          require("sidekick.cli").focus()
        end,
        desc = "Sidekick Focus",
        mode = { "n", "t", "i", "x" },
      },
    },
  },
}
