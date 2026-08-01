-- Per-line conflict highlights read straight from git-conflict.nvim's own
-- extmarks, so the minimap shows exactly what it paints in the buffer and
-- inherits its gating (real merge + complete markers) with no false positives.

local M = {}

---Per-line conflict highlight group for a buffer, taken from git-conflict.nvim's
---extmarks; empty when git-conflict isn't loaded or the buffer has no conflicts.
---@param bufnr integer explicit buffer handle (>= 1)
---@return table<integer, string> -- 1-indexed line -> highlight group
function M.line_status(bufnr)
  assert(type(bufnr) == "number" and bufnr >= 1, "git_conflict.line_status: an explicit buffer handle is required")
  local ns = vim.api.nvim_get_namespaces()["git-conflict"]
  if not ns then
    return {}
  end
  local by_line = {}
  for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, { details = true })) do
    local start_row, details = mark[2], mark[4]
    ---@cast details -? -- always present: we requested details = true
    -- git-conflict paints full-line ranges [start_row, end_row); 0-indexed rows -> 1-indexed lines.
    for lnum = start_row + 1, details.end_row or start_row + 1 do
      by_line[lnum] = details.hl_group
    end
  end
  return by_line
end

return M
