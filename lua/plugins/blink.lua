local disabled_filetypes = { "text", "markdown", "oil" }

return {
  "saghen/blink.cmp",
  opts = {
    enabled = function()
      return not vim.tbl_contains(disabled_filetypes, vim.bo.filetype)
    end,
    completion = {
      list = { selection = { preselect = false, auto_insert = false } },
    },
    sources = {
      providers = {
        snippets = { enabled = false },
        lsp = {
          transform_items = function(_, items)
            local snippet = require("blink.cmp.types").CompletionItemKind.Snippet
            return vim.tbl_filter(function(item)
              return item.kind ~= snippet
            end, items)
          end,
        },
      },
    },
  },
}
