return {
  "KaySum/lazygit-icons.nvim",
  dependencies = { "nvim-mini/mini.icons" },
  opts = {
    only = {
      ["*.jsx"] = "color",
      ["package.json"] = "icon",
    },
  },
}
