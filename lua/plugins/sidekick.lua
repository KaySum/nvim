return {
  -- Disable NES so the sidekick extra doesn't register the copilot LSP server
  {
    "folke/sidekick.nvim",
    opts = {
      nes = { enabled = false },
    },
    config = function(_, opts)
      -- Start AI CLIs in the project root by default, but don't override the
      -- directory of a session that already has one (e.g. reattach).
      local Session = require("sidekick.cli.session")
      local resolve_cwd = Session.cwd
      rawset(Session, "cwd", function(session)
        session = session or {}
        session.cwd = session.cwd or LazyVim.root()
        return resolve_cwd(session)
      end)
      require("sidekick").setup(opts)
    end,
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
