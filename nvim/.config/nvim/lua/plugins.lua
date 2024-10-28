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
		}
	}

	use {"nvim-treesitter/nvim-treesitter", run = ":TSUpdate"}

  use {
  "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    requires = { 
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    }
  }

  use "neovim/nvim-lspconfig" 

	use {
		"pmizio/typescript-tools.nvim",
		requires = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		config = function()
			require("typescript-tools").setup {
				expose_as_code_action = "all",
				complete_function_calls = true,
				jsx_close_tag = {
					enable = true,
					filetypes = { "javascriptreact", "typescriptreact" },
				}
			}
		end,
	}

  use "lukas-reineke/indent-blankline.nvim"

	use({
    "kylechui/nvim-surround",
    tag = "*", -- Use for stability; omit to use `main` branch for the latest features
    config = function()
        require("nvim-surround").setup({
            -- Configuration here, or leave empty to use defaults
        })
    end
	})

	use {
		"aznhe21/actions-preview.nvim",
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
