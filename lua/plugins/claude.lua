return {
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {
      diff_opts = {
        -- Inline diff in the current window instead of a side-by-side split
        layout = "unified",
      },
    },
    keys = {
      { "<C-.>", "<cmd>ClaudeCodeFocus<cr>", mode = { "n", "t", "v" }, desc = "Focus/Unfocus Claude" },
    },
  },
}
