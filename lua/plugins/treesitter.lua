-- Treesitter tweaks for Svelte + Tailwind v4.
--
-- 1. Ensure the `css`/`scss` parsers are installed. The Svelte injection query maps
--    `<style lang="scss|less">` blocks to the scss parser, so both are needed.
--    LazyVim sets `opts_extend = { "ensure_installed" }`, so this appends to defaults.
--
-- 2. The Svelte `injections` query is overridden in `queries/svelte/injections.scm`
--    (front of runtimepath) so `lang="postcss"` blocks parse with the *css* grammar
--    instead of scss — see that file for the rationale.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "css", "scss" } },
  },
}
