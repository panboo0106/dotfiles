return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    optional = true,
    dependencies = { "codeium.nvim", "saghen/blink.compat" },
    opts = {
      sources = {
        compat = { "codeium" },
        providers = {
          codeium = {
            kind = "Codeium",
            score_offset = 100,
            async = true,
          },
        },
      },
      fuzzy = { implementation = "prefer_rust" },
    },
  },
  {
    "mfussenegger/nvim-dap",
    config = function() end,
  },
}
