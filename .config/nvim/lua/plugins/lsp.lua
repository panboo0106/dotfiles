return {
  -- tools
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "goimports",
        "gofumpt",
        "gomodifytags",
        "delve",
        "impl",
        "stylua",
        "selene",
        "luacheck",
        "shellcheck",
        "shfmt",
        "tailwindcss-language-server",
        "typescript-language-server",
        "css-lsp",
        "prettierd",
        "ruff-lsp",
        "isort",
        "pyright",
        "ruff",
        "black",
      })
    end,
  },
  {
    "nvim-lspconfig",
    opts = {
      servers = {
        typos_lsp = {
          cmd = { "typos-lsp" },
          filetypes = { "*" },
          root_dir = function()
            return vim.fn.getcwd()
          end,
          init_options = {
            config = "~/.config/nvim/typos.toml",
            diagnosticSeverity = "Error",
          },
        },
      },
      inlay_hints = { enabled = false },
    },
  },
}
