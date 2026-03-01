return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown", "md", "mkd", "markdown.md" },
    build = function()
      require("lazy").load({ plugins = { "markdown-preview.nvim" } })
      vim.fn["mkdp#util#install"]()
    end,
    keys = {
      {
        "<leader>cp",
        ft = { "markdown", "md", "mkd", "markdown.md" },
        "<cmd>MarkdownPreviewToggle<cr>",
        desc = "Markdown Preview",
      },
    },
    config = function()
      vim.cmd([[do FileType]])
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-mini/mini.nvim", -- 如果使用 mini.nvim 套件
      -- 'echasnovski/mini.icons' -- 如果使用独立 mini 插件
      -- 'nvim-tree/nvim-web-devicons' -- 如果偏好使用 nvim-web-devicons
    },
    ft = { "markdown", "Avante" }, -- 懒加载，仅在 markdown 文件中加载
    cmd = { "RenderMarkdown" }, -- 也可以通过命令触发加载
    keys = {
      { "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", ft = "markdown", desc = "Toggle Markdown Rendering" },
      { "<leader>me", "<cmd>RenderMarkdown expand<cr>", ft = "markdown", desc = "Expand Anti-conceal" },
      { "<leader>mc", "<cmd>RenderMarkdown contract<cr>", ft = "markdown", desc = "Contract Anti-conceal" },
      { "<leader>md", "<cmd>RenderMarkdown debug<cr>", ft = "markdown", desc = "Debug Markdown" },
    },
    opts = {
      -- 是否默认渲染 markdown
      enabled = true,

      -- 显示渲染视图的 Vim 模式，:h mode()
      render_modes = { "n", "c", "t" },

      -- 最大文件大小 (MB)，超过此大小的文件将被忽略
      max_file_size = 2.0,

      -- 更新标记前必须经过的毫秒数
      debounce = 100,

      -- 预配置设置，已手动完整配置各项，使用 none 避免隐式覆盖
      -- 'obsidian' | 'lazy' | 'none'
      preset = "none",

      -- 日志级别和文件类型
      log_level = "info",
      file_types = { "markdown", "Avante" },

      -- 反隐藏设置 - 在光标行隐藏插件添加的虚拟文本
      anti_conceal = {
        enabled = true,
        above = 0, -- 光标上方显示的行数
        below = 0, -- 光标下方显示的行数
        ignore = {
          code_background = true,
          indent = true,
          sign = true,
          virtual_lines = true,
        },
      },

      -- 标题配置
      heading = {
        enabled = true,
        sign = false, -- 关闭 sign 列图标，减少干扰
        icons = { "Ⅰ ", "Ⅱ ", "Ⅲ ", "Ⅳ ", "Ⅴ ", "Ⅵ " },
        position = "overlay",
        width = "block", -- 只高亮标题文字区域，不铺满整行
        left_margin = 0,
        left_pad = 1, -- 图标左侧留一格，更透气
        right_pad = 1,
        min_width = 0,
        border = false,
        border_virtual = false,
        above = "▄",
        below = "▀",
        backgrounds = {
          "RenderMarkdownH1Bg",
          "RenderMarkdownH2Bg",
          "RenderMarkdownH3Bg",
          "RenderMarkdownH4Bg",
          "RenderMarkdownH5Bg",
          "RenderMarkdownH6Bg",
        },
        foregrounds = {
          "RenderMarkdownH1",
          "RenderMarkdownH2",
          "RenderMarkdownH3",
          "RenderMarkdownH4",
          "RenderMarkdownH5",
          "RenderMarkdownH6",
        },
      },

      -- 段落配置
      paragraph = {
        enabled = true,
        left_margin = 0,
        indent = 0,
        min_width = 0,
      },

      -- 代码块配置
      code = {
        enabled = true,
        sign = false, -- 关闭 sign 列图标
        conceal_delimiters = true,
        language = true,
        position = "left",
        language_icon = true,
        language_name = true,
        language_info = true,
        language_pad = 0,
        disable_background = { "diff" },
        width = "block", -- 只高亮代码区域，不铺满整行
        left_margin = 0,
        left_pad = 1, -- 左侧留空，更清爽
        right_pad = 1, -- 右侧留空，避免贴边
        min_width = 0,
        border = "thin", -- 用细边框代替 hide，更清晰
        above = "▄",
        below = "▀",
        -- 内联代码
        inline = true,
        inline_left = "",
        inline_right = "",
        inline_pad = 0,
        highlight = "RenderMarkdownCode",
        highlight_inline = "RenderMarkdownCodeInline",
      },

      -- 水平分割线配置
      dash = {
        enabled = true,
        icon = "─",
        width = "full",
        left_margin = 0,
        highlight = "RenderMarkdownDash",
      },

      -- 列表项目符号配置
      bullet = {
        enabled = true,
        icons = { "●", "○", "◆", "◇" },
        left_pad = 0,
        right_pad = 0,
        highlight = "RenderMarkdownBullet",
      },

      -- 复选框配置
      checkbox = {
        enabled = true,
        bullet = false,
        right_pad = 1,
        unchecked = {
          icon = "ı ",
          highlight = "RenderMarkdownUnchecked",
        },
        checked = {
          icon = "౒ ",
          highlight = "RenderMarkdownChecked",
        },
        custom = {
          todo = {
            raw = "[-]",
            rendered = "॔ ",
            highlight = "RenderMarkdownTodo",
          },
        },
      },

      -- 引用块配置
      quote = {
        enabled = true,
        icon = "▋",
        repeat_linebreak = false,
        highlight = {
          "RenderMarkdownQuote1",
          "RenderMarkdownQuote2",
          "RenderMarkdownQuote3",
          "RenderMarkdownQuote4",
          "RenderMarkdownQuote5",
          "RenderMarkdownQuote6",
        },
      },

      -- 表格配置
      pipe_table = {
        enabled = true,
        preset = "round", -- 圆角边框，比手动定义更简洁
        cell = "padded",
        padding = 1,
        min_width = 0,
        border_enabled = true,
        border_virtual = false,
        alignment_indicator = "━",
        head = "RenderMarkdownTableHead",
        row = "RenderMarkdownTableRow",
        filler = "RenderMarkdownTableFill",
      },

      -- 标注配置 (GitHub/Obsidian 风格)
      callout = {
        -- GitHub 风格标注
        note = {
          raw = "[!NOTE]",
          rendered = "˽ Note",
          highlight = "RenderMarkdownInfo",
          category = "github",
        },
        tip = {
          raw = "[!TIP]",
          rendered = "̶ Tip",
          highlight = "RenderMarkdownSuccess",
          category = "github",
        },
        important = {
          raw = "[!IMPORTANT]",
          rendered = "ž Important",
          highlight = "RenderMarkdownHint",
          category = "github",
        },
        warning = {
          raw = "[!WARNING]",
          rendered = "* Warning",
          highlight = "RenderMarkdownWarn",
          category = "github",
        },
        caution = {
          raw = "[!CAUTION]",
          rendered = "೦ Caution",
          highlight = "RenderMarkdownError",
          category = "github",
        },

        -- Obsidian 风格标注 (部分)
        abstract = {
          raw = "[!ABSTRACT]",
          rendered = "ਸ Abstract",
          highlight = "RenderMarkdownInfo",
          category = "obsidian",
        },
        todo = {
          raw = "[!TODO]",
          rendered = "ı Todo",
          highlight = "RenderMarkdownInfo",
          category = "obsidian",
        },
        success = {
          raw = "[!SUCCESS]",
          rendered = "Ĭ Success",
          highlight = "RenderMarkdownSuccess",
          category = "obsidian",
        },
        question = {
          raw = "[!QUESTION]",
          rendered = "إ Question",
          highlight = "RenderMarkdownWarn",
          category = "obsidian",
        },
        failure = {
          raw = "[!FAILURE]",
          rendered = "Ŗ Failure",
          highlight = "RenderMarkdownError",
          category = "obsidian",
        },
        example = {
          raw = "[!EXAMPLE]",
          rendered = "ɹ Example",
          highlight = "RenderMarkdownHint",
          category = "obsidian",
        },
      },

      -- 链接配置
      link = {
        enabled = true,
        footnote = {
          enabled = true,
          superscript = true,
          prefix = "",
          suffix = "",
        },
        image = "ȟ ",
        email = "Ǯ ",
        hyperlink = "֟ ",
        highlight = "RenderMarkdownLink",
        wiki = {
          icon = "֟ ",
          highlight = "RenderMarkdownWikiLink",
        },
        custom = {
          web = { pattern = "^http", icon = "֟ " },
          github = { pattern = "github%.com", icon = "ʤ " },
          discord = { pattern = "discord%.com", icon = "ٯ " },
          youtube = { pattern = "youtube%.com", icon = "׃ " },
          reddit = { pattern = "reddit%.com", icon = "э " },
        },
      },

      -- 符号栏配置
      sign = {
        enabled = true,
        highlight = "RenderMarkdownSign",
      },

      -- 缩进配置 (org-mode 风格)
      indent = {
        enabled = false, -- 默认关闭，可以根据需要启用
        per_level = 2,
        skip_level = 1,
        skip_heading = false,
        icon = "▎",
        highlight = "RenderMarkdownIndent",
      },

      -- LaTeX 支持
      latex = {
        enabled = true,
        converter = "latex2text",
        highlight = "RenderMarkdownMath",
        position = "above", -- 'above' | 'below'
        top_pad = 0,
        bottom_pad = 0,
      },

      -- HTML 配置
      html = {
        enabled = true,
        comment = {
          conceal = true,
          text = nil,
          highlight = "RenderMarkdownHtmlComment",
        },
      },

      -- 内联高亮 (Obsidian 风格 ==text==)
      inline_highlight = {
        enabled = true,
        highlight = "RenderMarkdownInlineHighlight",
      },

      -- 窗口选项
      win_options = {
        conceallevel = {
          default = vim.o.conceallevel,
          rendered = 3,
        },
        concealcursor = {
          default = vim.o.concealcursor,
          rendered = "",
        },
      },

      -- 自动补全配置
      completions = {
        lsp = { enabled = true }, -- 推荐方式
        -- blink = { enabled = false },
        -- coq = { enabled = false },
      },

      -- 覆盖配置 - 针对不同文件类型的细化配置
      overrides = {
        buftype = {
          nofile = {
            render_modes = true,
            padding = { highlight = "NormalFloat" },
            sign = { enabled = false },
          },
        },
      },
    },
  },
}
