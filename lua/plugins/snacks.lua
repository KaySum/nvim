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
          -- NOTE: openDirInEditor has not been tested
          -- editAtLineAndWait stays on the preset: lazygit blocks on it to apply the edited hunk,
          -- so it has to run a nested nvim in the float rather than hand the file off with --remote
          openDirInEditor = nvim_remote("nvim -- {{dir}}", "{{dir}}"),
        },
      },
    },
    styles = {
      terminal = {
        height = 0.45,
      },
      lazygit = {
        -- NOTE: lazygit's window dimensions need to be explicitly set if the terminal's window dimensions are explicitly changed
        -- otherwise it uses the values from the terminal height/width
        width = 0.9,
        height = 0.9,
        -- hide when focus moves elsewhere (e.g. <c-.> to sidekick), else the float covers it
        on_win = function(self)
          vim.api.nvim_create_autocmd("WinLeave", {
            group = self.augroup,
            buffer = self.buf,
            callback = vim.schedule_wrap(function()
              if self:valid() and vim.api.nvim_get_current_win() ~= self.win then
                self:hide()
              end
            end),
          })
        end,
      },
    },
    picker = {
      -- Referenced by name so sources can still pick their own preset (e.g. vim.ui.select uses "select")
      layout = { preset = "kaysum" },
      layouts = {
        kaysum = {
          layout = {
            width = 0.9,
            height = 0.9,
            box = "vertical",
            { win = "input", height = 1, border = true, title = "{title} {live} {flags}", title_pos = "center" },
            { win = "list", height = 0.3, max_height = 8, border = true, footer_pos = "right" },
            { win = "preview", title = "{preview}", border = true },
          },
        },
      },
      -- Show the cursor's position in the list's footer; snacks has no built-in option for it.
      -- NOTE: list.cursor and list:count() are undocumented (read-only use); revisit on bumps.
      -- BUG: on_change only fires when the highlighted item changes, so the total goes stale
      -- while results stream in or the filter changes under the same item; it corrects on the next move.
      on_change = function(picker)
        local list, win = picker.list, picker.list.win
        if not win:valid() or not win:has_border() then
          return
        end
        local count = list:count()
        win.opts.footer = count > 0 and (" %d/%d "):format(list.cursor, count) or ""
        -- nvim resets footer_pos to "left" unless it's passed alongside the footer
        vim.api.nvim_win_set_config(win.win, { footer = win.opts.footer, footer_pos = win.opts.footer_pos })
      end,
      sources = {
        explorer = {
          auto_close = true,
        },
        grep = {
          regex = false, -- <A-r> toggles regex back on
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
