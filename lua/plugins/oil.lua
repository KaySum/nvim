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

local function toggle_oil(dir)
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
