return {
	{
		"folke/tokyonight.nvim",
		priority = 1000, -- load before anything that defines highlights
		opts = { style = "moon" },
		config = function(_, opts)
			require("tokyonight").setup(opts)
			vim.cmd.colorscheme("tokyonight")
		end,
	},
}
