return {
  {
    "tpope/vim-sleuth",
    event = {
      "BufReadPost", -- existing file's contents loaded -> scan text for indent style
      "BufNewFile", -- brand-new file -> set up detection for the buffer
      "BufFilePost", -- buffer renamed (:file/:saveas) -> re-detect (new name/extension/dir)
    },
    -- Track the wrapped-line shift to sleuth's detected shiftwidth (deepIndent).
    init = function()
      vim.api.nvim_create_autocmd("OptionSet", {
        pattern = "shiftwidth",
        callback = function()
          local shift_width = vim.v.option_new
          -- shiftwidth=0 means "follow tabstop", so fall back to it
          if shift_width == 0 then
            shift_width = vim.bo.tabstop
          end
          vim.opt_local.breakindentopt = "shift:" .. vim.g.wrap_indent_multiplier * shift_width
        end,
      })
    end,
  },
}
