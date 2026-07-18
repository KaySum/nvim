-- Reimplements git-conflict's `disable_diagnostics` with the Neovim 0.11+ API:
-- suppress LSP diagnostics inside a buffer while it has conflicts, restore on resolve.
-- git-conflict still fires these User events correctly; only its own handler is broken.
local function setup_conflict_diagnostics()
  local grp = vim.api.nvim_create_augroup("git_conflict_diagnostics", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = grp,
    pattern = "GitConflictDetected",
    callback = function()
      vim.diagnostic.enable(false, { bufnr = vim.api.nvim_get_current_buf() })
    end,
  })
  vim.api.nvim_create_autocmd("User", {
    group = grp,
    pattern = "GitConflictResolved",
    callback = function()
      vim.diagnostic.enable(true, { bufnr = vim.api.nvim_get_current_buf() })
    end,
  })
end

return {
  {
    "akinsho/git-conflict.nvim",
    version = "*", -- pin to tagged releases (recommended by the author)
    -- Load once a real file buffer is opened so conflict markers are detected
    -- and highlighted automatically, without paying the cost at startup.
    event = "LazyFile",
    opts = {
      -- NOTE: do NOT set `disable_diagnostics = true`. On Neovim 0.11+ it crashes:
      -- git-conflict calls vim.diagnostic.disable(bufnr), a signature removed from
      -- the API, and upstream is unmaintained. setup_conflict_diagnostics reimplements it.
      default_mappings = false,
    },
    init = setup_conflict_diagnostics,
    keys = {
      { "<leader>gxo", "<cmd>GitConflictChooseOurs<cr>", desc = "Choose Ours (current)" },
      { "<leader>gxt", "<cmd>GitConflictChooseTheirs<cr>", desc = "Choose Theirs (incoming)" },
      { "<leader>gxb", "<cmd>GitConflictChooseBoth<cr>", desc = "Choose Both" },
      { "<leader>gx0", "<cmd>GitConflictChooseNone<cr>", desc = "Choose None" },
      { "<leader>gxn", "<cmd>GitConflictNextConflict<cr>", desc = "Next Conflict" },
      { "<leader>gxp", "<cmd>GitConflictPrevConflict<cr>", desc = "Prev Conflict" },
      { "<leader>gxq", "<cmd>GitConflictListQf<cr>", desc = "List Conflicts (quickfix)" },
    },
  },

  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>gx", group = "Git Conflict", icon = { icon = "󰊢 ", color = "red" } },
      },
    },
  },
}
