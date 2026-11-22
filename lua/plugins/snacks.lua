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
      },
    },
    picker = {
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
