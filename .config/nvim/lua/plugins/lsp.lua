return {
  -- tools
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts_extend = { "ensure_installed" },
    opts = {
      ensure_installed = {
        "stylua",
        "golangci-lint",
        "goimports",
        "gofumpt",
        "gomodifytags",
        "delve",
        "impl",
        "luacheck",
        "shellcheck",
        "shfmt",
        "typescript-language-server",
        "css-lsp",
        "prettierd",
        "isort",
        "pyright",
        "ruff",
        "black",
        "typos-lsp",
        "markdownlint-cli2",
        "markdown-toc",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    event = "LazyFile",
    dependencies = {
      "mason.nvim",
      { "mason-org/mason-lspconfig.nvim", config = function() end },
    },

    opts = {
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = LazyVim.config.icons.diagnostics.Error,
            [vim.diagnostic.severity.WARN] = LazyVim.config.icons.diagnostics.Warn,
            [vim.diagnostic.severity.HINT] = LazyVim.config.icons.diagnostics.Hint,
            [vim.diagnostic.severity.INFO] = LazyVim.config.icons.diagnostics.Info,
          },
        },
      },

      inlay_hints = {
        enabled = true,
        exclude = { "vue" },
      },

      codelens = { enabled = false },

      folds = { enabled = true },

      format = {
        formatting_options = nil,
        timeout_ms = nil,
      },

      ---@type table<string, lazyvim.lsp.Config|boolean>
      servers = {
        marksman = {},
        stylua = { enabled = false },

        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              codeLens = { enable = true },
              completion = { callSnippet = "Replace" },
              doc = { privateName = { "^_" } },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
            },
          },
        },

        gopls = {
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

        -- 如需 pyright，取消注释即可
        -- pyright = { ... },
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

        ruff = {
          cmd = { "ruff", "server", "--preview" },
          filetypes = { "python" },
          root_dir = function()
            return vim.fn.getcwd()
          end,
        },

        typos_lsp = {
          enabled = true,
          init_options = {
            config = "~/.config/nvim/typos.toml",
            diagnosticSeverity = "Info",
          },
        },
      },

      ---@type table<string, fun(server:string, opts:vim.lsp.Config):boolean?>
      setup = {},
    },
  },
}
