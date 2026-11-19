{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.features.latex;
in {
  options.features.latex = {
    enable = lib.mkEnableOption "LaTeX compilation toolchain";

    scheme = lib.mkOption {
      type = lib.types.enum ["basic" "small" "medium" "full"];
      default = "full";
      description = "TeX Live scheme to install.";
    };

    engine = lib.mkOption {
      type = lib.types.enum ["pdflatex" "xelatex" "lualatex"];
      default = "pdflatex";
      description = "LaTeX engine that latexmk drives for compilation.";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        home.packages = [pkgs.texlive.combined."scheme-${cfg.scheme}"];
      }
    ];

    features.editors.neovim.extraLuaConfig = lib.mkIf config.features.editors.enable (let
      engineFlag =
        {
          pdflatex = "-pdf";
          xelatex = "-xelatex";
          lualatex = "-lualatex";
        }
        .${
          cfg.engine
        };
    in ''
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "tex",
        callback = function(args)
          vim.keymap.set("n", "<leader><CR>", function()
            local file = vim.fn.expand("%:p")
            local dir  = vim.fn.expand("%:p:h")
            local pdf  = vim.fn.expand("%:p:r") .. ".pdf"
            local log  = vim.fn.expand("%:p:r") .. ".log"
            vim.cmd("silent! write")
            vim.notify("Compiling " .. vim.fn.expand("%:t") .. "...", vim.log.levels.INFO)

            vim.fn.jobstart({ "latexmk", "${engineFlag}", "-interaction=nonstopmode", file }, {
              cwd = dir,
              on_exit = function(_, code)
                if code == 0 then
                  if not vim.b.latex_pdf_opened then
                    vim.fn.jobstart({ "xdg-open", pdf }, { detach = true })
                    vim.b.latex_pdf_opened = true
                  end
                  vim.notify("LaTeX compiled", vim.log.levels.INFO)
                else
                  vim.notify("latexmk failed (exit " .. code .. "), opening " .. vim.fn.fnamemodify(log, ":t"), vim.log.levels.ERROR)
                  vim.fn.jobstart(
                    { "foot", "-T", "latexmk log", "less", "-R", log },
                    { detach = true }
                  )
                end
              end,
            })
          end, { buffer = args.buf, desc = "Compile LaTeX and open PDF" })
        end,
      })
    '');
  };
}
