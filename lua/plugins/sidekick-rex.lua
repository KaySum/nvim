-- Inside Rex, sidekick runs agent CLIs in Rex splits (see lua/rex/sidekick.lua).
if not require("rex").enabled then
  return {}
end

local function rex(fn)
  return function()
    require("rex.sidekick")[fn]()
  end
end

return {
  {
    "folke/sidekick.nvim",
    config = function(_, opts)
      require("sidekick").setup(opts)
      require("rex.sidekick").setup()
    end,
    keys = {
      { "<c-.>", rex("focus"), desc = "Sidekick Focus", mode = { "n", "t", "i", "x" } },
      { "<leader>aa", rex("toggle"), desc = "Sidekick Toggle CLI" },
      { "<leader>as", rex("select"), desc = "Select CLI" },
      { "<leader>ad", rex("close"), desc = "Detach a CLI Session" },
    },
  },
}
