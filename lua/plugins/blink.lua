local disabled_filetypes = { "text", "markdown", "oil" }

return {
  "saghen/blink.cmp",
  opts = {
    -- Tab accepts the highlighted completion (VS Code style) and jumps
    -- through snippet placeholders; falls back to normal Tab otherwise.
    -- Enter also accepts when a completion is visible, falling back to a
    -- normal newline otherwise.
    keymap = {
      preset = "super-tab",
      ["<CR>"] = { "accept", "fallback" },
    },
    enabled = function()
      return not vim.tbl_contains(disabled_filetypes, vim.bo.filetype)
    end,
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
