-- =========================
-- lazy.nvim bootstrap
-- =========================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "https://github.com/folke/lazy.nvim",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

-- =========================
-- plugins
-- =========================
require("lazy").setup({

  -- =========================
  -- 🔎 Telescope (navigation)
  -- =========================
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local tb = require("telescope.builtin")

      vim.keymap.set("n", "<leader>ff", tb.find_files)
      vim.keymap.set("n", "<leader>fg", tb.live_grep)
      vim.keymap.set("n", "<leader>fb", tb.buffers)
      vim.keymap.set("n", "gd", vim.lsp.buf.definition)
      vim.keymap.set("n", "K", vim.lsp.buf.hover)
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
    end,
  },

  -- =========================
  -- 🧠 LSP + Mason
  -- =========================
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()

      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "pyright",
          "clangd",
          "rust_analyzer",
        },
      })

      require("mason-lspconfig").setup({
        handlers = {
          function(server)
            -- special case Lua (fix vim warning)
            if server == "lua_ls" then
              vim.lsp.config("lua_ls", {
                settings = {
                  Lua = {
                    diagnostics = {
                      globals = { "vim" },
                    },
                  },
                },
              })
              vim.lsp.enable("lua_ls")
            else
              vim.lsp.config(server, {})
              vim.lsp.enable(server)
            end
          end,
        },
      })
    end,
  },


  -- =========================
  -- ⚡ Autocomplétion
  -- =========================
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require("cmp")

      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },

        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),

        sources = {
          { name = "nvim_lsp" },
        },
      })
    end,
  },

})
