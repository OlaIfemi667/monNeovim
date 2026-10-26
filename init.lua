
-- =========================
-- lazy.nvim bootstrap
-- =========================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

-- =========================
-- Plugins
-- =========================
require("lazy").setup({

  -- =========================
  -- Telescope : navigation
  -- =========================
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      local tb = require("telescope.builtin")

      vim.keymap.set("n", "<leader>ff", tb.find_files, {
        desc = "Rechercher des fichiers",
      })

      vim.keymap.set("n", "<leader>fg", tb.live_grep, {
        desc = "Rechercher dans le projet",
      })

      vim.keymap.set("n", "<leader>fb", tb.buffers, {
        desc = "Lister les buffers",
      })
    end,
  },

  -- =========================
  -- LSP + Mason
  -- =========================
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "mason-org/mason.nvim",
        opts = {},
      },
      {
        "mason-org/mason-lspconfig.nvim",
        opts = {
          ensure_installed = {
            "lua_ls",
            "pyright",
            "clangd",
            "rust_analyzer",
          },
        },
      },
    },
    config = function()
      -- Lua : reconnaître la variable globale vim
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
          },
        },
      })

      -- C / C++
      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--background-index",
        },
      })

      -- Activer les serveurs LSP
      vim.lsp.enable({
        "lua_ls",
        "pyright",
        "clangd",
        "rust_analyzer",
      })

      -- Raccourcis LSP
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup(
          "UserLspKeymaps",
          { clear = true }
        ),
        callback = function(args)
          local opts = {
            buffer = args.buf,
            silent = true,
          }

          -- Aller à la définition
          vim.keymap.set(
            "n", "gd",
            vim.lsp.buf.definition,
            vim.tbl_extend("force", opts, {
              desc = "Aller à la définition",
            })
          )

          -- Aller à la déclaration
          vim.keymap.set(
            "n", "gD",
            vim.lsp.buf.declaration,
            vim.tbl_extend("force", opts, {
              desc = "Aller à la déclaration",
            })
          )

          -- Afficher la documentation
          vim.keymap.set(
            "n", "K",
            vim.lsp.buf.hover,
            vim.tbl_extend("force", opts, {
              desc = "Documentation du symbole",
            })
          )

          -- Renommer un symbole
          vim.keymap.set(
            "n", "<leader>rn",
            vim.lsp.buf.rename,
            vim.tbl_extend("force", opts, {
              desc = "Renommer le symbole",
            })
          )

          -- Actions de code
          vim.keymap.set(
            "n", "<leader>ca",
            vim.lsp.buf.code_action,
            vim.tbl_extend("force", opts, {
              desc = "Actions de code",
            })
          )

          -- Trouver les références
          vim.keymap.set(
            "n", "gr",
            vim.lsp.buf.references,
            vim.tbl_extend("force", opts, {
              desc = "Trouver les références",
            })
          )
        end,
      })
    end,
  },

  -- =========================
  -- Autocomplétion
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
          ["<CR>"] = cmp.mapping.confirm({
            select = true,
          }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),

        sources = {
          { name = "nvim_lsp" },
        },
      })
    end,
  },

  -- =========================
  -- Treesitter
  -- =========================
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")

      ts.install({
        "lua",
        "c",
        "cpp",
        "python",
        "rust",
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "lua",
          "c",
          "cpp",
          "python",
          "rust",
        },
        callback = function()
          pcall(vim.treesitter.start)
          vim.bo.indentexpr =
            "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },

})

