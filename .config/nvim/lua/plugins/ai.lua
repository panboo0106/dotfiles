return {
  {
    "Exafunction/codeium.nvim",
    opts = {},
    config = function()
      require("codeium").setup({})
      vim.g.codeium_enabled = false
    end,
  },
}
