return {
  "folke/snacks.nvim",
  opts = {
    bigfile = {
      size = 512 * 1024, -- treesitter alone needs ~80ms to parse a file this size
    },
    styles = {
      -- NOTE: lazygit's window dimmensions need to be explicitly set if the terminal's window dimmensions are explicitly changed
      -- otherwise it uses the values from the terminal height/width
      terminal = {
        height = 0.45,
      },
      lazygit = {
        width = 0.9,
        height = 0.9,
      },
    },
    picker = {
      sources = {
        explorer = {
          auto_close = true,
        },
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
      sections = {
        {
          {
            section = "header",
          },
          {
            section = "startup",
            padding = 1,
          },
        },
        {
          pane = 2,
          {
            section = "keys",
            indent = 2,
            padding = 1,
          },
          {
            section = "projects",
            indent = 2,
            padding = 1,
          },
        },
      },
    },
  },
}
