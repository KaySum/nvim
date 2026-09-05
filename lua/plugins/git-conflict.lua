return {
  {
    "KaySum/git-conflict.nvim",
    -- Load once a real file buffer is opened so conflict markers are detected
    -- and highlighted automatically, without paying the cost at startup.
    event = "LazyFile",
    opts = {
      disable_diagnostics = true, -- a conflicted buffer does not parse, so the errors are noise
      mappings = {
        { "]x", "<cmd>GitConflictNextConflict<cr>", desc = "Next Conflict" },
        { "[x", "<cmd>GitConflictPrevConflict<cr>", desc = "Prev Conflict" },
      },
    },
    keys = {
      { "<leader>gxo", "<cmd>GitConflictChooseOurs<cr>", mode = { "n", "x" }, desc = "Choose Ours (Current)" },
      { "<leader>gxt", "<cmd>GitConflictChooseTheirs<cr>", mode = { "n", "x" }, desc = "Choose Theirs (Incoming)" },
      { "<leader>gxb", "<cmd>GitConflictChooseBoth<cr>", mode = { "n", "x" }, desc = "Choose Both" },
      { "<leader>gxa", "<cmd>GitConflictChooseBase<cr>", mode = { "n", "x" }, desc = "Choose Ancestor (Base)" },
      { "<leader>gx0", "<cmd>GitConflictChooseNone<cr>", mode = { "n", "x" }, desc = "Choose None" },
      { "<leader>gxn", "<cmd>GitConflictNextConflict<cr>", desc = "Next Conflict" },
      { "<leader>gxp", "<cmd>GitConflictPrevConflict<cr>", desc = "Prev Conflict" },
      { "<leader>gxq", "<cmd>GitConflictListQf<cr>", desc = "List Conflicts (Quickfix)" },
    },
  },

  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>gx", group = "conflicts", icon = { icon = "󰊢 ", color = "red" } },
      },
    },
  },
}
