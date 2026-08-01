-- Per-line git conflict regions, parsed straight from the buffer's conflict
-- markers (git-conflict.nvim keeps its own positions private, and the markers
-- are the source of truth anyway).

local M = {}

---@alias ConflictSide "current"|"ancestor"|"incoming"

---Per-line conflict side for a buffer; empty when there are no conflict markers.
---A stray marker outside a started conflict is ignored (side stays nil).
---@param bufnr integer explicit buffer handle (>= 1)
---@return table<integer, ConflictSide> -- 1-indexed line -> side
function M.line_status(bufnr)
  assert(type(bufnr) == "number" and bufnr >= 1, "git_conflict.line_status: an explicit buffer handle is required")
  local by_line = {}
  local side ---@type ConflictSide? non-nil while inside a conflict
  for lnum, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    if line:match("^<<<<<<<") then
      side = "current"
    elseif side and line:match("^|||||||") then
      side = "ancestor"
    elseif side and line:match("^=======") then
      side = "incoming"
    elseif side and line:match("^>>>>>>>") then
      by_line[lnum] = side
      side = nil
    end
    if side then
      by_line[lnum] = side
    end
  end
  return by_line
end

return M
