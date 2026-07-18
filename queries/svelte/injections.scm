; inherits: html_tags

; This is a full copy of the upstream svelte injections query, overriding it so
; `lang="postcss"` <style> blocks are parsed by the *css* grammar instead of scss.
; The scss grammar can't parse Tailwind's `@apply` (it produces ERROR nodes, giving
; inconsistent colors); the css grammar parses it cleanly as a `postcss_statement`
; with each utility class as a uniform `plain_value`.
;
; Because this file lives in ~/.config/nvim/queries (front of runtimepath) and has
; no `; extends` modeline, it replaces nvim-treesitter's bundled svelte injections.
; The `css`/`scss` parsers must be installed (see lua/plugins/treesitter.lua).

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
