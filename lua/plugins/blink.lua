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
  },
}
