return {
  "folke/snacks.nvim",
  opts = {
    -- Overriding `setup` means restating the upstream body, minus what we also want off.
    bigfile = {
      size = 512 * 1024, -- treesitter alone needs ~80ms to parse a file this size
      ---@param ctx {buf: number, ft: string}
      setup = function(ctx)
        if vim.fn.exists(":NoMatchParen") ~= 0 then
          vim.cmd([[NoMatchParen]])
        end
        -- Wrapping only hurts once one logical line spans many screen rows, i.e. long-lined files.
        local avg_line_length = vim.fn.getfsize(vim.api.nvim_buf_get_name(ctx.buf))
          / vim.api.nvim_buf_line_count(ctx.buf)

        Snacks.util.wo(0, {
          wrap = avg_line_length < 200, -- normal source sits around 30-50
          foldmethod = "manual",
          statuscolumn = "",
          conceallevel = 0,
        })
        -- Index by buffer so these land on the big file, not on whatever buffer happens to be current.
        vim.b[ctx.buf].completion = false
        vim.b[ctx.buf].minianimate_disable = true -- inert: mini.animate isn't installed, kept for upstream parity
        vim.b[ctx.buf].minihipatterns_disable = true
        vim.b[ctx.buf].snacks_scroll = false
        vim.b[ctx.buf].snacks_indent = false
        vim.b[ctx.buf].snacks_scope = false
        vim.bo[ctx.buf].undofile = false -- multi-MB buffers write multi-MB undo files
        vim.bo[ctx.buf].synmaxcol = 300 -- long lines are the pathological case for regex syntax
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(ctx.buf) then
            vim.bo[ctx.buf].syntax = ctx.ft
          end
        end)
      end,
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
