local M = {}

local offsets = {}
local names = {}

-- LSP namespaces are named "nvim.lsp.<client>.<id>"; sorting by name is stable
-- across sessions, so each source gets a fixed priority and a fixed eol order.
local function register(name)
  if offsets[name] then
    return offsets[name], false
  end

  table.insert(names, name)
  table.sort(names)

  local shifted = false
  for index, other in ipairs(names) do
    local offset = index - 1
    shifted = shifted or (offsets[other] ~= nil and offsets[other] ~= offset)
    offsets[other] = offset
  end

  return offsets[name], shifted
end

local function restamp(bufnr, virt_text_ns, priority)
  for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(bufnr, virt_text_ns, 0, -1, { details = true })) do
    local id, row, col, details = unpack(mark)

    if details and details.virt_text then
      vim.api.nvim_buf_set_extmark(bufnr, virt_text_ns, row, col, {
        id = id,
        virt_text = details.virt_text,
        virt_text_pos = details.virt_text_pos,
        virt_text_win_col = details.virt_text_win_col,
        virt_text_hide = details.virt_text_hide,
        hl_mode = details.hl_mode,
        priority = priority,
      })
    end
  end
end

local function resync(base_priority)
  for _, ns in pairs(vim.diagnostic.get_namespaces()) do
    local virt_text_ns = vim.tbl_get(ns, "user_data", "virt_text_ns")

    if virt_text_ns then
      local priority = base_priority + (offsets[ns.name or ""] or 0)

      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
          restamp(bufnr, virt_text_ns, priority)
        end
      end
    end
  end
end

function M.setup()
  local handler = vim.diagnostic.handlers.virtual_text
  local render = handler.show

  if not render then
    return
  end

  local base_priority = require("config.overrides.virtual_text_priority").diagnostics

  handler.show = function(namespace, bufnr, diagnostics, opts)
    local name = vim.tbl_get(vim.diagnostic.get_namespace(namespace) or {}, "name") or ""
    local offset, shifted = register(name)
    local priority = base_priority + offset

    -- The handler exposes no priority option, so stamp its eol extmarks as they
    -- are created; re-setting them afterwards reorders sources that share a line.
    local set_extmark = vim.api.nvim_buf_set_extmark
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.api.nvim_buf_set_extmark = function(b, ns, row, col, o)
      if o and o.virt_text then
        o.priority = priority
      end
      return set_extmark(b, ns, row, col, o)
    end

    local ok, err = pcall(render, namespace, bufnr, diagnostics, opts)
    vim.api.nvim_buf_set_extmark = set_extmark

    if not ok then
      error(err)
    end

    if shifted then
      vim.schedule(function()
        resync(base_priority)
      end)
    end
  end
end

return M
