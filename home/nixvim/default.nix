{ pkgs, ... }:
{
  programs.nixvim = {
    enable = true;
    plugins.lualine.enable = true;
    opts = {
      number = true;
      relativenumber = true;
      expandtab = true;
      autoindent = true;
      shiftwidth = 2;
      smartindent = true;
      tabstop = 2;
      ignorecase = true;
      incsearch = true;
      smartcase = true;
    };
    colorscheme = "iceberg";
    clipboard.register = "unnamedplus";

    globals = {
      mapleader = ",";
    };

    extraPlugins = with pkgs.vimPlugins; [
      iceberg-vim
    ];

    keymaps = [
      {
        action = "<cmd>Neotree toggle<CR>";
        key = "<space>s";
        mode = "n";
        options.silent = true;
      }
      {
        # shortcut to command mode
        action = ":";
        key = ";";
        mode = [
          "n"
          "x"
        ];
        options.silent = true;
      }
      {
        # insert line below without moving cursor
        action = "printf('m`%so<ESC>``', v:count1)";
        key = "<space>o";
        options.expr = true;
        mode = "n";
      }
      {
        # insert line above without moving cursor
        action = "printf('m`%sO<ESC>``', v:count1)";
        key = "<space>O";
        options.expr = true;
        mode = "n";
      }
      # nice emacs bindings
      {
        action = "<HOME>";
        key = "<C-a>";
        mode = "i";
      }
      {
        action = "<END>";
        key = "<C-e>";
        mode = "i";
      }
    ];

    plugins.cmp = {
      enable = true;
      settings.sources = [
        { name = "nvim_lsp"; }
        { name = "luasnip"; }
        { name = "buffer"; }
        { name = "nvim_lua"; }
        { name = "path"; }
      ];

      settings.mappings = {
        "<C-h>" = "cmp.mapping.abort()";
        "<C-n>" = "cmp.mapping.select_next_item()";
        "<C-p>" = "cmp.mapping.select_prev_item()";
        "<C-d>" = "cmp.mapping.scroll_docs(-4)";
        "<C-u>" = "cmp.mapping.scroll_docs(4)";
        "<C-k>" = "cmp.mapping.confirm({ select = true })";
        "<Tab>" = ''
          cmp.mapping(function(fallback)
            if require("luasnip").expand_or_jumpable() then
              require("luasnip").expand_or_jump()
            else
              fallback()
            end
          end,{"i","s"})
        '';
        "<S-Tab>" = ''
          cmp.mapping(function(fallback)
            if require("luasnip").jumpable(-1) then
              require("luasnip").jump(-1)
            else
              fallback()
            end
          end,{"i","s"})
        '';
      };
    };
    plugins.lsp = {
      enable = true;
      keymaps.lspBuf = {
        "K" = "hover";
        "gd" = "definition";
        "gD" = "references";
        "gt" = "type_definition";
        "gi" = "implementation";
      };
      servers = {
        bashls.enable = true;
        lua_ls.enable = true;
        nil_ls.enable = true;
        rust_analyzer = {
          enable = true;
          installRustc = true;
          installCargo = true;
        };
      };
    };
    plugins.treesitter = {
      enable = true;
      nixGrammars = true;
      settings.indent.enable = true;
    };
    plugins.fzf-lua = {
      enable = true;
      keymaps = {
        "<leader>ff" = "git_files";
        "<leader>fg" = "live_grep";
      };
    };

    plugins.neo-tree = {
      enable = true;
      closeIfLastWindow = true;
    };

    plugins.cmp-buffer.enable = true;
    plugins.cmp-emoji.enable = true;
    plugins.cmp-nvim-lsp.enable = true;
    plugins.cmp-path.enable = true;
    plugins.cmp_luasnip.enable = true;
    plugins.luasnip.enable = true;
    plugins.nvim-autopairs.enable = true;
    plugins.rainbow-delimiters.enable = true;
    plugins.web-devicons.enable = true;
    plugins.gitsigns.enable = true;
  };
}
