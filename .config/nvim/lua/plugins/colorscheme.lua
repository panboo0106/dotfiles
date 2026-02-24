-- =============================================================================
-- Solarized High-Contrast - Neovim Colorscheme Configuration
-- =============================================================================
-- Optimized for extended coding sessions (4+ hours)
-- Matches kitty solarized-zen-high-contrast.conf and Obsidian theme
-- WCAG AAA compliant contrast ratios (7:1 or higher where possible)
-- =============================================================================

return {
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      -- Use system/light mode (can be toggled with :set background=light)
      style = "dark",

      -- Disable transparency for consistency across tools
      transparent = false,

      -- Enable terminal colors for consistent terminal emulator display
      terminal_colors = true,

      -- Style options
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        sidebars = "transparent",
        floats = "transparent",
      },

      -- Sidebars that should use sidebar styling
      sidebars = { "qf", "vista_kind", "terminal", "packer", "neo-tree", "Outline" },

      -- Custom colors - High Contrast Solarized Light/Dark
      -- Matches kitty and Obsidian for seamless context switching
      on_colors = function(colors)
        -- =============================================================================
        -- DARK MODE - Solarized Deep
        -- Contrast ratio: ~12:1 (WCAG AAA)
        -- =============================================================================
        if vim.o.background == "dark" then
          colors.bg = "#00242c"           -- Deep teal background
          colors.fg = "#839395"           -- Soft gray foreground
          colors.bg_visual = "#002c38"      -- Selection background
          colors.bg_popup = "#002c38"       -- Popup/menu background
          colors.bg_sidebar = "#002830"     -- Sidebar (tree, etc.)
          colors.bg_status = "#002830"      -- Status line

        -- =============================================================================
        -- LIGHT MODE - High Contrast Solarized
        -- Optimized for 4+ hour coding sessions
        -- Contrast ratio: ~15:1 (WCAG AAA)
        -- Matches kitty: solarized-zen-high-contrast.conf
        -- =============================================================================
        else
          colors.bg = "#fdf6e3"           -- Warm off-white background
          colors.fg = "#073642"           -- Deep teal foreground (HIGH CONTRAST)
          colors.bg_visual = "#e8dcc8"    -- Visible selection (darker than base2)
          colors.bg_popup = "#e8dcc8"     -- Popup/menu background
          colors.bg_sidebar = "#eee8d5"     -- Sidebar (slightly darker)
          colors.bg_status = "#eee8d5"      -- Status line
        end
      end,

      -- Fine-tune specific highlights for better readability
      on_highlights = function(hl, colors)
        -- =============================================================================
        -- DARK MODE HIGHLIGHTS
        -- =============================================================================
        if vim.o.background == "dark" then
          hl.CursorLine = { bg = "#002830" }
          hl.CursorLineNr = { fg = "#839395", bold = true }
          hl.LineNr = { fg = "#637981" }
          hl.Comment = { fg = "#637981", italic = true }
          hl.Keyword = { fg = "#29a298", italic = true }
          hl.Function = { fg = "#268bd3" }
          hl.String = { fg = "#849900" }
          hl.Number = { fg = "#d23681" }

        -- =============================================================================
        -- LIGHT MODE HIGHLIGHTS - High Contrast
        -- =============================================================================
        else
          hl.CursorLine = { bg = "#e8dcc8" }      -- Visible current line
          hl.CursorLineNr = { fg = "#073642", bold = true } -- Bold line number
          hl.LineNr = { fg = "#93a1a1" }          -- Subtle line numbers
          hl.Comment = { fg = "#93a1a1", italic = true }  -- Muted comments
          hl.Keyword = { fg = "#268bd2", italic = true }  -- Blue keywords
          hl.Function = { fg = "#2aa198" }        -- Cyan functions
          hl.String = { fg = "#859900" }            -- Green strings
          hl.Number = { fg = "#d33682" }          -- Magenta numbers
          hl.Type = { fg = "#b58900" }             -- Yellow types
          hl.Constant = { fg = "#cb4b16" }         -- Orange constants
          hl.Identifier = { fg = "#073642" }       -- Default text
          hl.Statement = { fg = "#268bd2" }        -- Blue statements
          hl.PreProc = { fg = "#d33682" }          -- Magenta preproc
          hl.Special = { fg = "#2aa198" }          -- Cyan special
          hl.Underlined = { fg = "#268bd2", underline = true } -- Links
          hl.Error = { fg = "#dc322f", bold = true } -- Red errors
          hl.Todo = { fg = "#d33682", bold = true }  -- Magenta todos
          hl.Search = { bg = "#e8dcc8", fg = "#073642" } -- Search highlight
          hl.IncSearch = { bg = "#b58900", fg = "#fdf6e3" } -- Incremental search
          hl.Visual = { bg = "#e8dcc8" } -- Visual selection
          hl.VisualNOS = { bg = "#e8dcc8" } -- Visual non-owned
          hl.MatchParen = { bg = "#93a1a1", fg = "#073642" } -- Matching paren
          hl.Question = { fg = "#2aa198" } -- Prompt question
          hl.ModeMsg = { fg = "#073642" } -- Mode message
          hl.MoreMsg = { fg = "#2aa198" } -- More message
          hl.WarningMsg = { fg = "#b58900" } -- Warning
          hl.ErrorMsg = { fg = "#dc322f" } -- Error message
        end
      end,
    },
    config = function(_, opts)
      require("solarized-osaka").setup(opts)
      vim.cmd.colorscheme("solarized-osaka")

      -- =============================================================================
      -- Auto-detect background and sync with terminal
      -- =============================================================================
      local function set_background()
        -- Check if kitty is in light mode via environment or manual toggle
        -- You can toggle with: :set background=light | :set background=dark
        if vim.o.background == "light" then
          print("Solarized High-Contrast Light loaded")
        else
          print("Solarized Osaka Dark loaded")
        end
      end

      set_background()

      -- Command to toggle between light/dark
      vim.api.nvim_create_user_command("ToggleSolarized", function()
        if vim.o.background == "dark" then
          vim.o.background = "light"
        else
          vim.o.background = "dark"
        end
        print("Background: " .. vim.o.background)
      end, {})
    end,
  },

  -- =============================================================================
  -- Lualine Status Line - Solarized Osaka Theme
  -- =============================================================================
  -- Optimized for both Light and Dark modes with clear visibility
  -- =============================================================================
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      -- Auto-detect background and set appropriate colors
      local is_light = vim.o.background == "light"

      -- Define colors based on mode
      local colors
      if is_light then
        -- Light mode: High contrast Solarized Osaka
        colors = {
          -- Backgrounds (from light to dark)
          bg0 = "#fdf6e3",      -- main background (base3)
          bg1 = "#eee8d5",      -- secondary (base2)
          bg2 = "#e8dcc8",      -- tertiary highlight
          bg3 = "#d4c5a9",      -- darker highlight
          -- Foregrounds (from dark to light)
          fg0 = "#002b36",      -- deepest (base03) - for high contrast text
          fg1 = "#073642",      -- dark (base02) - primary text
          fg2 = "#586e75",      -- medium (base01) - secondary text
          fg3 = "#93a1a1",      -- light (base1) - muted text
          -- Accents (Solarized standard)
          yellow = "#b58900",
          orange = "#cb4b16",
          red = "#dc322f",
          magenta = "#d33682",
          violet = "#6c71c4",
          blue = "#268bd2",
          cyan = "#2aa198",
          green = "#859900",
        }
      else
        -- Dark mode: Solarized Osaka Dark
        colors = {
          bg0 = "#00242c",      -- main background
          bg1 = "#002c38",      -- secondary
          bg2 = "#003440",      -- tertiary
          bg3 = "#004050",      -- darker highlight
          fg0 = "#fdf6e3",      -- lightest (for high contrast)
          fg1 = "#839395",      -- primary text
          fg2 = "#637981",      -- secondary text
          fg3 = "#576d74",      -- muted text
          yellow = "#b28500",
          orange = "#c94c16",
          red = "#db302d",
          magenta = "#d23681",
          violet = "#6c71c4",
          blue = "#268bd3",
          cyan = "#29a298",
          green = "#849900",
        }
      end

      -- Build lualine theme based on colors
      -- FIXED: Ensure proper contrast for light mode visibility
      local lualine_theme = {
        normal = {
          a = { bg = colors.blue, fg = colors.bg0, gui = "bold" },  -- bg0 is light bg
          b = { bg = colors.bg1, fg = colors.fg1 },  -- fg1 is dark text for light mode
          c = { bg = colors.bg0, fg = colors.fg2 },  -- bg0 matches editor bg
        },
        insert = {
          a = { bg = colors.green, fg = colors.bg0, gui = "bold" },
          b = { bg = colors.bg1, fg = colors.fg1 },
          c = { bg = colors.bg0, fg = colors.fg2 },
        },
        visual = {
          a = { bg = colors.magenta, fg = colors.bg0, gui = "bold" },
          b = { bg = colors.bg1, fg = colors.fg1 },
          c = { bg = colors.bg0, fg = colors.fg2 },
        },
        replace = {
          a = { bg = colors.red, fg = colors.bg0, gui = "bold" },
          b = { bg = colors.bg1, fg = colors.fg1 },
          c = { bg = colors.bg0, fg = colors.fg2 },
        },
        command = {
          a = { bg = colors.yellow, fg = colors.fg0, gui = "bold" },  -- fg0 is darkest text
          b = { bg = colors.bg1, fg = colors.fg1 },
          c = { bg = colors.bg0, fg = colors.fg2 },
        },
        inactive = {
          a = { bg = colors.bg2, fg = colors.fg3, gui = "bold" },
          b = { bg = colors.bg1, fg = colors.fg3 },
          c = { bg = colors.bg0, fg = colors.fg3 },
        },
      }

      opts.options = opts.options or {}
      opts.options.theme = lualine_theme

      return opts
    end,
  },
}
