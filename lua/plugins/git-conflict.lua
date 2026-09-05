-- The plugin binds no keys itself, so scope the bracket motions to buffers that actually have
-- conflicts, the way LazyVim scopes gitsigns' `]h`/`[h`.
local function setup_conflict_nav()
  local grp = vim.api.nvim_create_augroup("git_conflict_nav", { clear = true })
  local function apply(active)
    return function(args)
      local buf = args.data and args.data.bufnr or vim.api.nvim_get_current_buf()
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      for lhs, dir in pairs({ ["]x"] = "Next", ["[x"] = "Prev" }) do
        if active then
          local rhs = ("<cmd>GitConflict%sConflict<cr>"):format(dir)
          vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = dir .. " Conflict" })
        else
          pcall(vim.keymap.del, "n", lhs, { buffer = buf })
        end
      end
    end
  end
  vim.api.nvim_create_autocmd("User", {
    group = grp,
    pattern = "GitConflictDetected",
    callback = apply(true),
  })
  vim.api.nvim_create_autocmd("User", {
    group = grp,
    pattern = "GitConflictResolved",
    callback = apply(false),
  })
end

return {
  {
    "KaySum/git-conflict.nvim",
    -- Load once a real file buffer is opened so conflict markers are detected
    -- and highlighted automatically, without paying the cost at startup.
    event = "LazyFile",
    opts = {
      disable_diagnostics = true, -- a conflicted buffer does not parse, so the errors are noise
    },
    init = function()
      setup_conflict_nav()
    end,
    keys = {
      { "<leader>gxo", "<cmd>GitConflictChooseOurs<cr>", mode = { "n", "x" }, desc = "Choose Ours (Current)" },
      { "<leader>gxt", "<cmd>GitConflictChooseTheirs<cr>", mode = { "n", "x" }, desc = "Choose Theirs (Incoming)" },
      { "<leader>gxb", "<cmd>GitConflictChooseBoth<cr>", mode = { "n", "x" }, desc = "Choose Both" },
      { "<leader>gxa", "<cmd>GitConflictChooseBase<cr>", mode = { "n", "x" }, desc = "Choose Ancestor (Base)" },
      { "<leader>gx0", "<cmd>GitConflictChooseNone<cr>", mode = { "n", "x" }, desc = "Choose None" },
      { "<leader>gxn", "<cmd>GitConflictNextConflict<cr>", desc = "Next Conflict" },
      { "<leader>gxp", "<cmd>GitConflictPrevConflict<cr>", desc = "Prev Conflict" },
      { "<leader>gxq", "<cmd>GitConflictListQf<cr>", desc = "List Conflicts (Quickfix)" },
    },
  },

  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>gx", group = "conflicts", icon = { icon = "󰊢 ", color = "red" } },
      },
    },
  },
}
