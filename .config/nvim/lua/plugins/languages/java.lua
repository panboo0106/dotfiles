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

      local jdtls_start = function()
        local function find_java_project_root()
          local wrapper_markers = { "gradlew", "mvnw" }
          local wrapper_root = jdtls_setup.find_root(wrapper_markers)
          if wrapper_root then
            return wrapper_root
          end

          local git_root = jdtls_setup.find_root({ ".git" })
          if git_root then
            local build_files = { "pom.xml", "build.gradle", "build.gradle.kts", "settings.gradle" }
            for _, file in ipairs(build_files) do
              if vim.fn.filereadable(git_root .. "/" .. file) == 1 then
                return git_root
              end
            end
          end

          local build_root = jdtls_setup.find_root({ "pom.xml", "build.gradle", "build.gradle.kts" })
          return build_root or vim.fn.getcwd()
        end

        local root_dir = find_java_project_root()
        local root_markers = { "gradlew", "mvnw", ".git", "pom.xml", "build.gradle" }
        if root_dir == "" then
          root_dir = vim.fn.getcwd()
        end

        local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
        local workspace_dir = home .. "/.cache/jdtls/workspace/" .. project_name

        local jdtls_install_dir = home .. "/.local/share/nvim/mason/packages/jdtls"
        local config_dir = jdtls_install_dir .. "/config_linux"
        local launcher_jar = vim.fn.glob(jdtls_install_dir .. "/plugins/org.eclipse.equinox.launcher_*.jar")
        local lombok_jar = jdtls_install_dir .. "/lombok.jar"

        local java_debug_path = vim.fn.expand("~/.local/share/nvim/mason/packages/java-debug-adapter")
        local java_test_path = home .. "/.local/share/nvim/mason/packages/java-test"

        local bundles = {}

        local java_debug_bundle =
          vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", true)
        if java_debug_bundle ~= "" then
          table.insert(bundles, java_debug_bundle)
        end

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
                nullAnalysis = { mode = "disabled" },
              },
              exclusions = {
                "**/src/main/**/proto/**",
                "**/target/generated-sources/protobuf/**",
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
              saveActions = {
                organizeImports = true,
                format = true,
              },
              cleanup = {
                actionsOnSave = {
                  "qualifyMembers",
                  "addOverride",
                },
              },
              autobuild = {
                enabled = true,
              },
              import = {
                enabled = true,
                order = {
                  "java",
                  "com",
                  "org",
                  "#",
                  "",
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

          init_options = {
            bundles = bundles,
          },
          capabilities = require("blink.cmp").get_lsp_capabilities(capabilities),
          on_attach = function(client, bufnr)
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
          end,
        }

        jdtls.start_or_attach(config)
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = jdtls_start,
      })
    end,
  },
}