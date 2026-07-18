-- Treesitter tweaks for Svelte + Tailwind v4.
--
-- 1. Ensure the `css`/`scss` parsers are installed. The Svelte injection query maps
--    `<style lang="scss|postcss|less">` blocks to the scss parser, so both are needed.
--    LazyVim sets `opts_extend = { "ensure_installed" }`, so this appends to defaults.
--
-- 2. Override the Svelte `injections` query so `lang="postcss"` blocks are parsed by the
--    *css* grammar instead of scss. The scss grammar can't parse Tailwind's `@apply`
--    (it produces ERROR nodes, giving inconsistent colors); the css grammar parses it
--    cleanly as a `postcss_statement` with each utility class as a uniform `plain_value`.
--    This is a full copy of the upstream svelte injections query with the postcss branch
--    split out to `css`. `init` runs before the first buffer is parsed, so the override
--    is in place in time.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "css", "scss" } },
    init = function()
      vim.treesitter.query.set(
        "svelte",
        "injections",
        [[
; inherits: html_tags

((style_element
  (start_tag
    (attribute
      (attribute_name) @_attr
      (quoted_attribute_value
        (attribute_value) @_lang)))
  (raw_text) @injection.content)
  (#eq? @_attr "lang")
  (#eq? @_lang "postcss")
  (#set! injection.language "css"))

((style_element
  (start_tag
    (attribute
      (attribute_name) @_attr
      (quoted_attribute_value
        (attribute_value) @_lang)))
  (raw_text) @injection.content)
  (#eq? @_attr "lang")
  (#any-of? @_lang "scss" "less")
  (#set! injection.language "scss"))

((svelte_raw_text) @injection.content
  (#set! injection.language "javascript"))

((script_element
  (start_tag
    (attribute
      (attribute_name) @_attr
      (quoted_attribute_value
        (attribute_value) @_lang)))
  (raw_text) @injection.content)
  (#eq? @_attr "lang")
  (#any-of? @_lang "ts" "typescript")
  (#set! injection.language "typescript"))

((script_element
  (start_tag
    (attribute
      (attribute_name) @_attr
      (quoted_attribute_value
        (attribute_value) @_lang)))
  (raw_text) @injection.content)
  (#eq? @_attr "lang")
  (#any-of? @_lang "js" "javascript")
  (#set! injection.language "javascript"))
]]
      )
    end,
  },
}
