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

      local function refresh_on(pattern)
        return {
          event = "User",
          opts = {
            pattern = pattern,
            desc = "Update git staged/unstaged annotations",
            get_buffers = function(args)
              return args.data and tonumber(args.data.buffer) or nil
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
        autocmds = { refresh_on("GitSignsUpdate"), refresh_on(STAGED_EVENT) },
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
        autocmds = {
          {
            event = "User",
            opts = {
              pattern = { "GitConflictDetected", "GitConflictResolved" },
              desc = "Update git conflict annotations",
              get_buffers = function(args)
                return args.buf
              end,
            },
          },
        },
        init = function() end,
        get_annotations = function(bufnr)
          local conflict = require("util.git_conflict")
          local annotations = {}
          for lnum, hl in pairs(conflict.line_status(bufnr)) do
            annotations[#annotations + 1] = {
              lnum = lnum,
              end_lnum = lnum,
              priority = 30, -- above git signs; conflicts are the urgent thing
              highlight = hl,
            }
          end
          return annotations
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
          search = { enabled = true },
          mark = { enabled = true },
          handlers = { git_staged_unstaged, git_conflict },
        }
      end
    end,
  },
}
