return {
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      sections = {
        lualine_z = {
          function()
            return " " .. (os.date("%l:%M %p") --[[@as string]]):gsub("^%s+", "")
          end,
        },
      },
    },
  },
}
