return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 300,
        -- NOTE: This is so git blame renders after the `/` search count.
        -- This is one above noice's default 4096 virtual text priority.
        virt_text_priority = 4097,
      },
    },
  },
}
