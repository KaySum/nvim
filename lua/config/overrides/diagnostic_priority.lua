-- vim.diagnostic's virtual_text handler has no `priority` option, so its eol
-- extmarks default to 4096 and tie with noice's search count. Wrap the handler
-- to re-stamp them with our priority. See virtual_text_priority.lua.
local M = {}

function M.setup()
  local handler = vim.diagnostic.handlers.virtual_text
  local render = handler.show

  if not render then
    return
  end

  local diagnostic_priority = require("config.overrides.virtual_text_priority").diagnostics

  handler.show = function(namespace, bufnr, diagnostics, opts)
    -- 1. Let the handler place its extmarks as normal (no priority -> 4096).
    render(namespace, bufnr, diagnostics, opts)

    -- Unloaded buffers render later, so skip them (no ns yet).
    if not vim.api.nvim_buf_is_loaded(bufnr) then
      return
    end

    local virt_text_ns = vim.tbl_get(vim.diagnostic.get_namespace(namespace), "user_data", "virt_text_ns")

    if not virt_text_ns then
      vim.notify_once(
        "[diagnostic_priority.lua] patch broke: virt_text_ns not found, "
          .. "likely a Neovim change. Fix the vim.tbl_get path.",
        vim.log.levels.WARN
      )
      return
    end

    -- 2. Read back the extmarks it just placed and 3. overwrite each at the
    -- same id: identical, but now carrying our priority.
    for _, extmark in ipairs(vim.api.nvim_buf_get_extmarks(bufnr, virt_text_ns, 0, -1, { details = true })) do
      local id, row, col, details = unpack(extmark)

      if details then
        vim.api.nvim_buf_set_extmark(bufnr, virt_text_ns, row, col, {
          id = id,
          virt_text = details.virt_text,
          virt_text_pos = details.virt_text_pos,
          hl_mode = details.hl_mode,
          priority = diagnostic_priority,
        })
      end
    end
  end
end

return M
