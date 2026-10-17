local opt = vim.opt

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

opt.number = true
opt.cursorline = true
opt.termguicolors = true

vim.o.number = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.smartindent = true

local coq_settings = {
  clients = {
    buffers = {
      enabled = false, -- Disables BF / text suggestions
    },
  },
}

vim.g.coq_settings = coq_settings

require("config.lazy")

plugins = {
{
  "neanias/everforest-nvim",
  version = false,
  lazy = false,
  priority = 1000, -- make sure to load this before all the other start plugins
  -- Optional; default configuration will be used if setup isn't called.
  config = function()
    require("everforest").setup({
      -- Your config here
      background="hard",
      
    })
  end,
},
{
	"chrisgrieser/nvim-origami",
	event = "VeryLazy",
	opts = {}, -- needed even when using default config

	-- recommended: disable vim's auto-folding
	init = function()
		vim.opt.foldlevel = 99
		vim.opt.foldlevelstart = 99
	end,
},
{
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' }
},
{
	'akinsho/bufferline.nvim',
	version = "*",
	dependencies = 'nvim-tree/nvim-web-devicons'
},
{ "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
{
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
};
{"tpope/vim-fugitive"},
{"lewis6991/gitsigns.nvim"},
{
  "ms-jpq/coq_nvim",
  branch = "coq",
  lazy = false,
  init = function()
    vim.g.coq_settings = coq_settings
    end,
  dependencies = {
    { "ms-jpq/coq.artifacts", branch = "artifacts" },
    { "ms-jpq/coq.thirdparty", branch = "3p" },
  },
},
{
  "ms-jpq/coq.artifacts",
  branch = "artifacts",
  priority = 100,
  lazy = false,
},
{
  'neovim/nvim-lspconfig',
  lazy = false,
  dependencies = {
    -- main one
    { "ms-jpq/coq_nvim", branch = "coq" },

    -- 9000+ Snippets
    { "ms-jpq/coq.artifacts", branch = "artifacts" },

    -- lua & third party sources -- See https://github.com/ms-jpq/coq.thirdparty
    -- Need to **configure separately**
    { 'ms-jpq/coq.thirdparty', branch = "3p" }
    -- - shell repl
    -- - nvim lua api
    -- - scientific calculator
    -- - comment banner
    -- - etc
  },
  init = function()
    vim.g.coq_settings = coq_settings
  end,
  config = function(_, opts)
  end,

  -- example using `opts` for defining servers
  opts = {
    servers = {
      lua_ls = {},
	  clangd = {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--fallback-style=file:" .. vim.fn.stdpath("config") .. "/.clang-format", 
        }
      }
    }
  },
},
{
  "nvim-treesitter/nvim-treesitter",
  config = function()
  require("nvim-treesitter.config").setup({
      indent = {
      enable = true,
      disable = { "c", "cpp" }, -- Delegate indenting back to cindent
      },
      ensure_installed = { "markdown", "markdown_inline", "lua", "vim", "vimdoc", "query" },
      sync_install=false,
      auto_install=true,
      highlight={enable=true},
  })
  end
},
{
	"geg2102/nvim-python-repl",
	dependencies = "nvim-treesitter",
	ft = {"python", "lua", "scala"}, 
	config = function()
	require("nvim-python-repl").setup({
	    execute_on_send = false,
	    vsplit = false,
	})
end
},
{
  'stevearc/conform.nvim',
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      -- Conform will run multiple formatters sequentially
      cpp = { "clang-format" },
    },
    format_on_save = {
      -- These options will be passed to conform.format()
      timeout_ms = 500,
      },
    default_format_opts = {
      lsp_format = "fallback",
    },
    formatters = {
      ["clang-format"] = {
        -- Use append_args to add to the default arguments
        append_args = {"--style=file:" .. vim.fn.stdpath("config") .. "/.clang-format"},
      },
    },
  },
}
}

local compiled = false

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    if not compiled then
      vim.defer_fn(function()
        pcall(vim.cmd, "COQ snips compile")
        compiled = true
      end, 200)
    end
  end,
})

require("lazy").setup(plugins)

vim.o.background="dark"

vim.cmd([[colorscheme everforest]])

require("lualine").setup({
	options = {
		theme = "everforest"
	}
})

require("nvim-treesitter.config").setup({
})

opt.foldmethod="expr"
opt.foldexpr="nvim_treesitter#foldexpr()"

require("ibl").setup()

require("nvim-tree").setup({
	update_focused_file = {
		enable = true,
		update_root = true,
	},
})

require("nvim-python-repl").setup({
    execute_on_send=true, 
    vsplit=true,
    spawn_command={
        python="ipython3", 
    }
})

vim.keymap.set("n", "<F5>s", function() require('nvim-python-repl').send_statement_definition() end)

vim.keymap.set("v", "<F5>v", function() require('nvim-python-repl').send_visual_to_repl() end)

vim.keymap.set("n", "<F5>b", function() require('nvim-python-repl').send_buffer_to_repl() end)

vim.api.nvim_create_autocmd("VimEnter", {callback = function(args) require("nvim-tree.api").tree.open() end})


require("origami").setup {
	useLspFoldsWithTreesitterFallback = {enabled = true}, -- required for `autoFold`
	pauseFoldsOnSearch = true,
	foldtext = {
		enabled = true,
		padding = {width=3},
		lineCount = {
			template = "%d lines", -- `%d` is replaced with the number of folded lines
			hlgroup = "Comment",
		},
		diagnosticsCount = true, -- uses hlgroups and icons from `vim.diagnostic.config().signs`
		gitsignsCount = true, -- requires `gitsigns.nvim`
	},
	autoFold = {
		enabled = true,
		kinds = { "comment", "imports" }, ---@type lsp.FoldingRangeKind[]
	},
	foldKeymaps = {
		setup = true, -- modifies `h` and `l`
		hOnlyOpensOnFirstColumn = false,
	},
}


require("cfg_bl")
require("cfg_lsp")
require("cfg_snip")
