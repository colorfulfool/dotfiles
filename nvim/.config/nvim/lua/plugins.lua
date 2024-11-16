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

-- Have packer use a popup window
packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

-- Install your plugins here
return packer.startup(function(use)
	use ("wbthomason/packer.nvim") -- Have packer manage itself

	use("folke/tokyonight.nvim")
	use("ellisonleao/gruvbox.nvim")
  use("AstroNvim/astrotheme")

	use {
	  'nvim-telescope/telescope.nvim', tag = '0.1.6',
	  requires = {
			{ 'nvim-lua/plenary.nvim' },
			{ 'nvim-telescope/telescope-github.nvim' }
		},
    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<space><space>', builtin.find_files, {})
      vim.keymap.set('n', '<space>fg', builtin.live_grep, {})
      vim.keymap.set('n', '<space>fs', builtin.grep_string, {})
      vim.keymap.set('n', '<space>fb', builtin.buffers, {})
      vim.keymap.set('n', '<space>fh', builtin.help_tags, {})
      vim.keymap.set('n', '<space>gb', builtin.git_branches, {})
      vim.keymap.set('n', '<space>fl', builtin.lsp_document_symbols, {})

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

  use "neovim/nvim-lspconfig"

	use {
		"pmizio/typescript-tools.nvim",
		requires = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		config = function()
      local api = require('typescript-tools.api')
      vim.keymap.set('n', 'gd', api.go_to_source_definition, {})
		end,
	}

  use "lukas-reineke/lsp-format.nvim"

  use "almo7aya/openingh.nvim"

  use "lukas-reineke/indent-blankline.nvim"

	use({
    "kylechui/nvim-surround",
    tag = "*", -- Use for stability; omit to use `main` branch for the latest features
    config = function()
      require("nvim-surround").setup({})
    end
	})

	use {
		"aznhe21/actions-preview.nvim",
    config = function()
      vim.keymap.set('n', '<space>ca', require('actions-preview').code_actions)
    end
	}

  use {
    -- "felipejz/i18n-menu.nvim",
    "~/Codebases/i18n-menu.nvim",
    -- "colorfulfool/i18n-menu.nvim",
    requires = {
      "smjonas/snippet-converter.nvim",
    },
    config = function()
      require("i18n-menu").setup()
      vim.keymap.set("n", "<leader>ii", ":TranslateMenu<cr>")
    end,
  }

	use {
		"ms-jpq/coq_nvim",
		config = function()
			vim.g.coq_settings = {
				auto_start = true, -- if you want to start COQ at startup
			}
		end,
	}

	use 'm4xshen/autoclose.nvim'

	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
