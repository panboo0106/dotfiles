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
        before = true,
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
    priority = 1000,
    opts = {
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
        finder = "explorer",
        sort = { fields = { "sort" } },
        supports_live = true,
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
        layout = { preset = "sidebar", preview = false },
        win = {
          list = {
            keys = {
              ["<C-b>"] = "page_up", -- Ctrl+r 向上翻页
              ["<C-f>"] = "page_down", -- Ctrl+f 向下翻页
            },
          },
        },
      },
      picker = {
        enabled = true,
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
            exclude = {
              ".DS_Store",
              "thumbs.db",
              ".git",
              "node_modules",
            },
          },
        },
      },
      dashboard = {
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
        { "<leader>k", group = "kitools", icon = { icon = "", color = "bule" } },
        { "<leader>T", group = "terminal", icon = { icon = "", color = "black" } },
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
    opts = {
      require("which-key").add({
        { "<leader>r", group = "Upload / Download", icon = "" },
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
          icon = { color = "green", icon = "󰑖" },
        },
        {
          "<leader>ru",
          "<cmd>TransferUpload<cr>",
          desc = "Upload to remote server (scp)",
          icon = { color = "green", icon = "󰕒" },
        },
      }),
    },
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
}
