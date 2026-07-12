return {
  {
    "KaySum/nvim-agent-path-ref",
    cmd = "AgentPathRef",
    keys = {
      { "<leader>ay", "<Plug>(AgentPathRef)", mode = { "n", "x" }, desc = "Yank @file reference" },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>a", group = "ai", mode = { "n", "x" } },
      },
    },
  },
}
