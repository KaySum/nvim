return {
  "akinsho/bufferline.nvim",
  opts = {
    options = {
      always_show_bufferline = true, -- show even with a single buffer open
      auto_toggle_bufferline = false, -- don't re-assert showtabline; let Snacks dashboard hide it (we set showtabline=2 in config/options.lua)
    },
  },
}
