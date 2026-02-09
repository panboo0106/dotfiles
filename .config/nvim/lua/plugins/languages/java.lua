return {
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
      -- 添加Java缩进设置
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = function()
          -- 使用空格而不是Tab (设置为false使用Tab)
          vim.bo.expandtab = true
          -- 设置Tab宽度为4个空格
          vim.bo.tabstop = 4
          -- 设置缩进宽度为4个空格
          vim.bo.shiftwidth = 4
          -- 设置编辑时Tab的宽度
          vim.bo.softtabstop = 4
        end,
      })

      -- JDTLS 自动启动函数
      local jdtls_start = function()
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
        -- 找到项目根目录
        local root_markers = { "gradlew", "mvnw", ".git", "pom.xml", "build.gradle" }
        -- local root_dir = jdtls_setup.find_root(root_markers) or vim.fn.getcwd()

        -- 工作空间目录
        local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
        local workspace_dir = home .. "/.cache/jdtls/workspace/" .. project_name

        -- JDTLS配置路径
        local jdtls_install_dir = home .. "/.local/share/nvim/mason/packages/jdtls"
        local jdtls_bin = jdtls_install_dir .. "/bin/jdtls"
        local lombok_jar = jdtls_install_dir .. "/lombok.jar"

        -- 检查jdtls脚本是否存在
        if vim.fn.executable(jdtls_bin) ~= 1 then
          vim.notify("JDTLS executable not found at: " .. jdtls_bin, vim.log.levels.ERROR)
          return
        end

        -- 设置 Java Debug Adapter 路径
        local java_debug_path = vim.fn.expand("~/.local/share/nvim/mason/packages/java-debug-adapter")
        local java_test_path = home .. "/.local/share/nvim/mason/packages/java-test"

        -- 收集所有调试和测试 bundle JAR 文件
        local bundles = {}

        -- 检查路径是否存在
        local java_debug_exists = vim.fn.isdirectory(java_debug_path) == 1
        local java_test_exists = vim.fn.isdirectory(java_test_path) == 1

        if not java_debug_exists or not java_test_exists then
          vim.notify(
            "Java debug/test tools not found. Install with: :MasonInstall java-debug-adapter java-test",
            vim.log.levels.WARN
          )
        end
        -- 定期清理工作空间
        local function cleanup_jdtls_workspace()
          local workspace_base = vim.fn.expand("~/.cache/jdtls/workspace/")
          -- 清理旧的日志文件
          vim.fn.system("find " .. workspace_base .. ' -name "*.log" -delete 2>/dev/null')
          -- 清理超过7天的临时文件
          vim.fn.system("find " .. workspace_base .. " -type f -mtime +7 -delete 2>/dev/null")
        end

        -- 启动时清理
        vim.api.nvim_create_autocmd("VimEnter", {
          callback = cleanup_jdtls_workspace,
          once = true,
        })

        -- 添加 Java Debug JAR (仅在存在时)
        if java_debug_exists then
          local java_debug_bundle =
            vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", true)
          if java_debug_bundle ~= "" then
            table.insert(bundles, java_debug_bundle)
          end
        end

        -- 添加 Java Test JAR 文件 (仅在存在时)
        if java_debug_exists then
          local java_debug_bundle =
            vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", true)
          if java_debug_bundle ~= "" then
            table.insert(bundles, java_debug_bundle)
          end
        end

        -- 添加 Java Test JAR 文件 (仅在存在时)
        if java_test_exists then
          local java_test_bundles = vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar", true), "\n")
          for _, bundle in ipairs(java_test_bundles) do
            if bundle ~= "" then
              table.insert(bundles, bundle)
            end
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
            jdtls_bin,
            "-data",
            workspace_dir,
            -- Lombok 支持
            "--jvm-arg=-javaagent:" .. lombok_jar,

            -- 内存配置（IDEA 级别）
            "--jvm-arg=-Xms1g", -- 初始堆内存 1GB
            "--jvm-arg=-Xmx6g", -- 最大堆内存 6GB（接近 IDEA 默认配置）
            "--jvm-arg=-XX:ReservedCodeCacheSize=512m", -- 代码缓存 512MB

            -- GC 优化（IDEA 同款配置）
            "--jvm-arg=-XX:+UseG1GC", -- 使用 G1 垃圾回收器
            "--jvm-arg=-XX:+UseStringDeduplication", -- 字符串去重
            "--jvm-arg=-XX:MaxGCPauseMillis=200", -- 最大 GC 暂停时间 200ms
            "--jvm-arg=-XX:+ParallelRefProcEnabled", -- 并行引用处理
            "--jvm-arg=-XX:G1HeapRegionSize=32m", -- G1 区域大小

            -- JVM 模块访问权限
            "--jvm-arg=--add-modules=ALL-SYSTEM",
            "--jvm-arg=--add-opens=java.base/java.util=ALL-UNNAMED",
            "--jvm-arg=--add-opens=java.base/java.lang=ALL-UNNAMED",
            "--jvm-arg=--add-opens=java.base/java.io=ALL-UNNAMED",
            "--jvm-arg=--add-opens=java.base/java.text=ALL-UNNAMED",
            "--jvm-arg=--add-opens=java.base/sun.nio.ch=ALL-UNNAMED",

            -- 性能优化
            "--jvm-arg=-Djava.awt.headless=true", -- 无头模式
            "--jvm-arg=-Dfile.encoding=UTF-8", -- 文件编码
            "--jvm-arg=-XX:SoftRefLRUPolicyMSPerMB=50", -- 软引用存活时间
            "--jvm-arg=-XX:CICompilerCount=2", -- JIT 编译器线程数
            "--jvm-arg=-Dsun.zip.disableMemoryMapping=true", -- 禁用内存映射（减少内存占用）
            "--jvm-arg=-Djdk.module.illegalAccess.silent=true", -- 静默非法访问警告
          },

          root_dir = root_dir,

          settings = {
            java = {
              home = os.getenv("JAVA_HOME"),
              eclipse = {
                downloadSources = true, -- 改为 true，下载源码（IDEA 默认行为）
              },
              -- 源码下载
              downloadSources = true, -- 自动下载依赖源码
              jdt = {
                ls = {
                  lombokSupport = {
                    enabled = true, -- Lombok 支持
                  },
                },
              },
              -- 项目配置
              project = {
                referencedLibraries = {
                  "lib/**/*.jar",
                  "libs/**/*.jar",
                  "*.jar",
                },
                sourcePaths = {
                  "src/main/java",
                  "src/test/java",
                  "src/main/resources",
                  "src/test/resources",
                },
              },
              compile = {
                nullAnalysis = { mode = "automatic" }, -- 开启 null 分析（类似 IDEA 的 @Nullable/@NotNull）
              },
              -- 代码分析和检查（IDEA 级别）
              errors = {
                incompleteClasspath = {
                  severity = "warning", -- 类路径不完整时的严重性
                },
              },
              -- 快速修复和重构
              quickfix = {
                showAt = "line", -- 在行级别显示快速修复
              },
              exclusions = {
                "**/src/main/**/proto/**",
                "**/target/generated-sources/protobuf/**",
                "**/node_modules/**",
                "**/.git/**",
              },
              -- 签名帮助
              signatureHelp = {
                enabled = true,
                description = {
                  enabled = true,
                },
              },
              -- 内容提供者
              contentProvider = {
                preferred = "fernflower", -- 反编译器
              },
              -- 代码生成
              codeGeneration = {
                toString = {
                  template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                },
                hashCodeEquals = {
                  useJava7Objects = true,
                  useInstanceof = true,
                },
                useBlocks = true,
                generateComments = true,
              },
              configuration = {
                updateBuildConfiguration = "interactive",
                runtimes = {
                  {
                    name = "JavaSE-17",
                    path = os.getenv("JAVA_HOME"),
                  },
                },
              },
              sources = {
                organizeImports = {
                  starThreshold = 99,
                  staticStarThreshold = 99,
                  staticImportsAfterNonStatic = true,
                },
              },
              maven = {
                downloadSources = true,
                downloadJavadoc = true, -- 新增：下载 Javadoc
                updateSnapshots = true,
                userSettings = "~/.m2/settings.xml",
                enabled = true,
                updateBuildConfiguration = "automatic",
              },
              -- Gradle 支持（类似 IDEA）
              gradle = {
                enabled = true,
                wrapper = {
                  enabled = true, -- 使用 Gradle Wrapper
                },
              },
              -- CodeLens 配置
              implementationsCodeLens = {
                enabled = true,
              },
              referencesCodeLens = {
                enabled = true,
              },
              references = {
                includeDecompiledSources = true,
              },
              -- Inlay Hints 配置（增强版）
              inlayHints = {
                parameterNames = {
                  enabled = "all", -- 显示参数名称提示
                },
              },
              -- 折叠范围
              foldingRange = {
                enabled = true,
              },
              -- 选择范围
              selectionRange = {
                enabled = true,
              },
              format = {
                enabled = true,
                settings = {
                  url = "~/.config/nvim/apex-formatter.xml",
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
              autobuild = {
                enabled = false, -- 禁用自动构建以提升性能
              },
              maxConcurrentBuilds = 4, -- 最大并发构建数
              -- 进度报告
              progressReports = {
                enabled = true, -- 显示后台任务进度
              },
              -- 语义高亮
              semanticHighlighting = {
                enabled = true,
              },
              import = {
                enabled = true,
                order = {
                  "java",
                  "javax",
                  "#",
                  "",
                  -- "com",
                  -- "org",
                  -- "#", -- 其他非静态导入
                  -- "", -- 空字符串表示静态导入与非静态导入的分隔点
                },
                separate = false,
                staticAfterInstance = true,
              },
              completion = {
                importOrder = {
                  "java",
                  "javax",
                },
                enabled = true,
                guessMethodArguments = true, -- 自动猜测方法参数（IDEA 默认）
                maxResults = 100, -- 补全结果数量（提高到 100，接近 IDEA）
                overwrite = true, -- 覆盖现有导入
                matchCase = "firstLetter", -- 大小写匹配策略（IDEA 风格）
                lazyResolveTextEdit = true, -- 延迟解析文本编辑（提升性能）
                postfix = {
                  enabled = true, -- 后缀补全（如 .var, .for 等，IDEA 特性）
                },
                filteredTypes = { -- 过滤不需要的类型
                  "com.sun.*",
                  "java.awt.*",
                  "jdk.*",
                  "sun.*",
                  "org.graalvm.*",
                  "io.micrometer.shaded.*",
                },
                favoriteStaticMembers = {
                  -- JUnit 4
                  "org.junit.Assert.*",
                  "org.junit.Assume.*",
                  -- JUnit 5
                  "org.junit.jupiter.api.Assertions.*",
                  "org.junit.jupiter.api.Assumptions.*",
                  "org.junit.jupiter.api.DynamicTest.*",
                  -- Mockito
                  "org.mockito.Mockito.*",
                  "org.mockito.ArgumentMatchers.*",
                  "org.mockito.BDDMockito.*",
                  -- Hamcrest
                  "org.hamcrest.MatcherAssert.assertThat",
                  "org.hamcrest.Matchers.*",
                  "org.hamcrest.CoreMatchers.*",
                  -- AssertJ
                  "org.assertj.core.api.Assertions.*",
                  -- Collections
                  "java.util.Collections.*",
                  "java.util.Arrays.*",
                },
              },
              -- 模板变量
              templates = {
                fileHeader = {},
                typeComment = {},
              },
            },
            extendedClientCapabilities = jdtls_setup.extendedClientCapabilities,
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
              { "<leader>j", group = "Java", icon = "☕" },

              -- 代码重构（类似 IDEA Alt+Enter / Ctrl+Shift+R）
              {
                "<leader>jo",
                "<cmd>lua require('jdtls').organize_imports()<cr>",
                desc = "Organize Imports",
                icon = { color = "orange", icon = "" },
              },
              {
                "<leader>jv",
                "<cmd>lua require('jdtls').extract_variable()<cr>",
                desc = "Extract Variable",
                icon = { color = "blue", icon = "" },
              },
              {
                "<leader>jc",
                "<cmd>lua require('jdtls').extract_constant()<cr>",
                desc = "Extract Constant",
                icon = { color = "purple", icon = "" },
              },
              {
                "<leader>jm",
                "<cmd>lua require('jdtls').extract_method()<cr>",
                desc = "Extract Method",
                icon = { color = "cyan", icon = "" },
              },

              -- 测试运行（类似 IDEA Ctrl+Shift+F10）
              {
                "<leader>jt",
                "<cmd>lua require('jdtls').test_class()<cr>",
                desc = "Run Test Class",
                icon = { color = "green", icon = "" },
              },
              {
                "<leader>jn",
                "<cmd>lua require('jdtls').test_nearest_method()<cr>",
                desc = "Run Test Method",
                icon = { color = "green", icon = "" },
              },

              -- 代码生成（类似 IDEA Alt+Insert）
              {
                "<leader>jg",
                group = "Generate",
                icon = { color = "yellow", icon = "" },
              },
              {
                "<leader>jgs",
                "<cmd>lua require('jdtls').generate_constructor()<cr>",
                desc = "Generate Constructor",
                icon = { color = "yellow", icon = "" },
              },
              {
                "<leader>jgg",
                "<cmd>lua require('jdtls').generate_accessors()<cr>",
                desc = "Generate Getters/Setters",
                icon = { color = "yellow", icon = "" },
              },
              {
                "<leader>jgt",
                "<cmd>lua require('jdtls').generate_toString()<cr>",
                desc = "Generate toString()",
                icon = { color = "yellow", icon = "" },
              },
              {
                "<leader>jge",
                "<cmd>lua require('jdtls').generate_hashCodeEquals()<cr>",
                desc = "Generate equals/hashCode",
                icon = { color = "yellow", icon = "" },
              },

              -- 代码导航
              {
                "<leader>jd",
                "<cmd>lua require('jdtls').goto_definition()<cr>",
                desc = "Goto Definition (Java)",
                icon = { color = "cyan", icon = "" },
              },
              {
                "<leader>js",
                "<cmd>lua require('jdtls').super_implementation()<cr>",
                desc = "Goto Super Implementation",
                icon = { color = "cyan", icon = "" },
              },

              -- Code Action（类似 IDEA Alt+Enter）
              {
                "<leader>ca",
                "<cmd>lua require('jdtls').code_action()<cr>",
                desc = "Code Action (Java)",
                icon = { color = "red", icon = "" },
              },

              -- 构建和更新
              {
                "<leader>ju",
                "<cmd>lua require('jdtls').update_project_config()<cr>",
                desc = "Update Project Config",
                icon = { color = "blue", icon = "" },
              },
              {
                "<leader>jc",
                "<cmd>lua require('jdtls').compile('full')<cr>",
                desc = "Full Compile",
                icon = { color = "orange", icon = "" },
              },
            }, { buffer = bufnr })
            -- DAP配置（如果安装了nvim-dap）
            if vim.fn.exists("nvim-dap") ~= 0 then
              -- 在这里添加DAP相关配置
              local dap = require("dap")

              -- 添加Java调试配置
              -- ...
            end
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
}

