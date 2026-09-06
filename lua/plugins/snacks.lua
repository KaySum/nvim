-- bufwinid() only looks in the current tabpage, so it calls a float in another tab hidden
local function is_hidden(buf)
  return #vim.fn.win_findbuf(buf) == 0
end

-- one restartable timer beats stacking vim.defer_fn calls, which cannot be called off: reopening
-- lazygit has to cancel the pending reap, not leave it to fire against a later hide
local function after(timer, ms, fn)
  timer:start(ms, 0, vim.schedule_wrap(fn))
end

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
          -- editAtLineAndWait stays on the preset: lazygit blocks on it to apply the edited hunk,
          -- so it has to run a nested nvim in the float rather than hand the file off with --remote
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
          self.reap = self.reap or vim.uv.new_timer()
          self.reap:stop() -- reopening calls off a pending reap, before the guard below returns
          -- on_buf runs on every show, but the buffer and its buffer-local autocmds are reused
          if vim.b[self.buf].lazygit_reap then
            return
          end
          vim.b[self.buf].lazygit_reap = true
          -- a hidden lazygit stays alive and keeps piping diffs through delta on every refresh, so
          -- quit it; reaping wipes the buffer, killing the pty and any edit preset chain still
          -- running in it, so the delay has to outlast the whole chain
          -- NOTE: the 2s is a tuned guess; stricter would be sequencing it on the chain finishing
          vim.api.nvim_create_autocmd("BufHidden", {
            buffer = self.buf,
            callback = function()
              after(self.reap, 2000, function()
                if not self:buf_valid() or not is_hidden(self.buf) then
                  return
                end
                -- a nonzero exit leaves snacks' auto_close with the buffer open, so a later hide lands
                -- here with lazygit already gone; there is nothing to quit, so just reap the buffer
                local job = vim.b[self.buf].terminal_job_id
                if vim.fn.jobwait({ job }, 0)[1] ~= -1 then
                  self:close()
                  return
                end
                vim.api.nvim_chan_send(job, "q")
                -- lazygit swallows `q` while a popup has focus, so kill whatever survived it;
                -- a clean quit has wiped the buffer via TermClose by now (~10ms), so this only hits
                -- strays. state.yml is written at startup, so a kill only loses what the popup held;
                -- reopening calls the kill off instead, leaving the `q` it typed into that popup
                after(self.reap, 1000, function()
                  if self:buf_valid() and is_hidden(self.buf) then
                    self:close()
                  end
                end)
              end)
            end,
          })
          -- snacks only re-registers its own TermClose handler on show, so a lazygit that quits
          -- while hidden would leave a dead buffer for the cached terminal to reuse on the next open
          vim.api.nvim_create_autocmd("TermClose", {
            buffer = self.buf,
            callback = function()
              if self:buf_valid() and is_hidden(self.buf) then
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
