return {
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        section_separators = "",
        component_separators = "",
      },
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
