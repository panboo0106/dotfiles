return {
  -- tools
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "golangci-lint",
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
          enabled = true,
          settings = {
            gopls = {
              gofumpt = true,
              codelenses = {
                gc_details = false,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              analyses = {
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
              },
              usePlaceholders = true,
              completeUnimported = true,
              staticcheck = true,
              directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
              semanticTokens = true,
            },
          },
        },
        -- Pyright 作为主要 Python LSP
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic", -- 或 "strict"
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                autoImportCompletions = true,
                diagnosticMode = "openFilesOnly", -- 或 "openFilesOnly"
              },
            },
          },
        },
        -- Jedi 作为补充（可选）
        -- jedi_language_server = {
        --   -- 禁用一些功能以避免与 Pyright 冲突
        --   init_options = {
        --     diagnostics = { enable = false }, -- 禁用诊断
        --     hover = { enable = false }, -- 禁用悬停
        --     completion = { enable = true }, -- 保留补全
        --   },
        -- },
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
    --   keys = {
    --     {
    --       "gd",
    --       function()
    --         require("telescope.builtin").lsp_definitions({ reuse_win = true })
    --       end,
    --       desc = "Goto Definition",
    --     },
    --     { "gr", "<cmd>Telescope lsp_references<cr>", desc = "References" },
    --     {
    --       "gI",
    --       function()
    --         require("telescope.builtin").lsp_implementations({ reuse_win = true })
    --       end,
    --       desc = "Goto Implementation",
    --     },
    --     {
    --       "gy",
    --       function()
    --         require("telescope.builtin").lsp_type_definitions({ reuse_win = true })
    --       end,
    --       desc = "Goto T[y]pe Definition",
    --     },
    --   },
  },
}
