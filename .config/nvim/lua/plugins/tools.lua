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
    event = "VeryLazy",
    build = ":TSUpdate html",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-treesitter/nvim-treesitter",
      "folke/noice.nvim",
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
    dependencies = {
      "leafo/magick",
    },
    cond = function()
      return vim.fn.has("win32") ~= 1
        and (vim.env.KITTY_WINDOW_ID ~= nil or vim.env.TERM == "xterm-kitty")
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
            ignored = true, -- 显示 .gitignore 里的文件

            -- 排除列表：只排除真正不需要看的文件，避免误杀同名业务目录
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

              -- 编辑器临时文件
              "*.swp",
              "*.swo",
              "*~",
            },
            -- Explorer 特定配置
            tree = true,
            watch = true,
            diagnostics = true,
            diagnostics_open = true,
            git_status = true,
            git_status_open = true,
            git_untracked = true, -- 必须 true：snacks 同时传 --ignored=matching，与 -uno 不兼容会让 git status 整体失败
            follow_file = true,
            focus = "list",
            auto_close = false,
            jump = { close = false },

            -- 动态调整 Explorer 宽度
            -- actions 里的函数签名是 (picker, item, action)，是正确的 picker 对象
            actions = {
              -- position="left" 是 split 窗口，dim_box 对 split root 读取实际窗口大小
              -- 所以必须直接 nvim_win_set_width(root.win)，WinResized 后 snacks 自动重排子窗口
              explorer_shrink = function(picker)
                local root = picker.layout and picker.layout.root
                local win = root and root.win
                if win and vim.api.nvim_win_is_valid(win) then
                  vim.api.nvim_win_set_width(win, math.max(10, vim.api.nvim_win_get_width(win) - 5))
                end
              end,
              explorer_grow = function(picker)
                local root = picker.layout and picker.layout.root
                local win = root and root.win
                if win and vim.api.nvim_win_is_valid(win) then
                  vim.api.nvim_win_set_width(win, vim.api.nvim_win_get_width(win) + 5)
                end
              end,
            },
            win = {
              list = {
                keys = {
                  ["<S-Left>"]  = "explorer_shrink",
                  ["<S-Right>"] = "explorer_grow",
                },
              },
            },

            -- 布局配置（注意嵌套结构）
            layout = {
              cycle = false,
              preview = false,
              auto_hide = { "input" },
              layout = { -- 这里是关键的第二层 layout
                backdrop = true,
                width = 30, -- 宽度：30 列
                min_width = 10, -- 最小宽度（允许缩小）
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
    },
    init = function()
      local group = vim.api.nvim_create_augroup("SnacksExplorerGitRefresh", { clear = true })
      local function refresh_explorer()
        vim.defer_fn(function()
          local pickers = Snacks.picker.get({ source = "explorer", tab = false })
          for _, picker in ipairs(pickers) do
            if picker and not picker.closed then
              -- explorer_update = Tree:refresh(cwd) + M.update(picker)
              -- Tree:refresh 同时清除 expanded 状态（让目录重新扫描）并标记 git 缓存失效
              -- 仅用 Git.refresh() 无法触发文件系统变化（新增/删除文件）的更新
              picker:action("explorer_update")
            end
          end
        end, 150)
      end
      -- 切回 nvim 焦点时刷新（外部 git 操作、Claude Code、lazygit 后的主要触发器）
      vim.api.nvim_create_autocmd("FocusGained", {
        group = group,
        callback = refresh_explorer,
        desc = "Refresh explorer on focus regain",
      })
      -- 离开 nvim 内置终端时刷新（在 nvim terminal 里跑 git 命令不会触发 FocusGained）
      vim.api.nvim_create_autocmd("TermLeave", {
        group = group,
        callback = refresh_explorer,
        desc = "Refresh explorer after leaving terminal mode",
      })
      -- vim 从 :stop / ctrl+z 挂起恢复时刷新
      vim.api.nvim_create_autocmd("VimResume", {
        group = group,
        callback = refresh_explorer,
        desc = "Refresh explorer on vim resume",
      })
      -- CursorHold 兜底：AI 工具在 nvim terminal 内持续运行时无法自动触发上述事件
      local _last_hold = 0
      vim.api.nvim_create_autocmd("CursorHold", {
        group = group,
        callback = function()
          local now = vim.uv.now()
          if now - _last_hold < 10000 then return end
          _last_hold = now
          refresh_explorer()
        end,
        desc = "Refresh explorer on cursor hold (fallback)",
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
        { "<leader>h",  group = "Harpoon",  icon = { icon = "󰖙",  color = "orange" } },
        { "<leader>k",  group = "kitools",  icon = { icon = "",  color = "cyan"   } },
        { "<leader>kh", group = "HTTP",     icon = { icon = "󰖟",  color = "blue"   } },
        { "<leader>kd", group = "Database", icon = { icon = "󰄞",  color = "yellow" } },
        { "<leader>km", group = "Mermaid",   icon = { icon = "󰟵",  color = "green"  } },
        { "<leader>m",  group = "Markdown", icon = { icon = "󰍔",  color = "blue"   } },
        { "<leader>T",  group = "test",     icon = { icon = "󰙨",  color = "green"  } },
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
        { "<leader>R", group = "Upload / Download", icon = { icon = "", color = "yellow" } },
        {
          "<leader>Rd",
          "<cmd>TransferDownload<cr>",
          desc = "Download from remote server (scp)",
          icon = { color = "green", icon = "󰇚" },
        },
        {
          "<leader>Rf",
          "<cmd>DiffRemote<cr>",
          desc = "Diff file with remote server (scp)",
          icon = { color = "green", icon = "" },
        },
        {
          "<leader>Ri",
          "<cmd>TransferInit<cr>",
          desc = "Init/Edit Deployment config",
          icon = { color = "green", icon = "" },
        },
        {
          "<leader>Rr",
          "<cmd>TransferRepeat<cr>",
          desc = "Repeat transfer command",
          icon = { color = "green", icon = "" },
        },
        {
          "<leader>Ru",
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

  {
    "mbbill/undotree",
    keys = {
      { "<leader>uu", "<cmd>UndotreeToggle<cr>", desc = "Undo Tree" },
    },
  },

  {
    "tpope/vim-dadbod",
    dependencies = {
      {
        "kristijanhusak/vim-dadbod-ui",
        keys = {
          { "<leader>kdb", "<cmd>DBUIToggle<cr>",       desc = "Toggle DB UI" },
          { "<leader>kdB", "<cmd>DBUIFindBuffer<cr>",   desc = "Find DB Buffer" },
        },
        init = function()
          vim.g.db_ui_use_nerd_fonts = 1
        end,
      },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" } },
    },
    cmd = { "DB", "DBUI", "DBUIToggle", "DBUIFindBuffer" },
  },

  {
    "mistweaverco/kulala.nvim",
    ft = "http",
    keys = {
      { "<leader>khs", function() require("kulala").run() end,          desc = "Send Request" },
      { "<leader>kha", function() require("kulala").run_all() end,      desc = "Send All Requests" },
      { "<leader>khi", function() require("kulala").inspect() end,      desc = "Inspect Request" },
      { "<leader>khp", function() require("kulala").jump_prev() end,    desc = "Prev Request" },
      { "<leader>khn", function() require("kulala").jump_next() end,    desc = "Next Request" },
    },
    opts = {},
  },
}
