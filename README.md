# ✂️  truncateline.nvim

A customisable way to avoid getting lost by truncating long lines

![eg](eg.png)

> [!WARNING]
> Upon first installing you may encounter an error message about namespace id. I'm pretty sure I fixed this but if it happens, just restart Neovim and it will go away. The problem is the plugin manager running a plugin that hasn't had the chance to load normally.

## ✨ Features

+ Have the option to turn it on or off at startup.
+ A toggle function, a key can also be bound to temporarily toggle between on and off.
+ Character count, truncation string, temporary toggle duration and highlight groups can also be configured.

## 📦 Installation

For a default configuration:

```lua
{
  "rlychrisg/truncateline.nvim",
  keys = {
    {
      "<leader>l",
      function()
        require("truncateline").TemporaryToggle()
      end,
      { noremap = true, silent = true, desc = "TruncateLine temporary toggle" },
    },

    {
      "<leader>sl",
      function()
        require("truncateline").ToggleTruncate()
      end,
      { noremap = true, silent = true, desc = "TruncateLine toggle" },
    },
  },
  opts = {
    enabled_on_start = true,

    -- this will be appended to the virtual text to distinguish it from the actual text
    -- to disable this behaviour, set truncate_str to ""
    truncate_str = "...",

    -- how many characters from the start of the line should be displayed
    -- Note: you might want the total of this setting,
    -- along with truncate_str, to be less than your sidescrolloff
    -- setting, to prevent obscuring text.
    line_start_length = 8,

    -- time for in ms for a temporary toggle
    temporary_toggle_dur = 2000,

    -- which highlight group should be used for virtual text.
    -- "Comment", or "Normal" are good choices, but anything in
    -- :highlight can be used.
    hilight_group = "Comment",
  },
},
```

> [!NOTE]
> Contributions and suggestions are welcome but I'm a bit of a beginner in both Lua and Git, so please be patient and err on the side of patronising when explaining stuff.
