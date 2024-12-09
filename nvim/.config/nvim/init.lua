require("plugins")

require("astrotheme").setup({
  palette = "astrodark",
  style = {
    transparent = true,
    simple_syntax_colors = true
  },

  termguicolors = true,
})

vim.cmd("colorscheme astrodark")

local set = vim.opt -- set options
set.tabstop = 2
set.softtabstop = 2
set.shiftwidth = 2
set.number = false
set.relativenumber = true
set.scrolloff = 5
set.signcolumn = "no"
set.expandtab = true

vim.cmd("set wrap!")
vim.cmd("set cursorline")

-- vim.opt.foldmethod = "indent"
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevelstart = 99

vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('highlight_yank', {}),
  desc = 'Hightlight selection on yank',
  pattern = '*',
  callback = function()
    vim.highlight.on_yank({ higroup = 'Visual', timeout = 200 })
  end,
})

vim.api.nvim_set_option("clipboard", "unnamed")

vim.api.nvim_set_keymap('t', '<ESC>', '<C-\\><C-n>', { noremap = true })

local bufopts = { noremap = true, silent = true, buffer = buffer }
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, bufopts)
vim.keymap.set("n", "<space>h", ":noh<cr>")

require("typescript-tools").setup({
  expose_as_code_action = "all",
  complete_function_calls = true,
})

require('nvim-treesitter.configs').setup {
  ensure_installed = { "lua", "javascript", "typescript", "python", "ruby", "gleam", "bash", "go", "markdown", "css" },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = true,
  },
}

require('telescope').setup {
  defaults = {
    file_ignore_patterns = {
      "node_modules",
      "build",
      "out"
    }
  }
}

require("neo-tree").setup({
  window = {
    width = 30
  },
  filesystem = {
    follow_current_file = {
      enabled = true
    }
  }
})

require("ibl").setup({
  indent = {
    char = "│",
    tab_char = "│",
  },
  scope = { show_start = false, show_end = false },
  exclude = { filetypes = { 'gleam' } }
})

require("autoclose").setup()
