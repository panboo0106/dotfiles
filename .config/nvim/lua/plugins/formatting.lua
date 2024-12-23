return {
  "stevearc/conform.nvim",
  optional = true,
  opts = {
    formatters_by_ft = {
      bash = { "shfmt" },
      sh = { "shfmt" },
      lua = { "stylua" },
      go = { "goimports", "gofumpt", "goimports-reviser" },
      javascript = { { "prettier" } },
      typescript = { { "prettier" } },
      javascriptreact = { { "prettier" } },
      typescriptreact = { { "prettier" } },
      vue = { { "prettier" } },
      css = { { "prettier" } },
      scss = { { "prettier" } },
      less = { { "prettier" } },
      html = { { "prettier" } },
      json = { { "prettier" } },
      jsonc = { { "prettier" } },
      yaml = { { "prettier" } },
      markdown = { { "prettier" } },
      ["markdown.mdx"] = { { "prettier" } },
      graphql = { { "prettier" } },
      handlebars = { { "prettier" } },
      rust = { { "rustfmt" } },
      python = function(bufnr)
        if require("conform").get_formatter_info("ruff_format", bufnr).available then
          return { "ruff_format" }
        else
          return { "isort", "black" }
        end
      end,
    },
  },
}
