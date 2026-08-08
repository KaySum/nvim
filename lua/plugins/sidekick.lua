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
      ---@diagnostic disable-next-line: duplicate-set-field
      Session.cwd = function(session)
        session = session or {}
        session.cwd = session.cwd or LazyVim.root()
        return resolve_cwd(session)
      end
      require("sidekick").setup(opts)

      -- Claude is the only CLI in use, so keep it the only choice and skip the picker
      local Config = require("sidekick.config")
      Config.cli.tools = { claude = Config.cli.tools.claude }
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
