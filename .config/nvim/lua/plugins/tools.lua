return {
  {
    "dhruvasagar/vim-table-mode",
    ft = { "markdown", "text", "org" }, -- 只在这些文件类型中加载
    config = function()
      -- 基本配置
      vim.g.table_mode_corner = "|"
      vim.g.table_mode_corner_corner = "|"
      vim.g.table_mode_header_fillchar = "-"
      require("which-key").add({
        { "<leader>kt", group = "Table Mode", desc = "Table Mode" },
        { "<leader>ktm", ":TableModeToggle<CR>", desc = "Toggle Table Mode" },
        { "<leader>ktr", ":TableModeRealign<CR>", desc = "Realign Table" },
      })
    end,
  },
  {
    "kawre/leetcode.nvim",
    build = ":TSUpdate html",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim", -- required by telescope
      "MunifTanjim/nui.nvim",

      -- optional
      "nvim-treesitter/nvim-treesitter",
      "folke/noice.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      ---@type string
      arg = "leetcode.nvim",

      ---@type lc.lang
      lang = "golang",

      cn = { -- leetcode.cn
        enabled = true, ---@type boolean
        translator = true, ---@type boolean
        translate_problems = true, ---@type boolean
      },

      ---@type lc.storage
      storage = {
        home = vim.fn.stdpath("data") .. "/leetcode",
        cache = vim.fn.stdpath("cache") .. "/leetcode",
      },

      ---@type table<string, boolean>
      plugins = {
        non_standalone = false,
      },

      ---@type boolean
      logging = true,

      injector = {
        ["cpp"] = {
          before = { "#include <bits/stdc++.h>", "using namespace std;" },
          after = "int main() {}",
        },
        ["golang"] = {
          before = { "package main" },
          after = "func main() {}",
        },
      }, ---@type table<lc.lang, lc.inject>

      cache = {
        update_interval = 60 * 60 * 24 * 7, ---@type integer 7 days
      },

      console = {
        open_on_runcode = true, ---@type boolean

        dir = "row", ---@type lc.direction

        size = { ---@type lc.size
          width = "90%",
          height = "75%",
        },

        result = {
          size = "60%", ---@type lc.size
        },

        testcase = {
          virt_text = true, ---@type boolean

          size = "40%", ---@type lc.size
        },
      },

      description = {
        position = "left", ---@type lc.position

        width = "40%", ---@type lc.size

        show_stats = true, ---@type boolean
      },

      hooks = {
        ---@type fun()[]
        ["enter"] = {},

        ---@type fun(question: lc.ui.Question)[]
        ["question_enter"] = {},

        ---@type fun()[]
        ["leave"] = {},
      },

      keys = {
        toggle = { "q" }, ---@type string|string[]
        confirm = { "<CR>" }, ---@type string|string[]

        reset_testcases = "r", ---@type string
        use_testcase = "U", ---@type string
        focus_testcases = "H", ---@type string
        focus_result = "L", ---@type string
      },

      ---@type lc.highlights
      theme = {},

      ---@type boolean
      image_support = true,
    },
  },
  {
    "3rd/image.nvim",
    -- Disable on Windows system
    enabled = not vim.g.vscode,
    dependencies = {
      "leafo/magick",
    },
    cond = function()
      return vim.fn.has("win32") ~= 1
    end,
    opts = {
      -- image.nvim config
      backend = "kitty",
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { "markdown", "vimwiki" }, -- markdown extensions (ie. quarto) can go here
        },
        neorg = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { "norg" },
        },
        html = {
          enabled = false,
        },
        css = {
          enabled = false,
        },
      },
      max_width = nil,
      max_height = nil,
      max_width_window_percentage = nil,
      max_height_window_percentage = 50,
      window_overlap_clear_enabled = false, -- toggles images when windows are overlapped
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
      editor_only_render_when_focused = false, -- auto show/hide images when the editor gains/looses focus
      tmux_show_only_in_active_window = false, -- auto show/hide images in the correct Tmux window (needs visual-activity off)
      hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" }, -- render image files as images when opened
    },
  },
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      terminal = {
        win = {
          style = "terminal", -- 使用内置终端样式
          border = "rounded", -- 圆角边框
        },
      },
      notifier = {
        enabled = true,
        timeout = 3000, -- 默认通知显示时间(毫秒)
        width = { min = 40, max = 0.4 },
        height = { min = 1, max = 0.6 },
        margin = { top = 0, right = 1, bottom = 0 },
        padding = true,
        sort = { "level", "added" },
        -- 保留通知历史
        history = {
          -- 最大保存的通知数量
          max = 128,
          -- 是否在关闭时保留历史
          keep_closed = true,
        },
        style = "compact",
      },
      explorer = {
        enabled = true,
        replace_netrw = true,
      },
      picker = {
        preset = "sidebar",
        enabled = true,
        win = {
          list = {
            keys = {
              ["<C-b>"] = "page_up",
              ["<C-f>"] = "page_down",
            },
          },
          preview = {
            wo = {
              wrap = true,
              linebreak = true,
            },
          },
        },
        sources = {
          explorer = {
            -- 文件显示配置
            hidden = true, -- 显示隐藏文件（推荐 true，这样能看到 .env 等配置）
            ignored = false, -- 不显示 gitignore 的文件（推荐 false）

            -- 排除列表（推荐配置）
            exclude = {
              -- 系统垃圾文件
              ".DS_Store",
              "thumbs.db",
              "desktop.ini",
              "Thumbs.db",

              -- 版本控制内部文件
              ".git",
              ".svn",
              ".hg",

              -- Node.js
              "node_modules",
              "package-lock.json",
              "yarn.lock",
              "pnpm-lock.yaml",

              -- Python
              "__pycache__",
              "*.pyc",
              "*.pyo",
              ".pytest_cache",
              ".venv",
              "venv",
              ".tox",

              -- 构建产物
              "dist",
              "build",
              "out",
              ".next",
              ".nuxt",
              "target",
              "*.o",
              "*.so",
              "*.dylib",

              -- 缓存
              ".cache",
              "*.swp",
              "*.swo",
              "*~",

              -- IDE/编辑器
              ".idea",
              ".vscode",
              "*.sublime-*",
            },
            -- Explorer 特定配置
            tree = true,
            watch = true,
            diagnostics = true,
            diagnostics_open = true,
            git_status = true,
            git_status_open = true,
            git_untracked = true,
            follow_file = true,
            focus = "list",
            auto_close = false,
            jump = { close = false },

            -- 布局配置（注意嵌套结构）
            layout = {
              cycle = false,
              preview = false,
              auto_hide = { "input" },
              layout = { -- 这里是关键的第二层 layout
                backdrop = true,
                width = 30, -- 宽度：30 列
                min_width = 30, -- 最小宽度
                position = "left", -- 位置：left 或 right
                border = "none",
                box = "vertical",
                {
                  win = "list",
                  title = " 📁 Files ",
                  border = "rounded",
                },
                {
                  win = "input",
                  height = 1,
                  border = "rounded",
                  -- title = " 📁 Files ",
                  title_pos = "center",
                },
              },
            },
          },
        },
      },
      dashboard = {
        enabled = true,
        preset = {
          header = [[
   ███╗   ███╗██╗   ██╗    ██████╗  █████╗ ███╗   ██╗██████╗  █████╗
   ████╗ ████║╚██╗ ██╔╝    ██╔══██╗██╔══██╗████╗  ██║██╔══██╗██╔══██╗
   ██╔████╔██║ ╚████╔╝     ██████╔╝███████║██╔██╗ ██║██║  ██║███████║
   ██║╚██╔╝██║  ╚██╔╝      ██╔═══╝ ██╔══██║██║╚██╗██║██║  ██║██╔══██║
   ██║ ╚═╝ ██║   ██║       ██║     ██║  ██║██║ ╚████║██████╔╝██║  ██║
   ╚═╝     ╚═╝   ╚═╝       ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝
 ]],
        -- stylua: ignore
        ---@type snacks.dashboard.Item[]
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
        },
      },
    },
    keys = {
      {
        "<leader>e",
        function()
          Snacks.explorer()
        end,
        desc = "Explorer",
      },
      {
        "<leader>er",
        function()
          -- 手动刷新 explorer
          if Snacks.explorer then
            Snacks.explorer.refresh()
          end
        end,
        desc = "Refresh Explorer",
      },
    },
    config = function(_, opts)
      -- 设置 snacks 选项
      require("snacks").setup(opts)

      -- 监听 Git 状态变化后刷新 explorer（explorer 本身已有 watch=true 监听文件变化）
      local group = vim.api.nvim_create_augroup("SnacksExplorerGitRefresh", { clear = true })
      local function refresh_explorer()
        vim.defer_fn(function()
          if Snacks.explorer and Snacks.explorer.refresh then
            Snacks.explorer.refresh()
          end
        end, 50)
      end
      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = { "GitSignsUpdate", "GitSignsChanged" },
        callback = refresh_explorer,
        desc = "Refresh explorer after git signs update",
      })
      -- 切回 nvim 焦点时刷新（外部 git 操作后最关键的触发器）
      vim.api.nvim_create_autocmd("FocusGained", {
        group = group,
        callback = refresh_explorer,
        desc = "Refresh explorer git status on focus",
      })
      -- 保存文件后刷新
      vim.api.nvim_create_autocmd("BufWritePost", {
        group = group,
        callback = refresh_explorer,
        desc = "Refresh explorer git status after write",
      })
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      spec = {
        { "<leader>k", group = "kitools", icon = { icon = "", color = "cyan" } },
        { "<leader>T", group = "test", icon = { icon = "󰙨", color = "green" } },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
  {
    "coffebar/transfer.nvim",
    lazy = true,
    cmd = { "TransferInit", "DiffRemote", "TransferUpload", "TransferDownload", "TransferDirDiff", "TransferRepeat" },
    config = function()
      require("transfer").setup({})
      require("which-key").add({
        { "<leader>r", group = "Upload / Download", icon = { icon = "", color = "yellow" } },
        {
          "<leader>rd",
          "<cmd>TransferDownload<cr>",
          desc = "Download from remote server (scp)",
          icon = { color = "green", icon = "󰇚" },
        },
        {
          "<leader>rf",
          "<cmd>DiffRemote<cr>",
          desc = "Diff file with remote server (scp)",
          icon = { color = "green", icon = "" },
        },
        {
          "<leader>ri",
          "<cmd>TransferInit<cr>",
          desc = "Init/Edit Deployment config",
          icon = { color = "green", icon = "" },
        },
        {
          "<leader>rr",
          "<cmd>TransferRepeat<cr>",
          desc = "Repeat transfer command",
          icon = { color = "green", icon = "" },
        },
        {
          "<leader>ru",
          "<cmd>TransferUpload<cr>",
          desc = "Upload to remote server (scp)",
          icon = { color = "green", icon = "󰕒" },
        },
      })
    end,
  },
  {
    "nvimdev/template.nvim",
    cmd = { "Template", "TemProject" },
    config = function()
      require("template").setup({
        temp_dir = os.getenv("HOME") .. "/.config/nvim/templates",
        author = "minorui",
        email = "leo.minorui@gmail.com",
      })
    end,
  },
  {
    "stevearc/overseer.nvim",
    cmd = { "OverseerOpen", "OverseerClose", "OverseerToggle", "OverseerRun", "OverseerTaskAction" },
    keys = {
      { "<leader>ow", "<cmd>OverseerToggle!<cr>",    desc = "Task list" },
      { "<leader>oo", "<cmd>OverseerRun<cr>",         desc = "Run task" },
      { "<leader>ot", "<cmd>OverseerTaskAction<cr>",  desc = "Task action" },
    },
    opts = {
      dap = false,
      task_list = {
        keymaps = {
          ["<C-j>"] = false,
          ["<C-k>"] = false,
        },
      },
      form     = { win_opts = { winblend = 0 } },
      task_win = { win_opts = { winblend = 0 } },
    },
    config = function(_, opts)
      require("overseer").setup(opts)
      require("overseer").enable_dap()
    end,
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    opts = function(_, opts)
      opts.consumers = opts.consumers or {}
      opts.consumers.overseer = require("neotest.consumers.overseer")
    end,
  },
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>o", group = "overseer", icon = { icon = "󰑮", color = "orange" } },
      },
    },
  },
}
