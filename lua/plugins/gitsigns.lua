return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 300,
        -- outrank noice's search-count overlay, which inherits nvim's default extmark priority (4096)
        virt_text_priority = 4097,
      },
    },
  },
}
