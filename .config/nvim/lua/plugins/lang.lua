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
          if
            client
            and (client.name == "pyright" or client.name == "pylsp" or client.name == "jedi_language_server")
          then
            wk.add({
              { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv" },
            }, { buffer = bufnr })
          end
        end,
      })
    end,
  },
  {
    "ray-x/go.nvim",
    dependencies = { -- optional packages
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup()
    end,
    event = { "CmdlineEnter" },
    ft = { "go", "gomod" },
    build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
  },
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
        local root_markers = { "gradlew", "mvnw", ".git", "pom.xml", "build.gradle" }
        local root_dir = jdtls_setup.find_root(root_markers)
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
            sources = {
              organizeImports = {
                starThreshold = 9999,
                staticStarThreshold = 9999,
                staticImportsAfterNonStatic = true,
              },
            },
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

          -- -- 按键映射和其他附加功能
          -- on_attach = function(client, bufnr)
          --   -- 添加代码操作和调试支持
          --   local opts = { noremap = true, silent = true, buffer = bufnr }
          --
          --   -- 常用Java功能映射
          --   vim.keymap.set("n", "<leader>jo", jdtls.organize_imports, opts)
          --   vim.keymap.set("n", "<leader>jv", jdtls.extract_variable, opts)
          --   vim.keymap.set("n", "<leader>jc", jdtls.extract_constant, opts)
          --   vim.keymap.set("n", "<leader>jm", jdtls.extract_method, opts)
          --   vim.keymap.set("n", "<leader>jt", jdtls.test_class, opts)
          --   vim.keymap.set("n", "<leader>jn", jdtls.test_nearest_method, opts)
          --
          --   -- 代码行为菜单
          --   vim.keymap.set("n", "<A-CR>", jdtls.code_action, opts)
          --   vim.keymap.set("n", "<leader>jr", jdtls.code_action, opts)
          --
          --   -- 如果有which-key，可以添加标签
          --   local wk = require("which-key")
          --   wk.add({
          --     ["<leader>j"] = { name = "Java" },
          --   })
          --
          --   -- DAP配置（如果安装了nvim-dap）
          --   if vim.fn.exists("nvim-dap") ~= 0 then
          --     -- 在这里添加DAP相关配置
          --     local dap = require("dap")
          --
          --     -- 添加Java调试配置
          --     -- ...
          --   end
          -- end,
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
}
