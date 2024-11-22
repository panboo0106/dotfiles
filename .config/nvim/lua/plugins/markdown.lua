return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.cmd([[Lazy load markdown-preview.nvim]])
      vim.fn["mkdp#util#install"]()
    end,
  },
  -- {
  --   "OXY2DEV/markview.nvim",
  --   lazy = false, -- Recommended
  --   ft = { "markdown", "norg", "rmd", "org", "vimwiki", "Avante" },
  --   opts = {
  --     filetypes = { "markdown", "norg", "rmd", "org", "vimwiki", "Avante" },
  --     buf_ignore = {},
  --     max_length = 99999,
  --   }, -- ft = "markdown" -- If you decide to lazy-load anyway
  --
  --   dependencies = {
  --     "nvim-treesitter/nvim-treesitter",
  --     "nvim-tree/nvim-web-devicons",
  --   },
  -- },
}
