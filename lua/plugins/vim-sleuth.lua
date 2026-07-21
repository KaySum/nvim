return {
  {
    "tpope/vim-sleuth",
    event = {
      "BufReadPost", -- existing file's contents loaded -> scan text for indent style
      "BufNewFile", -- brand-new file -> set up detection for the buffer
      "BufFilePost", -- buffer renamed (:file/:saveas) -> re-detect (new name/extension/dir)
    },
  },
}
