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
        -- a hidden lazygit stays alive and keeps piping diffs through delta on every refresh,
        -- so quit it; the delay lets the nvim-remote edit preset open the file first
        on_buf = function(self)
          vim.api.nvim_create_autocmd("BufHidden", {
            buffer = self.buf,
            callback = function()
              vim.defer_fn(function()
                if self:buf_valid() and vim.fn.bufwinid(self.buf) == -1 then
                  vim.api.nvim_chan_send(vim.b[self.buf].terminal_job_id, "q")
                end
              end, 2000)
            end,
          })
        end,
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
