return {
  {
    "linux-cultist/venv-selector.nvim",
    branch = "regexp",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-telescope/telescope.nvim",
      "mfussenegger/nvim-dap-python",
    },
    opts = {
      name = { "venv", ".venv", "env", ".env" },
      search_venv_managers = true,
      search_workspace = true,
      auto_refresh = true,
    },
    config = function()
      require("venv-selector").setup({
        settings = {
          search = {
            anaconda_base = {
              command = "fd /python$ /Users/leo/anaconda3/bin --full-path --color never -E /proc",
              type = "anaconda",
            },
            anaconda_envs = {
              command = "fd /python$ /Users/leo/anaconda3/envs --full-path --color never -E /proc",
              type = "anaconda",
            },
          },
        },
      })
      -- 在 LspAttach 事件中设置键映射
      local wk = require("which-key")
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)

          -- 检查是否是 Python LSP 和 Python 文件类型
          if client and (client.name == "pyright" or client.name == "pylsp") then
            wk.add({
              { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv" },
            }, { buffer = bufnr })
          end
        end,
      })
    end,
  },
  -- {
  --   "ray-x/go.nvim",
  --   dependencies = { -- optional packages
  --     "ray-x/guihua.lua",
  --     "neovim/nvim-lspconfig",
  --     "nvim-treesitter/nvim-treesitter",
  --   },
  --   config = function()
  --     require("go").setup()
  --   end,
  --   event = { "CmdlineEnter" },
  --   ft = { "go", "gomod" },
  --   build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
  -- },
  {
    "mfussenegger/nvim-jdtls",
    dependencies = {
      "folke/which-key.nvim",
    },
    ft = { "java" },
    config = function()
      local jdtls = require("jdtls")
      local jdtls_setup = require("jdtls.setup")
      local home = os.getenv("HOME")

      -- JDTLS 自动启动函数
      local jdtls_start = function()
        -- 找到项目根目录
        local function find_java_project_root()
          -- 优先查找构建工具的包装脚本（通常在真正的项目根目录）
          local wrapper_markers = { "gradlew", "mvnw" }
          local wrapper_root = jdtls_setup.find_root(wrapper_markers)
          if wrapper_root then
            return wrapper_root
          end

          -- 然后查找 Git 仓库根目录
          local git_root = jdtls_setup.find_root({ ".git" })
          if git_root then
            -- 检查 Git 根目录是否包含构建文件
            local build_files = { "pom.xml", "build.gradle", "build.gradle.kts", "settings.gradle" }
            for _, file in ipairs(build_files) do
              if vim.fn.filereadable(git_root .. "/" .. file) == 1 then
                return git_root
              end
            end
          end

          -- 最后查找最近的构建文件
          local build_root = jdtls_setup.find_root({ "pom.xml", "build.gradle", "build.gradle.kts" })
          return build_root or vim.fn.getcwd()
        end

        local root_dir = find_java_project_root()
        local root_markers = { "gradlew", "mvnw", ".git", "pom.xml", "build.gradle" }
        -- local root_dir = jdtls_setup.find_root(root_markers)
        if root_dir == "" then
          root_dir = vim.fn.getcwd()
        end

        -- 工作空间目录
        local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
        local workspace_dir = home .. "/.cache/jdtls/workspace/" .. project_name

        -- JDTLS配置路径
        local jdtls_install_dir = home .. "/.local/share/nvim/mason/packages/jdtls"
        local config_dir = jdtls_install_dir .. "/config_linux" -- 根据你的系统修改为 config_mac 或 config_win
        local launcher_jar = vim.fn.glob(jdtls_install_dir .. "/plugins/org.eclipse.equinox.launcher_*.jar")
        local lombok_jar = jdtls_install_dir .. "/lombok.jar"

        -- 设置 Java Debug Adapter 路径
        local java_debug_path = vim.fn.expand("~/.local/share/nvim/mason/packages/java-debug-adapter")
        local java_test_path = home .. "/.local/share/nvim/mason/packages/java-test"

        -- 收集所有调试和测试 bundle JAR 文件
        local bundles = {}

        -- 添加 Java Debug JAR
        local java_debug_bundle =
          vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", true)
        if java_debug_bundle ~= "" then
          table.insert(bundles, java_debug_bundle)
        end

        -- 添加 Java Test JAR 文件
        local java_test_bundles = vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar", true), "\n")
        for _, bundle in ipairs(java_test_bundles) do
          if bundle ~= "" then
            table.insert(bundles, bundle)
          end
        end

        local capabilities = {
          textDocument = {
            foldingRange = {
              dynamicRegistration = false,
              lineFoldingOnly = true,
            },
          },
        }

        -- Java语言服务器配置项
        local config = {
          cmd = {
            "java",
            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "-Dosgi.bundles.defaultStartLevel=4",
            "-Declipse.product=org.eclipse.jdt.ls.core.product",
            "-Dlog.protocol=true",
            "-Dlog.level=ALL",
            "-Xms1g",
            "--add-modules=ALL-SYSTEM",
            "--add-opens",
            "java.base/java.util=ALL-UNNAMED",
            "--add-opens",
            "java.base/java.lang=ALL-UNNAMED",
            "-javaagent:" .. lombok_jar,
            "-jar",
            launcher_jar,
            "-configuration",
            config_dir,
            "-data",
            workspace_dir,
          },

          root_dir = root_dir,
          settings = {
            java = {
              home = os.getenv("JAVA_HOME"),
              eclipse = {
                downloadSources = true,
              },
              compile = {
                nullAnalysis = { mode = "automatic" },
              },
              configuration = {
                updateBuildConfiguration = "automatic",
                runtimes = {
                  {
                    name = "JavaSE-17",
                    path = os.getenv("JAVA_HOME"),
                  },
                },
              },
              sources = {
                organizeImports = {
                  starThreshold = 9999,
                  staticStarThreshold = 9999,
                  staticImportsAfterNonStatic = true,
                },
              },
              maven = {
                downloadSources = true,
                updateSnapshots = false,
              },
              implementationsCodeLens = {
                enabled = true,
              },
              referencesCodeLens = {
                enabled = true,
              },
              references = {
                includeDecompiledSources = true,
              },
              inlayHints = {
                parameterNames = {
                  enabled = "all",
                },
              },
              format = {
                enabled = true,
                settings = {
                  url = "~/.config/nvim/eclipse-formatter.xml",
                },
              },
              saveActions = { -- 添加：保存时操作
                organizeImports = true,
                format = true,
              },
              cleanup = { -- 添加：代码清理
                actionsOnSave = {
                  "qualifyMembers",
                  "addOverride",
                },
              },
              autobuild = { -- 添加：自动构建
                enabled = true,
              },
              import = {
                enabled = true,
                order = {
                  "java",
                  "com",
                  "org",
                  "#", -- 其他非静态导入
                  "", -- 空字符串表示静态导入与非静态导入的分隔点
                },
                separate = false,
                staticAfterInstance = true,
              },
              completion = {
                importOrder = {
                  "java",
                  "javax",
                  "com",
                  "org",
                },
                enabled = true,
                guessMethodArguments = true,
                favoriteStaticMembers = {
                  "org.hamcrest.MatcherAssert.assertThat",
                  "org.hamcrest.Matchers.*",
                  "org.junit.Assert.*",
                  "org.junit.Assume.*",
                  "org.junit.jupiter.api.Assertions.*",
                  "org.junit.jupiter.api.Assumptions.*",
                  "org.junit.jupiter.api.DynamicTest.*",
                  "org.mockito.Mockito.*",
                },
              },
            },
            signatureHelp = { enabled = true },
            contentProvider = { preferred = "fernflower" },
            extendedClientCapabilities = jdtls_setup.extendedClientCapabilities,
            codeGeneration = {
              toString = {
                template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
              },
              generateComments = true,
              useBlocks = true,
            },
          },

          flags = {
            allow_incremental_sync = true,
          },

          -- 初始化选项
          init_options = {
            bundles = bundles,
          },
          -- LazyVim集成: 添加capabilities
          capabilities = require("blink.cmp").get_lsp_capabilities(capabilities),
          -- 按键映射和其他附加功能
          on_attach = function(client, bufnr)
            -- 添加代码操作和调试支持
            local opts = { noremap = true, silent = true, buffer = bufnr }

            require("which-key").add({
              { "<leader>j", group = "Java", icon = "??" },
              {
                "<leader>jo",
                "<cmd>lua require('jdtls').organize_imports()<cr>",
                desc = "Organize Imports",
                icon = { color = "orange", icon = "??" },
              },
              {
                "<leader>jv",
                "<cmd>lua require('jdtls').extract_variable()<cr>",
                desc = "Extract Variable",
                icon = { color = "blue", icon = "??" },
              },
              {
                "<leader>jc",
                "<cmd>lua require('jdtls').extract_constant()<cr>",
                desc = "Extract Constant",
                icon = { color = "purple", icon = "??" },
              },
              {
                "<leader>jm",
                "<cmd>lua require('jdtls').extract_method()<cr>",
                desc = "Extract Method",
                icon = { color = "cyan", icon = "??" },
              },
              {
                "<leader>jt",
                "<cmd>lua require('jdtls').test_class()<cr>",
                desc = "Test Class",
                icon = { color = "green", icon = "??" },
              },
              {
                "<leader>jn",
                "<cmd>lua require('jdtls').test_nearest_method()<cr>",
                desc = "Test Nearest Method",
                icon = { color = "green", icon = "??" },
              },
              {
                "<leader>jd",
                "<cmd>lua require('jdtls').goto_definition()<cr>",
                desc = "Goto Definition (Java Enhanced)",
                icon = { color = "yellow", icon = "??" },
              },
              {
                "<leader>cA",
                "<cmd>lua require('jdtls').code_action()<cr>",
                desc = "Java Code Action",
                icon = { color = "red", icon = "??" },
              },
            }, { buffer = bufnr })
            -- DAP配置（如果安装了nvim-dap）
            -- if vim.fn.exists("nvim-dap") ~= 0 then
            --   -- 在这里添加DAP相关配置
            --   local dap = require("dap")

            -- 添加Java调试配置
            -- ...
            -- end
          end,
        }

        -- 启动JDTLS
        jdtls.start_or_attach(config)
      end

      -- 创建自动命令，在打开Java文件时自动启动JDTLS
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = jdtls_start,
      })
    end,
  },
  -- go.nvim 主配置
  -- {
  --   "ray-x/go.nvim",
  --   dependencies = {
  --     "ray-x/guihua.lua", -- 提供浮动窗口支持
  --     "neovim/nvim-lspconfig",
  --     "nvim-treesitter/nvim-treesitter",
  --   },
  --   config = function()
  --     require("go").setup({
  --       -- 基本配置
  --       go = "go", -- go 命令路径
  --       goimports = "gopls", -- 使用 gopls 进行 import 管理
  --       gofmt = "gofumpt", -- 使用 gofumpt 进行格式化
  --
  --       -- LSP 配置
  --       lsp_cfg = true, -- 让 go.nvim 管理 gopls 配置
  --       lsp_gofumpt = true, -- 启用 gofumpt
  --       lsp_on_attach = true, -- 使用 go.nvim 的 on_attach
  --
  --       -- 诊断配置
  --       lsp_diag_hdlr = true, -- 使用 go.nvim 的诊断处理器
  --       lsp_diag_underline = true,
  --       lsp_diag_virtual_text = { space = 0, prefix = "■" },
  --       lsp_diag_signs = true,
  --       lsp_diag_update_in_insert = false,
  --       lsp_keymaps = false,
  --       -- 代码操作
  --       lsp_document_formatting = true,
  --       lsp_inlay_hints = {
  --         enable = true,
  --         -- 只在 Normal 模式显示 inlay hints
  --         only_current_line = false,
  --         -- 显示的 hint 类型
  --         show_variable_name = true,
  --         show_parameter_hints = true,
  --         show_other_hints = true,
  --         max_len_align = false,
  --         max_len_align_padding = 1,
  --         right_align = false,
  --         right_align_padding = 7,
  --         highlight = "Comment",
  --       },
  --
  --       -- gopls 特定设置
  --       gopls_cmd = nil, -- 使用默认的 gopls
  --       gopls_remote_auto = true,
  --
  --       -- 分析器配置（包括 shadow）
  --       gopls_settings = {
  --         analyses = {
  --           shadow = true, -- 启用变量遮蔽检查
  --           unusedparams = true,
  --           unusedwrite = true,
  --           nilness = true,
  --           useany = true,
  --         },
  --         staticcheck = true,
  --         gofumpt = true,
  --         hints = {
  --           assignVariableTypes = true,
  --           compositeLiteralFields = true,
  --           compositeLiteralTypes = true,
  --           constantValues = true,
  --           functionTypeParameters = true,
  --           parameterNames = true,
  --           rangeVariableTypes = true,
  --         },
  --         codelenses = {
  --           gc_details = false,
  --           generate = true,
  --           regenerate_cgo = true,
  --           run_govulncheck = true,
  --           test = true,
  --           tidy = true,
  --           upgrade_dependency = true,
  --           vendor = true,
  --         },
  --         usePlaceholders = true,
  --         completeUnimported = true,
  --         directoryFilters = {
  --           "-.git",
  --           "-.vscode",
  --           "-.idea",
  --           "-.vscode-test",
  --           "-node_modules",
  --         },
  --         semanticTokens = true,
  --       },
  --
  --       -- Treesitter 配置
  --       luasnip = true, -- 启用 go.nvim 的 luasnip 集成
  --
  --       -- 测试配置
  --       test_runner = "go", -- 默认测试运行器
  --       run_in_floaterm = false, -- 在终端中运行，而不是浮动终端
  --
  --       -- 调试配置
  --       dap_debug = true,
  --       dap_debug_gui = true,
  --       dap_debug_keymap = true, -- 设置调试快捷键
  --
  --       -- 构建标签检测
  --       build_tags = "", -- 可以设置特定的构建标签
  --       textobjects = true, -- 启用 Go 特定的文本对象
  --
  --       -- 图标配置
  --       icons = {
  --         breakpoint = "🔴",
  --         currentpos = "🔶",
  --       },
  --
  --       -- 浮动窗口配置
  --       floaterm = {
  --         posititon = "auto", -- 或 'top', 'bottom', 'left', 'right', 'center', 'auto'
  --         width = 0.45,
  --         height = 0.98,
  --       },
  --
  --       -- 自动命令
  --       trouble = false, -- 如果你使用 trouble.nvim，设置为 true
  --       test_efm = false, -- 使用错误格式
  --     })
  --
  --     -- 自动命令：保存时格式化和组织导入
  --     local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
  --     vim.api.nvim_create_autocmd("BufWritePre", {
  --       pattern = "*.go",
  --       callback = function()
  --         require("go.format").goimports()
  --       end,
  --       group = format_sync_grp,
  --     })
  --   end,
  --   event = { "CmdlineEnter" },
  --   ft = { "go", "gomod" },
  --   build = ':lua require("go.install").update_all_sync()', -- 自动安装/更新 Go 工具
  --
  --   -- 键映射配置 - 完全避免与 LazyVim 默认键映射冲突
  --   keys = {
  --     -- 构建和运行
  --     { "<leader>cgb", "<cmd>GoBuild<cr>", desc = "Build", ft = "go" },
  --     { "<leader>cgr", "<cmd>GoRun<cr>", desc = "Run", ft = "go" },
  --     { "<leader>cgR", "<cmd>GoRun %<cr>", desc = "Run Current File", ft = "go" },
  --
  --     -- 测试相关
  --     { "<leader>cgt", "<cmd>GoTest<cr>", desc = "Test Package", ft = "go" },
  --     { "<leader>cgT", "<cmd>GoTestFunc<cr>", desc = "Test Function", ft = "go" },
  --     { "<leader>cgc", "<cmd>GoCoverage<cr>", desc = "Test Coverage", ft = "go" },
  --     { "<leader>cgtf", "<cmd>GoTestFile<cr>", desc = "Test File", ft = "go" },
  --     { "<leader>cgta", "<cmd>GoTestAll<cr>", desc = "Test All", ft = "go" },
  --
  --     -- 代码生成和修复
  --     { "<leader>cgfs", "<cmd>GoFillStruct<cr>", desc = "Fill Struct", ft = "go" },
  --     { "<leader>cgfw", "<cmd>GoFillSwitch<cr>", desc = "Fill Switch", ft = "go" },
  --     { "<leader>cgie", "<cmd>GoIfErr<cr>", desc = "Add If Err", ft = "go" },
  --     { "<leader>cgii", "<cmd>GoImpl<cr>", desc = "Implement Interface", ft = "go" },
  --     { "<leader>cgig", "<cmd>GoGenerate<cr>", desc = "Go Generate", ft = "go" },
  --
  --     -- 代码操作和重构
  --     { "<leader>cgn", "<cmd>GoRename<cr>", desc = "Go Rename", ft = "go" },
  --     { "<leader>cge", "<cmd>GoExtract<cr>", desc = "Extract", ft = "go" },
  --     { "<leader>cgA", "<cmd>GoAlt<cr>", desc = "Alternate File", ft = "go" },
  --
  --     -- 标签操作
  --     { "<leader>cgj", "<cmd>GoAddTag<cr>", desc = "Add Tags", ft = "go" },
  --     { "<leader>cgJ", "<cmd>GoRmTag<cr>", desc = "Remove Tags", ft = "go" },
  --
  --     -- 格式化和导入
  --     { "<leader>cgf", "<cmd>GoImports<cr>", desc = "Format & Imports", ft = "go" },
  --
  --     -- 模块和依赖管理
  --     { "<leader>cgm", "<cmd>GoMod<cr>", desc = "Go Mod", ft = "go" },
  --     { "<leader>cgM", "<cmd>GoModTidy<cr>", desc = "Go Mod Tidy", ft = "go" },
  --     { "<leader>cgI", "<cmd>GoInstallDeps<cr>", desc = "Install Dependencies", ft = "go" },
  --
  --     -- 诊断和 lint
  --     { "<leader>cgl", "<cmd>GoLint<cr>", desc = "Go Lint", ft = "go" },
  --     { "<leader>cgv", "<cmd>GoVet<cr>", desc = "Go Vet", ft = "go" },
  --     { "<leader>cgV", "<cmd>GoVulnCheck<cr>", desc = "Vulnerability Check", ft = "go" },
  --
  --     -- 调试相关
  --     { "<leader>cgdb", "<cmd>GoBreakToggle<cr>", desc = "Toggle Breakpoint", ft = "go" },
  --     { "<leader>cgdB", "<cmd>GoBreakCondition<cr>", desc = "Conditional Breakpoint", ft = "go" },
  --     { "<leader>cgdd", "<cmd>GoDebug<cr>", desc = "Debug", ft = "go" },
  --     { "<leader>cgdt", "<cmd>GoDebugTest<cr>", desc = "Debug Test", ft = "go" },
  --     { "<leader>cgdT", "<cmd>GoDebugTestFunc<cr>", desc = "Debug Test Function", ft = "go" },
  --     { "<leader>cgds", "<cmd>GoDebugStop<cr>", desc = "Stop Debug", ft = "go" },
  --
  --     -- 导航和信息
  --     -- { "<leader>cgnd", "<cmd>GoDefStack<cr>", desc = "Definition Stack", ft = "go" },
  --     -- { "<leader>cgnt", "<cmd>GoDefType<cr>", desc = "Go to Type Definition", ft = "go" },
  --     -- { "<leader>cgni", "<cmd>GoInfo<cr>", desc = "Go Info", ft = "go" },
  --     -- { "<leader>cgnD", "<cmd>GoDoc<cr>", desc = "Go Documentation", ft = "go" },
  --     -- { "<leader>cgnr", "<cmd>GoReferrers<cr>", desc = "Go Referrers", ft = "go" },
  --     -- { "<leader>cgnc", "<cmd>GoCallers<cr>", desc = "Go Callers", ft = "go" },
  --     -- { "<leader>cgnC", "<cmd>GoCallees<cr>", desc = "Go Callees", ft = "go" },
  --
  --     -- 工具和实用功能
  --     { "<leader>cgw", "<cmd>GoWork<cr>", desc = "Go Work", ft = "go" },
  --     { "<leader>cgE", "<cmd>GoEnv<cr>", desc = "Go Environment", ft = "go" },
  --     { "<leader>cgp", "<cmd>GoPlay<cr>", desc = "Go Playground", ft = "go" },
  --   },
  -- },
}
