-- lazygit's nvim-remote preset edits with `--remote-tab`; `--remote` reuses the current window, but
-- lazygit exits async, so we quit it and close its float up front, else the file opens inside it.
local function nvim_remote(fallback, target, line)
  local nv = 'nvim --server "$NVIM" '
  local steps = {
    nv .. [[--remote-expr "&buftype == 'terminal' ? chansend(&channel, 'q') : 0"]],
    nv .. [[--remote-expr "nvim_win_get_config(0).relative != '' ? nvim_win_close(0, v:false) : 0"]],
    nv .. "--remote " .. target,
  }
  if line then
    steps[#steps + 1] = nv .. ('--remote-expr "cursor(%s, 1)"'):format(line)
  end
  return ('[ -z "$NVIM" ] && (%s) || (%s)'):format(fallback, table.concat(steps, " && "))
end

return {
  "folke/snacks.nvim",
  opts = {
    bigfile = {
      size = 512 * 1024, -- treesitter alone needs ~80ms to parse a file this size
    },
    lazygit = {
      config = {
        os = {
          edit = nvim_remote("nvim -- {{filename}}", "{{filename}}"),
          editAtLine = nvim_remote("nvim +{{line}} -- {{filename}}", "{{filename}}", "{{line}}"),
          openDirInEditor = nvim_remote("nvim -- {{dir}}", "{{dir}}"), -- NOTE: openDirInEditor has not been tested
        },
      },
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
        on_buf = function(self)
          -- on_buf runs on every show and the buffer is reused, so clear to avoid stacking these
          local group = vim.api.nvim_create_augroup("lazygit_reap_" .. self.buf, { clear = true })
          -- a hidden lazygit stays alive and keeps piping diffs through delta on every refresh,
          -- so quit it; the delay lets the nvim-remote edit preset open the file first
          -- NOTE: both delays are tuned guesses; stricter would be sequencing the 2s on the edit
          -- preset actually finishing, and polling the job rather than assuming 1s is enough to quit
          vim.api.nvim_create_autocmd("BufHidden", {
            group = group,
            buffer = self.buf,
            callback = function()
              vim.defer_fn(function()
                if not self:buf_valid() or vim.fn.bufwinid(self.buf) ~= -1 then
                  return
                end
                vim.api.nvim_chan_send(vim.b[self.buf].terminal_job_id, "q")
                -- lazygit swallows `q` while a popup has focus, so kill whatever survived it;
                -- a clean quit has wiped the buffer via TermClose by now, so this only hits strays.
                -- WARNING: killing skips lazygit's state.yml write, losing its recent repos and command history
                vim.defer_fn(function()
                  if self:buf_valid() and vim.fn.bufwinid(self.buf) == -1 then
                    self:close()
                  end
                end, 1000)
              end, 2000)
            end,
          })
          -- snacks drops its own TermClose handler on hide, so a lazygit that quits while hidden
          -- would leave a dead buffer for the cached terminal to reuse on the next open
          vim.api.nvim_create_autocmd("TermClose", {
            group = group,
            buffer = self.buf,
            callback = function()
              if vim.fn.bufwinid(self.buf) == -1 then
                self:close()
              end
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
