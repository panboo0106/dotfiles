-- Language plugins are now organized in separate modules
-- Import all language-specific configurations
return {
  { import = "plugins.languages.markdown" },
  { import = "plugins.languages.python" },
  { import = "plugins.languages.java" },
}
