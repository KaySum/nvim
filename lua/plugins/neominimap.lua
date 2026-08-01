return {
  {
    "Isrothy/neominimap.nvim",
    lazy = false, -- neominimap recommends against lazy-loading
    keys = {
      { "<leader>uM", "<cmd>Neominimap Toggle<cr>", desc = "Toggle Minimap" },
    },
    init = function()
      -- Custom git handler that shows both staged and unstaged hunks, distinctly
      -- colored. The per-line staged/unstaged classification lives in the shared
      -- util.git_hunks module; here we just map it to neominimap annotations.
      local id_by_type = { add = 1, change = 2, delete = 3 }
      local git_staged_unstaged = {
        name = "Git Staged/Unstaged",
        mode = "sign",
        namespace = vim.api.nvim_create_namespace("neominimap_git_staged_unstaged"),
        autocmds = {
          {
            event = "User",
            opts = {
              pattern = "GitSignsUpdate",
              desc = "Update git staged/unstaged annotations",
              get_buffers = function(args)
                return args.data and tonumber(args.data.buffer) or nil
              end,
            },
          },
        },
        init = function() end,
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

      vim.g.neominimap = function()
        return {
          layout = "split", -- real split window (reserves space, never overlaps text)
          split = {
            minimap_width = 10, -- thinner than the default 20
            fix_width = true, -- keep the width stable
            close_if_last_window = true,
          },
          git = { enabled = false }, -- replaced by the custom staged/unstaged handler below
          search = { enabled = true },
          mark = { enabled = true },
          handlers = { git_staged_unstaged },
        }
      end
    end,
  },
}
