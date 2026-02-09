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
        -- Lua
        "stylua",
        "luacheck",

        -- Go
        "golangci-lint",
        "goimports",
        "gofumpt",
        "gomodifytags",
        "delve",
        "impl",

        -- Python
        "ruff",
        "pyright", -- Python 类型检查 LSP
        "vulture", -- 死代码检测工具（可选）
        "isort",
        "black",

        -- JavaScript/TypeScript (新增)
        "eslint-lsp",
        "prettierd",
        "typescript-language-server",
        "css-lsp",
        "vue-language-server",

        -- Shell (已有)
        "shellcheck",
        "shfmt",

        -- C/C++
        "clangd", -- Clang LSP（包含 clang-tidy 功能）
        -- 注意：clang-format 需要手动安装

        -- Java Linter
        "checkstyle",

        -- 其他
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
        jdtls = false,

        marksman = {},
        stylua = { enabled = false },

        -- ============ JavaScript/TypeScript ============
        eslint = {
          settings = {
            validate = "on",
            packageManager = "npm",
            codeActionOnSave = {
              enable = true,
              mode = "all",
            },
            format = true,
            nodePath = "",
            rules = {},
            workingDirectory = { mode = "location" },
            useESLintClass = true,
            experimental = {
              useFlatConfig = true,
            },
          },
        },

        ts_ls = {
          settings = {
            typescript = {
              format = {
                enable = true,
              },
            },
          },
        },

        -- ============ C/C++ ============
        clangd = {
          keys = {
            { "<leader>cR", "<cmd>ClangdReset<cr>", desc = "Clangd Reset" },
          },
          settings = {
            clangd = {
              -- 使用已创建的 .clang-tidy 配置
              arguments = {
                "--config-file=" .. vim.fn.stdpath("config") .. "/.clang-tidy",
                "--header-insertion=never",
                "--completion-style=detailed",
                "--background-index",
                "--clang-tidy",
              },
              -- 使用已创建的 .clang-format 配置
              fallback_flags = {
                "--style=file:" .. vim.fn.stdpath("config") .. "/.clang-format",
              },
            },
          },
        },

        -- ============ Shell ============
        -- Shell 没有 LSP，只使用 linter 和 formatter

        -- ============ Lua ============
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

        -- ============ Python ============
        -- Pyright 配置（类型检查）
        pyright = {
          settings = {
            python = {
              analysis = {
                autoSearchPaths = true,
                diagnosticMode = "workspace",
                useLibraryCodeForTypes = true,
                typeCheckingMode = "basic", -- 或 "strict"
                -- Pyright 只能检测变量和参数，不能检测未使用函数
                diagnosticSeverityOverrides = {
                  reportUnusedVariable = "warning",
                  reportUnusedImport = "warning",
                  reportUnusedParameter = "warning",
                  reportUnusedCallResult = "warning",
                  -- 注意：Pyright 没有 reportUnusedFunction 选项
                },
              },
            },
          },
        },

        -- Ruff 配置（代码质量、格式化 + 未使用函数检测）
        ruff = {
          -- 禁用一些功能，避免与 pyright 冲突
          on_attach = function(client, bufnr)
            -- 禁用 hover，避免与 pyright 冲突
            if client.server_capabilities then
              client.server_capabilities.hoverProvider = false
            end
          end,
          -- 使用 ~/.config/nvim/ruff.toml 中的自定义规则
          -- Ruff 通过规则检测未使用函数（如 PLR0913, F841 等）
          settings = {
            -- 组织导入（自动排序和删除未使用的导入）
            organizeImports = true,
            -- 修复所有可自动修复的问题
            fixAll = true,
            -- Ruff LSP 特定设置
            logLevel = "error",
            -- 代码行动配置
            codeAction = {
              disableRuleCommentWithExplanation = {
                enable = true,
              },
              fixViolation = {
                enable = true,
              },
            },
          },
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
