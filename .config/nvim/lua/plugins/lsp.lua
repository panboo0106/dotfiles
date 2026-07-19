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

        -- Go
        "golangci-lint",
        "goimports",
        "gofumpt",
        "gomodifytags",
        "delve",
        "impl",

        -- Debug adapters (previously only reachable via coding.lua's deleted nvim-dap block)
        "debugpy",
        "java-debug-adapter",
        "java-test",
        "jdtls",

        -- Python
        "ruff",
        "pyright", -- Python 类型检查 LSP
        "vulture", -- 死代码检测工具（可选）
        "isort",
        "black",

        -- JavaScript/TypeScript (新增)
        -- typescript-language-server 已移除：ts_ls 永不启用，vtsls（vue/typescript extras）全面接管
        "eslint-lsp",
        "prettierd",
        "css-lsp",
        "vue-language-server",

        -- Shell (已有)
        "shellcheck",
        "shfmt",

        -- C/C++
        "clangd", -- Clang LSP（包含 clang-tidy 功能）
        -- 注意：clang-format 需要手动安装

        -- Rust
        "rust-analyzer",
        "codelldb", -- Rust debugger

        -- Java Linter
        "checkstyle",

        -- Shell LSP
        "bash-language-server",

        -- JavaScript/TypeScript debugger
        "js-debug-adapter",

        -- 格式化工具
        "sql-formatter",
        "buf",
        "taplo",

        -- 其他
        "typos-lsp",
        "markdownlint-cli2",
        "markdown-toc",
        "markdown-oxide", -- Obsidian wikilink LSP（跳转/反链/补全）
        "yamlfmt",
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
            [vim.diagnostic.severity.WARN]  = LazyVim.config.icons.diagnostics.Warn,
            [vim.diagnostic.severity.HINT]  = LazyVim.config.icons.diagnostics.Hint,
            [vim.diagnostic.severity.INFO]  = LazyVim.config.icons.diagnostics.Info,
          },
        },
      },

      inlay_hints = {
        enabled = true,
        exclude = { "vue" },
      },

      codelens = { enabled = true },

      folds = { enabled = false }, -- nvim-ufo 接管折叠

      ---@type table<string, lazyvim.lsp.Config|boolean>
      servers = {
        jdtls = false,

        -- 用 markdown-oxide 取代 marksman：原生支持 Obsidian [[wikilink]] 跳转/反链/补全
        marksman = false,
        markdown_oxide = {
          capabilities = {
            workspace = {
              didChangeWatchedFiles = { dynamicRegistration = true },
            },
          },
        },

        -- ============ JavaScript/TypeScript ============
        -- eslint: handled by extras.linting.eslint (registers LazyVim formatter, unlike the old inert `format=true`)
        -- ts_ls: dead code removed — lang.vue → lang.typescript extra forces vtsls, ts_ls.enabled=false always

        -- ============ C/C++ ============
        -- clangd: base config from extras.lang.clangd; only --header-insertion differs from its default (iwyu)
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=never",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
          },
        },

        -- ============ Shell ============
        bashls = {
          settings = {
            bashIde = {
              globPattern = "*@(.sh|.inc|.bash|.command)",
            },
          },
        },

        -- ============ Rust (managed by rustaceanvim) ============
        -- rust_analyzer disable now comes from extras.lang.rust

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

        -- gopls: config now comes entirely from extras.lang.go (identical settings + the
        -- semanticTokensProvider workaround the hand-copied version was missing)

        -- ============ Python ============
        -- Pyright 配置（只负责类型检查，linting 交给 Ruff）
        pyright = {
          on_new_config = function(new_config, new_root_dir)
            local venv = new_root_dir .. "/.venv"
            if vim.fn.isdirectory(venv) == 1 then
              new_config.settings.python.pythonPath = venv .. "/bin/python"
            end
          end,
          settings = {
            pyright = {
              -- 禁用 import 整理，由 Ruff 负责
              disableOrganizeImports = true,
            },
            python = {
              analysis = {
                autoSearchPaths = true,
                -- 只分析当前打开的文件，减少后台分析压力
                diagnosticMode = "openFilesOnly",
                useLibraryCodeForTypes = true,
                typeCheckingMode = "basic",
                -- 关闭与 Ruff 重叠的 lint 规则，只保留类型检查
                diagnosticSeverityOverrides = {
                  reportUnusedImport = "none",
                  reportUnusedVariable = "none",
                  reportUnusedParameter = "none",
                  reportUnusedCallResult = "none",
                },
              },
            },
          },
        },

        -- ruff server 配置完全由 extras.lang.python 提供（正确的 ruff server schema）。
        -- 自定义规则在 ~/.config/ruff/ruff.toml，ruff server 自动读取，无需在此重复。
        -- （原 ruff-lsp schema organizeImports/fixAll/codeAction 在 ruff server 上是 no-op，已删。）

        typos_lsp = {
          enabled = true,
          -- init_options 必须是 table（neovim 不会调用函数值的 init_options）；
          -- 用 IIFE 在配置期求值，typos.toml 才会真正发给 server。
          init_options = (function()
            local typos_config = vim.fn.expand("~/.config/nvim/typos.toml")
            if vim.fn.filereadable(typos_config) ~= 1 then
              vim.notify("typos.toml not found, using default rules", vim.log.levels.WARN)
            end
            return {
              config = typos_config,
              diagnosticSeverity = "Info",
            }
          end)(),
        },
      },

      ---@type table<string, fun(server:string, opts:vim.lsp.Config):boolean?>
      setup = {},
    },
  },
}
