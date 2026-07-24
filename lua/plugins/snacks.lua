local terminal = require("util.snacks_terminal")

return {
  "folke/snacks.nvim",
  init = terminal.setup, -- MRU terminal tracking + <C-/> override
  keys = terminal.keys, -- <leader>tt switch, tr rename, t1..t9 open
  opts = {
    styles = {
      -- NOTE: lazygit's window dimmensions need to be explicitly set if the terminal's window dimmensions are explicitly changed
      -- otherwise it uses the values from the terminal height/width
      terminal = {
        height = 0.45,
        wo = { winbar = terminal.winbar },
      },
      lazygit = {
        width = 0.9,
        height = 0.9,
      },
    },
    dashboard = {
      preset = {
        header = [[
  ██╗  ██╗ █████╗ ██╗   ██╗███████╗██╗   ██╗███╗   ███╗
  ██║ ██╔╝██╔══██╗╚██╗ ██╔╝██╔════╝██║   ██║████╗ ████║
  █████╔╝ ███████║ ╚████╔╝ ███████╗██║   ██║██╔████╔██║
  ██╔═██╗ ██╔══██║  ╚██╔╝  ╚════██║██║   ██║██║╚██╔╝██║
  ██║  ██╗██║  ██║   ██║   ███████║╚██████╔╝██║ ╚═╝ ██║
  ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝ ╚═════╝ ╚═╝     ╚═╝]],
      },
    },
  },
}
