return {
  {
    "neovim/nvim-lspconfig",
    init = function()
      -- vim.diagnostic's virtual_text handler has no `priority` option, so re-stamp
      -- its eol extmarks after rendering. See config/overrides/virtual_text_priority.lua.
      local handler = vim.diagnostic.handlers.virtual_text
      local render = handler.show

      if not render then
        return
      end

      local priority = require("config.overrides.virtual_text_priority").diagnostics

      handler.show = function(namespace, bufnr, diagnostics, opts)
        render(namespace, bufnr, diagnostics, opts)

        local virt_text_ns = vim.tbl_get(vim.diagnostic.get_namespace(namespace), "user_data", "virt_text_ns")

        if not virt_text_ns or not vim.api.nvim_buf_is_loaded(bufnr) then
          return
        end

        for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(bufnr, virt_text_ns, 0, -1, { details = true })) do
          local id, row, col, details = unpack(mark)
          -- Re-set the mark with all its details (ns_id is read-only) so nothing is dropped.
          details.id, details.ns_id, details.priority = id, nil, priority
          vim.api.nvim_buf_set_extmark(bufnr, virt_text_ns, row, col, details)
        end
      end
    end,
  },
}
