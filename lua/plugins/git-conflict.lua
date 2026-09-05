local function has_conflict_markers(buf)
  for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    if vim.startswith(line, "<<<<<<<") then
      return true
    end
  end
  return false
end

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

-- Bind the bracket motions per buffer, so `]x`/`[x` stay free everywhere except files that
-- actually have conflicts, the way LazyVim scopes gitsigns' `]h`/`[h`.
local function setup_conflict_nav()
  local grp = vim.api.nvim_create_augroup("git_conflict_nav", { clear = true })
  -- Both events fire on every reparse, not just on transitions, so track what is already bound.
  local function apply(active)
    return function()
      local buf = vim.api.nvim_get_current_buf()
      if vim.b[buf].git_conflict_nav == active then
        return
      end
      vim.b[buf].git_conflict_nav = active
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

-- git-conflict paints onto the focused buffer rather than the one it parsed, so redrawing a
-- conflicted buffer behind a float (lazygit mid-rebase) stamps the markers over that float.
local function patch_conflict_paint_target()
  local set_provider = vim.api.nvim_set_decoration_provider
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.api.nvim_set_decoration_provider = function(ns, handlers)
    local on_win = handlers.on_win
    if not on_win or ns ~= vim.api.nvim_get_namespaces()["git-conflict"] then
      return set_provider(ns, handlers)
    end
    vim.api.nvim_set_decoration_provider = set_provider -- git-conflict registers once
    handlers.on_win = function(_, winid, bufnr, ...)
      if bufnr ~= vim.api.nvim_get_current_buf() then
        return false
      end
      return on_win(_, winid, bufnr, ...)
    end
    return set_provider(ns, handlers)
  end
end

-- git-conflict samples git state on its own schedule and can miss the buffer in front of you;
-- GitConflictRefresh re-checks from that buffer's own path, so fire it when markers show up.
local function setup_conflict_refresh()
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter", "FileChangedShellPost" }, {
    group = vim.api.nvim_create_augroup("git_conflict_refresh", { clear = true }),
    callback = function(args)
      -- BufEnter also lands on terminals and pickers, whose contents are not worth scanning.
      if vim.bo[args.buf].buftype ~= "" or not has_conflict_markers(args.buf) then
        return
      end
      pcall(vim.cmd.GitConflictRefresh)
      for _, delay in ipairs({ 50, 300 }) do
        vim.defer_fn(function()
          vim.cmd("redraw")
        end, delay)
      end
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
    init = function()
      patch_conflict_paint_target()
      setup_conflict_diagnostics()
      setup_conflict_nav()
      setup_conflict_refresh()
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
