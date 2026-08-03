return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 300,
        -- See lua/config/overrides/virtual_text_priority.lua for the ordering rationale.
        virt_text_priority = require("config.overrides.virtual_text_priority").git_blame,
      },
    },
  },
}
