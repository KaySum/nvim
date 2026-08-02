local function close_oil()
  local oil = require("oil")
  oil.save(nil, function(err)
    if not err then
      return oil.close()
    end
    -- Declined the confirmation: drop pending edits so they don't linger, then close.
    if err == "Canceled" then
      oil.discard_all_changes()
      oil.close()
    end
  end)
end

local function is_editable(bufnr)
  return vim.bo[bufnr].buftype == "" or vim.bo[bufnr].filetype == "oil"
end

local function toggle_oil(dir)
  -- Oil replaces the focused window's buffer; from a plugin window (e.g. the snacks explorer) route to where we came from so the layout doesn't collapse.
  if not is_editable(vim.api.nvim_get_current_buf()) then
    local prev = vim.fn.win_getid(vim.fn.winnr("#"))
    if prev == 0 or not is_editable(vim.api.nvim_win_get_buf(prev)) then
      return
    end
    vim.api.nvim_set_current_win(prev)
  end

  if vim.bo.filetype == "oil" then
    close_oil()
  else
    require("oil").open(dir)
  end
end

return {
  {
    "stevearc/oil.nvim",
    -- Load eagerly so oil takes over as the default directory handler (replaces netrw).
    lazy = false,
    dependencies = { "nvim-mini/mini.icons" },
    -- Oil's buffer creation races which-key's trigger setup, so the leader trigger
    -- never lands and <Space> falls through as a literal space. Re-attach on entry.
    init = function()
      -- NOTE: FileType only fires on buffer creation. If you leave an oil buffer and which-key
      -- clears its state, re-entry won't re-attach; switch to BufEnter (ft-gated) if that recurs.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "oil",
        callback = function(ev)
          vim.schedule(function()
            -- NOTE: which-key.buf is internal API (no public buffer-refresh exists); the pcall
            -- means an upstream change would silently no-op, re-breaking leader here. Revisit on bumps.
            pcall(function()
              require("which-key.buf").get({ buf = ev.buf, update = true })
            end)
          end)
        end,
      })
    end,
    opts = {
      view_options = {
        show_hidden = true,
      },
      keymaps = {
        ["q"] = { close_oil, mode = "n", desc = "Apply/Discard Changes and Close" },
      },
    },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Explorer Oil (parent dir)" },
      {
        "<leader>o",
        function()
          toggle_oil()
        end,
        desc = "Explorer Oil",
      },
      {
        "<leader>O",
        function()
          toggle_oil(vim.fn.getcwd())
        end,
        desc = "Explorer Oil (cwd)",
      },
    },
  },
}
