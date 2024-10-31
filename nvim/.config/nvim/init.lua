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
    vim.highlight.on_yank { higroup = 'Visual', timeout = 200 }
  end,
})

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<space><space>', builtin.find_files, {})
vim.keymap.set('n', '<space>fg', builtin.live_grep, {})
vim.keymap.set('n', '<space>fs', builtin.grep_string, {})
vim.keymap.set('n', '<space>fb', builtin.buffers, {})
vim.keymap.set('n', '<space>fh', builtin.help_tags, {})
vim.keymap.set('n', '<space>gb', builtin.git_branches, {})
local telescope = require('telescope')
vim.keymap.set('n', '<space>gp', telescope.extensions.gh.pull_request, {})

vim.keymap.set('n', '<space>ca', require('actions-preview').code_actions)

vim.keymap.set('n', '<space>e', function() vim.cmd('Neotree toggle') end)

vim.api.nvim_set_keymap('t', '<ESC>', '<C-\\><C-n>', {noremap = true})

local bufopts = { noremap = true, silent = true, buffer = bufnr }
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, bufopts)

local lspconfig = require('lspconfig')
lspconfig.gleam.setup({})
lspconfig.pyright.setup({})
lspconfig.rust_analyzer.setup({})
lspconfig.tailwindcss.setup({})
lspconfig.gopls.setup({})

local api = require('typescript-tools.api')
vim.keymap.set('n', 'gd', api.go_to_source_definition, {})

vim.keymap.set("n", "<space>ti",
  function()
    local result = vim.treesitter.get_captures_at_cursor(0)
    print(vim.inspect(result))
  end,
  { noremap = true, silent = false }
)

vim.api.nvim_set_option("clipboard", "unnamed")

require('telescope').setup{
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
