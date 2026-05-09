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
  bg2  = "#0a3848",
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
  black   = "#4a7080",
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
  -- main background | kitty: background
  bg   = "#f4f0e2",
  -- sidebar, inactive tab | kitty: inactive_tab_background
  bg1  = "#e8e2cf",
  -- selection, popup, visual | kitty: selection_background
  bg2  = "#b8d4ea",
  -- cursor line highlight
  bg3  = "#e0d8cc",
  -- tab bar background | kitty: tab_bar_background
  bg4  = "#c8bfa8",
  -- lualine inactive depth
  bg5  = "#c4baaa",

  -- Foregrounds (dark → light)
  -- main foreground | kitty: foreground
  fg      = "#1c2d38",
  -- secondary text
  fg2     = "#3d5468",
  -- muted: lineNr, comment | kitty: inactive_border_color
  fg3     = "#8fa4ae",
  -- max contrast text = br_white | kitty: color15
  fg_max  = "#001a28",

  -- ANSI normal (color0–7)
  -- color0 | kitty: color0
  black   = "#3d5260",
  -- color1 | kitty: color1
  red     = "#bf3535",
  -- color2 | kitty: color2
  green   = "#3a7800",
  -- color3 | kitty: color3
  yellow  = "#6a5e00",
  -- color4 | kitty: color4
  blue    = "#1a6faf",
  -- color5 | kitty: color5
  magenta = "#883c8c",
  -- color6 | kitty: color6
  cyan    = "#107870",
  -- color7 | kitty: color7
  white   = "#4a6878",

  -- ANSI bright (color8–15, deeper on light bg)
  -- color8 | kitty: color8
  br_black   = "#293e4c",
  -- color9 | kitty: color9
  br_red     = "#c02828",
  -- color10 | kitty: color10
  br_green   = "#007840",
  -- color11 | kitty: color11
  br_yellow  = "#6e6200",
  -- color12 | kitty: color12
  br_blue    = "#1060a0",
  -- color13 | kitty: color13
  br_magenta = "#9640a0",
  -- color14 | kitty: color14
  br_cyan    = "#0c6460",
  -- color15 | kitty: color15
  br_white   = "#001a28",

  -- Extended
  -- color16 | kitty: color16
  orange    = "#b04400",
  -- color17 | kitty: color17
  br_orange = "#903800",

  -- Semantic UI
  -- kitty: selection_background
  selection     = "#b8d4ea",
  -- kitty: url_color
  url           = "#1a6faf",
  -- LspReference read/text (light blue)
  lsp_ref       = "#dde8f0",
  -- LspReference write (light orange)
  lsp_ref_write = "#f0e0dd",
}

return M
