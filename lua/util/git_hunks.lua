-- Per-line staged/unstaged git status, read from gitsigns' internal cache
-- (its public get_hunks() only exposes unstaged hunks).

local M = {}

local SUFFIX = { add = "Add", change = "Change", delete = "Delete" }

---Highlight group for a hunk type; staged groups fall back to their unstaged counterpart.
---@param ty "add"|"change"|"delete"
---@param staged boolean
---@return string
function M.hl_group(ty, staged)
  return (staged and "GitSignsStaged" or "GitSigns") .. SUFFIX[ty]
end

---@param by_line table<integer, {type: "add"|"change"|"delete", staged: boolean}>
---@param hunks table[]?
---@param staged boolean
local function collect(by_line, hunks, staged)
  for _, h in ipairs(hunks or {}) do
    local first = math.max(1, h.added.start)
    local last = h.added.count > 0 and h.added.start + h.added.count - 1 or first -- deletes have count 0
    for l = first, last do
      by_line[l] = by_line[l] or { type = h.type, staged = staged } -- first writer wins
    end
  end
end

---Per-line git status for a buffer; unstaged wins where a line is both. Empty when untracked.
---@param bufnr integer explicit buffer handle (>= 1)
---@return table<integer, {type: "add"|"change"|"delete", staged: boolean}>
function M.line_status(bufnr)
  assert(type(bufnr) == "number" and bufnr >= 1, "git_hunks.line_status: an explicit buffer handle is required")
  local ok, cache = pcall(require, "gitsigns.cache")
  local entry = ok and cache.cache and cache.cache[bufnr]
  if not entry then
    return {}
  end
  local by_line = {}
  collect(by_line, entry.hunks, false) -- unstaged first, so it wins ties
  collect(by_line, entry.hunks_staged, true)
  return by_line
end

return M
