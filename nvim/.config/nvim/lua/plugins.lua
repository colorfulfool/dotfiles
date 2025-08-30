local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system({
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  })
  print("Installing packer close and reopen Neovim...")
  vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

packer.init({
  display = {
    open_fn = function()
      return require("packer.util").float({ border = "rounded" })
    end,
  },
})

return packer.startup(function(use)
  use("wbthomason/packer.nvim") -- Have packer manage itself

  use("AstroNvim/astrotheme")

  use {
    'nvim-telescope/telescope.nvim',
    commit = '814f102',
    requires = {
      { 'nvim-lua/plenary.nvim' },
      { 'nvim-telescope/telescope-github.nvim' },
      { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
    },
    config = function()
      require('telescope').setup({
        defaults = {
          file_ignore_patterns = {
            "^node_modules/",
            "^build/",
            "^out/",
            "^performance/",
            "^venv/",
            "^__pycache__/",
            "^.git/",
            ".png$",
            ".avif$",
            ".webp$",
            ".mp3$",
          }
        },
        pickers = {
          buffers = { sort_mru = true },
          find_files = { hidden = true },
          git_branches = { pattern = "refs/heads" }
        }
      })

      require('telescope').load_extension('fzf')

      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<space><space>', builtin.find_files, {})
      vim.keymap.set('n', '<space>fg', builtin.live_grep, {})
      vim.keymap.set('n', '<space>fs', function()
        builtin.grep_string({ word_match = "-w" })
      end, {})
      vim.keymap.set('n', '<space>fb', builtin.buffers, {})
      vim.keymap.set('n', '<space>fh', builtin.help_tags, {})
      vim.keymap.set('n', '<space>gb', builtin.git_branches, {})
      vim.keymap.set('n', '<space>fl', builtin.lsp_document_symbols, {})
      vim.keymap.set('n', 'gr', builtin.lsp_references, {})

      local telescope = require('telescope')
      vim.keymap.set('n', '<space>gp', telescope.extensions.gh.pull_request, {})
    end
  }

  use {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = function()
      vim.keymap.set("n", "<space>ti",
        function()
          local result = vim.treesitter.get_captures_at_cursor(0)
          print(vim.inspect(result))
        end,
        { noremap = true, silent = false }
      )

      require('nvim-treesitter.configs').setup {
        ensure_installed = { "lua", "javascript", "typescript", "python", "ruby", "gleam", "bash", "go", "markdown", "css" },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = true,
        },
      }
    end
  }

  use {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      vim.keymap.set('n', '<space>te', ':Neotree toggle<cr>')
    end
  }

  use {
    "colorfulfool/todo-comments.nvim",
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      require("todo-comments").setup({
        search = {
          pattern = [[\b(TODO|BUG|FIXME):]]
        }
      })
    end,
  }

  use {
    "neovim/nvim-lspconfig",
    requires = { "saghen/blink.cmp" },
    config = function()
      local lspconfig = require('lspconfig')
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      lspconfig.gleam.setup({ capabilities = capabilities })
      lspconfig.pyright.setup({ capabilities = capabilities })
      lspconfig.rust_analyzer.setup({ capabilities = capabilities })
      lspconfig.gopls.setup({ capabilities = capabilities })
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { 'vim' } },
          },
        },
      })
      lspconfig.elixirls.setup({
        capabilities = capabilities,
        cmd = { "/Users/antonkhamets/.local/elixir-ls/language_server.sh" }
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then return end

          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = args.buf,
              callback = function()
                vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
              end
            })
          end
        end
      })
    end
  }

  use {
    "pmizio/typescript-tools.nvim",
    requires = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("typescript-tools").setup({
        expose_as_code_action = "all",
        complete_function_calls = true,
      })
    end,
  }

  use {
    "luckasRanarison/tailwind-tools.nvim",
    run = ":UpdateRemotePlugins",
    requires = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("tailwind-tools").setup({
        document_color = {
          enabled = false
        }
      })
    end
  }

  use {
    "windwp/nvim-ts-autotag",
    config = function()
      require('nvim-ts-autotag').setup({
        opts = {
          enable_close = true,          -- Auto close tags
          enable_rename = true,         -- Auto rename pairs of tags
          enable_close_on_slash = false -- Auto close on trailing </
        }
      })
    end
  }

  use "almo7aya/openingh.nvim"

  use "lukas-reineke/indent-blankline.nvim"

  use({
    "kylechui/nvim-surround",
    tag = "*",
    config = function()
      require("nvim-surround").setup({
        keymaps = {
          visual = "S",
          visual_line = "gS",
        },
      })
    end
  })

  use({
    "echasnovski/mini.nvim",
    config = function()
      require("mini.ai").setup({ n_lines = 100 })
      require("mini.surround").setup({ n_lines = 100 })
      require("mini.operators").setup({
        replace = { prefix = "fuck" }
      })
    end
  })

  use {
    -- "aznhe21/actions-preview.nvim",
    "colorfulfool/actions-preview.nvim",
    -- "~/Codebases/actions-preview.nvim",
    branch = "fix/action-is-nil",
    config = function()
      vim.keymap.set('n', '<space>ca', require('actions-preview').code_actions)
    end
  }

  use {
    -- "felipejz/i18n-menu.nvim",
    "colorfulfool/i18n-menu.nvim",
    branch = "feature/function-patterns-config",
    requires = {
      "smjonas/snippet-converter.nvim",
    },
    config = function()
      require("i18n-menu").setup()
      vim.keymap.set("n", "<leader>ii", ":TranslateMenucr")
    end,
  }

  use {
    "saghen/blink.cmp",
    tag = "v0.11.0",
    config = function()
      require("blink.cmp").setup({
        keymap = {
          preset = 'default',
          ['<CR>'] = { 'accept', 'fallback' },
          ['<Up>'] = { 'select_prev', 'fallback' },
          ['<Down>'] = { 'select_next', 'fallback' },
          cmdline = {
            preset = 'enter',
            ['<Tab>'] = { 'show', 'snippet_forward', 'fallback' },
          }
        },
        completion = {
          menu = { auto_show = function(ctx) return ctx.mode ~= 'cmdline' end }
        },
        appearance = {
          use_nvim_cmp_as_default = true,
          nerd_font_variant = 'mono'
        },
        sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer' },
          cmdline = {},
        },
        signature = { enabled = false }
      })
    end,
  }

  use {
    "folke/ts-comments.nvim",
    config = function()
      require("ts-comments").setup()
    end
  }

  use 'm4xshen/autoclose.nvim'

  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
