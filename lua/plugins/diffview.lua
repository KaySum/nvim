return {
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewFileHistory",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
    },
    keys = {
      {
        "<leader>gvv",
        function()
          -- Close only when the current tab is a diffview (diff or file history);
          -- otherwise open. Checking the current-tab view avoids getting stuck when
          -- a view exists in another tab but DiffviewClose acts on the current one.
          if require("diffview.lib").get_current_view() then
            vim.cmd("DiffviewClose")
          else
            vim.cmd("DiffviewOpen")
          end
        end,
        desc = "Diffview Toggle",
      },
      { "<leader>gvh", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview File History" },
      { "<leader>gvf", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview Current File History" },
      {
        "<leader>gvr",
        function()
          vim.ui.input({ prompt = "Diff against ref: " }, function(ref)
            if ref and ref ~= "" then
              vim.cmd("DiffviewOpen " .. ref)
            end
          end)
        end,
        desc = "Diffview vs Ref",
      },
      { "<leader>gvc", "<cmd>DiffviewOpen<cr>", desc = "Diffview Resolve Conflicts" },
    },
    opts = {
      enhanced_diff_hl = true,
    },
  },

  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>gv", group = "diffview", icon = { icon = "󰊢 ", color = "orange" } },
      },
    },
  },
}
