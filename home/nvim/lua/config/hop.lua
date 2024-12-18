local hop = require('hop')
local keymap = vim.keymap

hop.setup {
  case_insensitive = true;
  char2_fallback_key = "<CR>",
  quit_key = "<Esc",
}

keymap.set({ 'n', 'v', 'o' }, 't', "", {
  silent = true;
  noremap = true;
  callback = function()
    hop.hint_char1()
  end,
})
