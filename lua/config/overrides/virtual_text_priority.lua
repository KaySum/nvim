-- Priorities for end-of-line virtual text; `sources` order is the left→right
-- layout. Everything is placed relative to search_count, which noice pins to
-- 4096: sources listed before it render to its left, after it to its right.
local sources = {
  "search_count", -- noice (fixed at ANCHOR_PRIORITY; can't be moved)
  "git_blame", -- gitsigns, via its virt_text_priority option
  "diagnostics", -- applied by a handler wrapper in plugins/lspconfig.lua (no native priority option)
}

local ANCHOR = "search_count" -- folke/noice.nvim's "/" search count [i/n] overlay
local ANCHOR_PRIORITY = 4096 -- NOTE: Noice does not expose a way to change this, so instead everything is relative to this fixed value

local gap = 10
local anchor_index

for index, source in ipairs(sources) do
  if source == ANCHOR then
    anchor_index = index
    break
  end
end

local priorities = {}
for index, source in ipairs(sources) do
  priorities[source] = ANCHOR_PRIORITY + (index - anchor_index) * gap
end

return priorities
