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
        gopls = {
          settings = {
            gopls = {
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
            },
          },
        },
        ruff = {
          cmd = { "~/.local/share/nvim/mason/bin/ruff", "server", "--preview" },
          filetypes = { "python" },
          root_dir = function()
            return vim.fn.getcwd()
          end,
        },
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
      capabilities = {
        workspace = {
          didChangeWatchedFiles = {
            dynamicRegistration = true,
          },
        },
      },
    },
    keys = {
      {
        "gd",
        function()
          require("telescope.builtin").lsp_definitions({ reuse_win = true })
        end,
        desc = "Goto Definition",
      },
      { "gr", "<cmd>Telescope lsp_references<cr>", desc = "References" },
      {
        "gI",
        function()
          require("telescope.builtin").lsp_implementations({ reuse_win = true })
        end,
        desc = "Goto Implementation",
      },
      {
        "gy",
        function()
          require("telescope.builtin").lsp_type_definitions({ reuse_win = true })
        end,
        desc = "Goto T[y]pe Definition",
      },
    },
  },
}
