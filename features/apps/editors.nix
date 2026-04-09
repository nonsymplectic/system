{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}: let
  cfg = config.features.editors;
in {
  options.features.editors = {
    enable = lib.mkEnableOption "Editor applications";

    neovim = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable neovim";
      };

      plugins = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = with pkgs.vimPlugins; [
          nvim-treesitter.withAllGrammars
          nvim-lspconfig
          conform-nvim
          gitsigns-nvim
          mini-files
        ];
        description = "Neovim plugins to install.";
      };

      extraPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = with pkgs; [
          git
          ripgrep

          nixd
          lua-language-server
          pyright
        ];
        description = "Extra packages for Neovim (LSP servers, formatters, CLI tools).";
      };

      extraLuaConfig = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "Extra Lua config appended to Neovim's init.lua.";
      };
    };

    zed = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Zed";
      };

      extensions = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "nix"
          "git-firefly"
        ];
        description = "Zed extensions to install.";
      };

      extraPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = with pkgs; [
          nixd
          nil
        ];
        description = "Extra packages for Zed (LSP servers, etc.).";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        programs.neovim = lib.mkIf cfg.neovim.enable {
          enable = true;
          defaultEditor = true;
          viAlias = true;
          vimAlias = true;

          extraPackages = cfg.neovim.extraPackages;
          plugins = cfg.neovim.plugins;

          extraLuaConfig = ''
            vim.g.mapleader = " "

            vim.opt.number = true
            vim.opt.relativenumber = true
            vim.opt.termguicolors = true
            vim.opt.signcolumn = "yes"
            vim.opt.clipboard = "unnamedplus"
            vim.opt.expandtab = true
            vim.opt.shiftwidth = 2
            vim.opt.tabstop = 2

            vim.opt.list = true
            vim.opt.listchars = {
              tab = "→ ",
              space = "·",
              nbsp = "␣",
              trail = "•",
              eol = "¶",
              precedes = "«",
              extends = "»",
            }

            require("nvim-treesitter.configs").setup({
              highlight = { enable = true },
              indent = { enable = true },
            })

            vim.lsp.config("nixd", {})
            vim.lsp.enable("nixd")

            vim.lsp.config("lua_ls", {
              settings = {
                Lua = {
                  diagnostics = {
                    globals = { "vim" },
                  },
                  workspace = {
                    checkThirdParty = false,
                  },
                },
              },
            })
            vim.lsp.enable("lua_ls")

            vim.lsp.config("pyright", {})
            vim.lsp.enable("pyright")

            require("conform").setup({
              formatters_by_ft = {
                nix = { "alejandra" },
                lua = { "stylua" },
                python = { "black" },
              },
              format_on_save = {
                timeout_ms = 500,
                lsp_fallback = true,
              },
            })

            require("gitsigns").setup({})

            require("mini.files").setup({
              windows = {
                preview = true,
                width_focus = 35,
                width_nofocus = 20,
                width_preview = 45,
              },
            })

            vim.keymap.set("n", "<leader>e", function()
              require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
            end, { desc = "Open file explorer" })

            ${cfg.neovim.extraLuaConfig}
          '';
        };

        programs.zed-editor = lib.mkIf cfg.zed.enable {
          enable = true;
          package = pkgsUnstable.zed-editor;
          extensions = cfg.zed.extensions;
          extraPackages = cfg.zed.extraPackages;
        };
      }
    ];
  };
}
