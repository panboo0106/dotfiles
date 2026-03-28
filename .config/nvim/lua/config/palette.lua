-- =============================================================================
-- Solarized Zen Palette - Single source of truth
-- =============================================================================
-- Mirrors:
--   kitty/solarized-zen-dark.conf   (dark mode)
--   kitty/solarized-zen-light.conf  (light mode)
--
-- When changing a color here, update the matching line in the kitty conf.
-- Each kitty conf color value is preceded by a comment line: "# palette: <key>".
-- =============================================================================

local M = {}

-- ---------------------------------------------------------------------------
-- Dark palette
-- ---------------------------------------------------------------------------
M.dark = {
  -- Backgrounds (dark → light)
  -- main background | kitty: background
  bg   = "#00242c",
  -- sidebar, statusbar, tab bar | kitty: tab_bar_background
  bg1  = "#002830",
  -- popup, visual, inactive tab | kitty: inactive_tab_background
  bg2  = "#002c38",
  -- lualine section c depth
  bg3  = "#003440",
  -- cursor line highlight
  bg4  = "#003a4a",
  -- lualine inactive depth
  bg5  = "#004050",

  -- Foregrounds (light → dark)
  -- main foreground / color7 | kitty: foreground
  fg      = "#839395",
  -- comment, lineNr, inactive tab fg
  fg2     = "#637981",
  -- muted text / color8 (bright black)
  fg3     = "#576d74",
  -- max contrast on colored bg (e.g. lualine command mode)
  fg_max  = "#fdf6e3",

  -- ANSI normal (color0–7)
  -- color0 | kitty: color0
  black   = "#002b36",
  -- color1 | kitty: color1
  red     = "#db302d",
  -- color2 | kitty: color2
  green   = "#849900",
  -- color3 | kitty: color3
  yellow  = "#b28500",
  -- color4 | kitty: color4
  blue    = "#268bd3",
  -- color5 | kitty: color5
  magenta = "#d23681",
  -- color6 | kitty: color6
  cyan    = "#29a298",

  -- ANSI bright (color8–15)
  -- color8 | kitty: color8
  br_black   = "#576d74",
  -- color9 | kitty: color9
  br_red     = "#e8524f",
  -- color10 | kitty: color10
  br_green   = "#9eb200",
  -- color11 | kitty: color11
  br_yellow  = "#cc9b00",
  -- color12 | kitty: color12
  br_blue    = "#4aa3e3",
  -- color13 | kitty: color13
  br_magenta = "#e04a95",
  -- color14 | kitty: color14
  br_cyan    = "#35bdb2",
  -- color15 | kitty: color15
  br_white   = "#a0b2b2",

  -- Extended
  -- color16 | kitty: color16
  orange    = "#c94c16",
  -- color17 | kitty: color17
  br_orange = "#f55350",

  -- Semantic UI
  -- kitty: selection_background
  selection     = "#268bd3",
  -- kitty: url_color
  url           = "#29a298",
  -- LspReference read/text (cool blue-dark)
  lsp_ref       = "#003850",
  -- LspReference write (warm dark)
  lsp_ref_write = "#2a1800",
}

-- ---------------------------------------------------------------------------
-- Light palette
-- ---------------------------------------------------------------------------
M.light = {
  -- Backgrounds (light → dark)
  -- main background (Solarized base3) | kitty: background
  bg   = "#fdf6e3",
  -- sidebar, inactive tab | kitty: inactive_tab_background
  bg1  = "#eee8d5",
  -- selection, popup, visual | kitty: selection_background
  bg2  = "#e8dcc8",
  -- cursor line highlight
  bg3  = "#ddd0b0",
  -- tab bar background | kitty: tab_bar_background
  bg4  = "#e5dfc8",
  -- lualine inactive depth
  bg5  = "#d4c5a9",

  -- Foregrounds (dark → light)
  -- main foreground | kitty: foreground
  fg      = "#073642",
  -- secondary text (Solarized base01)
  fg2     = "#586e75",
  -- muted: lineNr, comment | kitty: inactive_border_color
  fg3     = "#93a1a1",
  -- max contrast text = br_white | kitty: color15
  fg_max  = "#002b36",

  -- ANSI normal (color0–7)
  -- color0 (near-bg UI fill) | kitty: color0
  black   = "#eee8d5",
  -- color1 | kitty: color1
  red     = "#dc322f",
  -- color2 | kitty: color2
  green   = "#859900",
  -- color3 | kitty: color3
  yellow  = "#b58900",
  -- color4 | kitty: color4
  blue    = "#268bd2",
  -- color5 | kitty: color5
  magenta = "#d33682",
  -- color6 | kitty: color6
  cyan    = "#2aa198",
  -- color7 | kitty: color7
  white   = "#93a1a1",

  -- ANSI bright (color8–15, darker on light bg)
  -- color8 | kitty: color8
  br_black   = "#586e75",
  -- color9 | kitty: color9
  br_red     = "#cb4b16",
  -- color10 | kitty: color10
  br_green   = "#6a8a00",
  -- color11 | kitty: color11
  br_yellow  = "#7a6200",
  -- color12 | kitty: color12
  br_blue    = "#1565a8",
  -- color13 | kitty: color13
  br_magenta = "#a0236a",
  -- color14 | kitty: color14
  br_cyan    = "#1a8077",
  -- color15 | kitty: color15
  br_white   = "#002b36",

  -- Extended
  -- color16 | kitty: color16
  orange    = "#cb4b16",
  -- color17 | kitty: color17
  br_orange = "#dc322f",

  -- Semantic UI
  -- kitty: selection_background
  selection     = "#e8dcc8",
  -- kitty: url_color
  url           = "#268bd2",
  -- LspReference read/text (light blue)
  lsp_ref       = "#dde8f0",
  -- LspReference write (light orange)
  lsp_ref_write = "#f0e0dd",
}

return M
