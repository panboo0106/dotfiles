return {
  {
    "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    build = "npm install -g mcp-hub@latest", -- Installs `mcp-hub` node binary globally
    config = function()
      require("mcphub").setup({
        --- `mcp-hub` binary related options-------------------
        config = vim.fn.expand("~/.config/mcphub/servers.json"), -- Absolute path to MCP Servers config file (will create if not exists)
        port = 38888, -- The port `mcp-hub` server listens to
        shutdown_delay = 5 * 60 * 000, -- Delay in ms before shutting down the server when last instance closes (default: 5 minutes)
        use_bundled_binary = false, -- Use local `mcp-hub` binary (set this to true when using build = "bundled_build.lua")
        mcp_request_timeout = 60000, --Max time allowed for a MCP tool or resource to execute in milliseconds, set longer for long running tasks
        global_env = {}, -- Global environment variables available to all MCP servers (can be a table or a function returning a table)
        workspace = {
          enabled = true, -- Enable project-local configuration files
          look_for = { ".mcphub/servers.json", ".vscode/mcp.json", ".cursor/mcp.json" }, -- Files to look for when detecting project boundaries (VS Code format supported)
          reload_on_dir_changed = true, -- Automatically switch hubs on DirChanged event
          port_range = { min = 40000, max = 41000 }, -- Port range for generating unique workspace ports
          get_port = nil, -- Optional function returning custom port number. Called when generating ports to allow custom port assignment logic
        },

        ---Chat-plugin related options-----------------
        auto_approve = false, -- Auto approve mcp tool calls
        auto_toggle_mcp_servers = true, -- Let LLMs start and stop MCP servers automatically
        extensions = {
          avante = {
            make_slash_commands = true, -- make /slash commands from MCP server prompts
          },
        },

        --- Plugin specific options-------------------
        native_servers = {}, -- add your custom lua native servers here
        builtin_tools = {
          edit_file = {
            parser = {
              track_issues = true,
              extract_inline_content = true,
            },
            locator = {
              fuzzy_threshold = 0.8,
              enable_fuzzy_matching = true,
            },
            ui = {
              go_to_origin_on_complete = true,
              keybindings = {
                accept = ".",
                reject = ",",
                next = "n",
                prev = "p",
                accept_all = "ga",
                reject_all = "gr",
              },
            },
          },
        },
        ui = {
          window = {
            width = 0.8, -- 0-1 (ratio); "50%" (percentage); 50 (raw number)
            height = 0.8, -- 0-1 (ratio); "50%" (percentage); 50 (raw number)
            align = "center", -- "center", "top-left", "top-right", "bottom-left", "bottom-right", "top", "bottom", "left", "right"
            relative = "editor",
            zindex = 50,
            border = "rounded", -- "none", "single", "double", "rounded", "solid", "shadow"
          },
          wo = { -- window-scoped options (vim.wo)
            winhl = "Normal:MCPHubNormal,FloatBorder:MCPHubBorder",
          },
        },
        json_decode = nil, -- Custom JSON parser function (e.g., require('json5').parse for JSON5 support)
        on_ready = function(hub)
          -- Called when hub is ready
        end,
        on_error = function(err)
          -- Called on errors
        end,
        log = {
          level = vim.log.levels.WARN,
          to_file = false,
          file_path = nil,
          prefix = "MCPHub",
        },
      })
    end,
  },
  {
    "Exafunction/codeium.nvim",
    cmd = "Codeium",
    build = ":Codeium Auth",
    dependencies = {
      "hrsh7th/nvim-cmp",
      "nvim-lua/plenary.nvim",
    },
    opts = function()
      -- AI completion accept function
      LazyVim.cmp.actions.ai_accept = function()
        if require("codeium.virtual_text").get_current_completion_item() then
          LazyVim.create_undo()
          vim.api.nvim_input(require("codeium.virtual_text").accept())
          return true
        end
      end

      -- Return the options table
      return {

        enable_cmp_source = not vim.g.ai_cmp,
        virtual_text = {
          enabled = vim.g.ai_cmp,
          key_bindings = {
            accept = "<Tab>",
            next = "<M-]>",
            prev = "<M-[>",
          },
        },
      }
    end,
  },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false, -- set this if you want to always pull the latest change
    opts = {
      ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
      provider = "claude-code", -- Recommend using Claude
      auto_suggestions_provider = "openai", -- Since auto-suggestions are a high-frequency operation and therefore expensive, it is recommended to specify an inexpensive provider or even a free provider: copilot
      -- add any opts here
      providers = {
        openai = {
          endpoint = "https://api.openai.com/v1",
          model = "gpt-4o-mini",
          timeout = 30000, -- Timeout in milliseconds
          max_tokens = 4096,
        },
      },
      acp_providers = {
        ["claude-code"] = {
          command = "npx",
          args = { "@zed-industries/claude-code-acp" },
          env = {
            NODE_NO_WARNINGS = "1",
            ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY"),
          },
        },
        ["codex"] = {
          command = "codex-acp",
          env = {
            NODE_NO_WARNINGS = "1",
            OPENAI_API_KEY = os.getenv("OPENAI_API_KEY"),
          },
        },
        ["gemini-cli"] = {
          command = "gemini",
          args = { "--experimental-acp" },
          env = {
            NODE_NO_WARNINGS = "1",
            GEMINI_API_KEY = os.getenv("GEMINI_API_KEY"),
          },
        },
      },
      behaviour = {
        auto_suggestions = false, -- Experimental stage
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = true,
        support_paste_from_clipboard = true,
      },
      ui = {
        sidebar = {
          width = 40, -- sidebar width in columns
        },
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make BUILD_FROM_SOURCE=true",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "nvim-tree/nvim-web-devicons",
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
      },
    },
  },
}
