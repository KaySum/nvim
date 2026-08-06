return {
  {
    "Isrothy/neominimap.nvim",
    lazy = false, -- neominimap recommends against lazy-loading
    keys = {
      { "<leader>uM", "<cmd>Neominimap Toggle<cr>", desc = "Toggle Minimap" },
    },
    init = function()
      -- Shows staged and unstaged hunks distinctly; classification lives in util.git_hunks.
      local id_by_type = { add = 1, change = 2, delete = 3 }

      -- Fired by init()'s gitsigns hook; covers staged-only changes GitSignsUpdate skips (e.g. a commit).
      local STAGED_EVENT = "NeominimapGitStaged"

      local DIAGNOSTIC_TOGGLE_EVENT = "NeominimapDiagnosticToggled"

      -- The built-in builds its highlight group from config.diagnostic.mode; both must agree.
      local DIAGNOSTIC_MODE = "line"

      local function refresh_on(event, pattern)
        return {
          event = event,
          opts = {
            pattern = pattern,
            desc = "Refresh minimap annotations",
            get_buffers = function(args)
              return args.data and tonumber(args.data.buffer) or args.buf
            end,
          },
        }
      end

      local function emit_on_staged_change()
        local ok, manager = pcall(require, "gitsigns.manager")
        if not ok then
          return
        end
        manager.on_update(function(ctx)
          if ctx.hunks_staged_changed then
            vim.api.nvim_exec_autocmds("User", {
              pattern = STAGED_EVENT,
              modeline = false,
              data = { buffer = ctx.bufnr },
            })
          end
        end)
      end

      local git_staged_unstaged = {
        name = "Git Staged/Unstaged",
        mode = "sign",
        namespace = vim.api.nvim_create_namespace("neominimap_git_staged_unstaged"),
        autocmds = { refresh_on("User", "GitSignsUpdate"), refresh_on("User", STAGED_EVENT) },
        init = function()
          -- gitsigns may attach after neominimap loads; hook once it's up.
          if package.loaded["gitsigns.manager"] then
            emit_on_staged_change()
          else
            vim.api.nvim_create_autocmd("User", {
              pattern = "GitSignsUpdate",
              once = true,
              callback = emit_on_staged_change,
            })
          end
        end,
        get_annotations = function(bufnr)
          local git = require("util.git_hunks")
          local annotations = {}
          for lnum, s in pairs(git.line_status(bufnr)) do
            annotations[#annotations + 1] = {
              lnum = lnum,
              end_lnum = lnum,
              id = id_by_type[s.type],
              priority = s.staged and 6 or 7, -- unstaged wins on collapsed rows
              highlight = git.hl_group(s.type, s.staged),
            }
          end
          return annotations
        end,
      }

      -- Conflict regions mirror git-conflict.nvim's own highlights (read from its
      -- extmarks in util.git_conflict). Edits refresh via neominimap's per-change
      -- pass; the detect/resolve events cover its async highlighting on open.
      local git_conflict = {
        name = "Git Conflict",
        mode = "line",
        namespace = vim.api.nvim_create_namespace("neominimap_git_conflict"),
        autocmds = { refresh_on("User", { "GitConflictDetected", "GitConflictResolved" }) },
        init = function() end,
        get_annotations = function(bufnr)
          local conflict = require("util.git_conflict")
          local annotations = {}
          for lnum, hl in pairs(conflict.line_status(bufnr)) do
            annotations[#annotations + 1] = {
              lnum = lnum,
              end_lnum = lnum,
              priority = 110, -- above diagnostics (ERROR = 100); conflicts are the urgent thing
              highlight = hl,
            }
          end
          return annotations
        end,
      }

      -- Mirrors <leader>ud: the built-in keeps painting, as vim.diagnostic.get() ignores display state.
      local diagnostic = {
        name = "Diagnostic",
        mode = DIAGNOSTIC_MODE,
        namespace = vim.api.nvim_create_namespace("neominimap_diagnostic_synced"),
        autocmds = { refresh_on("DiagnosticChanged"), refresh_on("User", DIAGNOSTIC_TOGGLE_EVENT) },
        init = function()
          -- enable() fires no DiagnosticChanged, but these do — on every publish too, so only emit on flips.
          local function on_toggle(_, bufnr)
            if not vim.api.nvim_buf_is_valid(bufnr) then
              return
            end
            local state = vim.diagnostic.is_enabled({ bufnr = bufnr })
            if vim.b[bufnr].neominimap_diag_enabled == state then
              return
            end
            vim.b[bufnr].neominimap_diag_enabled = state
            vim.api.nvim_exec_autocmds("User", {
              pattern = DIAGNOSTIC_TOGGLE_EVENT,
              modeline = false,
              data = { buffer = bufnr },
            })
          end
          vim.diagnostic.handlers.neominimap_sync = { show = on_toggle, hide = on_toggle }
        end,
        get_annotations = function(bufnr)
          if not vim.diagnostic.is_enabled({ bufnr = bufnr }) then
            return {}
          end
          return require("neominimap.map.handlers.builtins.diagnostic").get_annotations(bufnr)
        end,
      }

      vim.g.neominimap = function()
        return {
          layout = "split", -- real split window (reserves space, never overlaps text)
          split = {
            minimap_width = 10, -- thinner than the default 20
            fix_width = true, -- keep the width stable
            close_if_last_window = true,
          },
          -- Don't open the split for tabs that only hold the snacks dashboard
          -- (exclude_filetypes only blanks the map; the split still opens).
          tab_filter = function(tabid)
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabid)) do
              if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "snacks_dashboard" then
                return false
              end
            end
            return true
          end,
          -- Reserve the sign column so the map never reflows when git signs come/go.
          -- NOTE: permanent ~2-cell cost, and caps signs at 1/row — use "auto:1-2" if a 2nd sign handler is added.
          winopt = function(opt)
            opt.signcolumn = "yes:1"
          end,
          git = { enabled = false }, -- replaced by the custom staged/unstaged handler below
          diagnostic = { enabled = false, mode = DIAGNOSTIC_MODE }, -- replaced by the <leader>ud-aware handler below
          search = { enabled = true },
          mark = { enabled = true },
          handlers = { git_staged_unstaged, git_conflict, diagnostic },
        }
      end
    end,
  },
}
