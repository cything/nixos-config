local keymap = vim.keymap

local fzf = require("fzf-lua")

keymap.set("n", "<leader>ff", fzf.files, { silent = true })
keymap.set("n", "<leader>fr", fzf.oldfiles, { silent = true })
keymap.set("n", "<leader>fc", fzf.resume, { silent = true })
keymap.set("n", "<leader>fs", fzf.treesitter, { silent = true })
keymap.set("n", "<leader>fg", fzf.grep_project, { silent = true })

fzf.setup {
  "fzf-native",
  keymap = {
    fzf = {
      ["ctrl-u"]          = "half-page-up",
      ["ctrl-d"]          = "half-page-down",
      ["ctrl-j"]    = "preview-page-down",
      ["ctrl-k"]    = "preview-page-up",
    }
  }
}
