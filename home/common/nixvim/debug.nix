{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib) mkIf;
  inherit (lib.meta) getExe';
  inherit (lib.attrsets) mapAttrs mapAttrsToList;
  inherit (config.lib.nixvim) mkRaw;
  cfg = config.baseline.nixvim.debug;
  nixvim = config.programs.nixvim;
in {
  options = {
    baseline.nixvim.debug = {
      enable = mkEnableOption "Enable baseline debug configuiration DAP + DAP ui";
    };
  };

  config = mkIf cfg.enable {
    programs.nixvim = {
      plugins.dap = let
        base = {
          command = "${getExe' pkgs.gdb "gdb"}";
          args = ["-i" "dap"];
        };

        exes = {
          launch_excecutable = {
            name = "Launch executable";
            request = "launch";
            enrichConfig = ''
              function(config, on_config)
                local final_config = vim.deepcopy(config)
                local program = vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                final_config.program = program
                on_config(final_config)
              end
            '';
            options = {};
          };

          attach = {
            name = "Attach to process";
            request = "attach";
            enrichConfig = ''
              function(config, on_config)
                local final_config = vim.deepcopy(config)
                local pid = coroutine.resume(require('dap.utils').pick_process({}))
                final_config.pid = pid
                on_config(final_config)
              end
            '';
            options = {};
          };
        };

        executables = cfgs: mapAttrs (_: cfg: {inherit (cfg) enrichConfig options;} // base) cfgs;
        configurations = cfgs:
          mapAttrsToList (type: cfg: {
            inherit type;
            inherit (cfg) name request;
          })
          cfgs;
      in {
        enable = true;
        adapters = {
          executables = executables exes;
        };
        configurations = {
          c = configurations exes;
          h = configurations exes;
          cpp = configurations exes;
          hpp = configurations exes;
        };
        signs = {
          dapBreakpoint = {
            text = "●";
            texthl = "DapBreakpoint";
          };
          dapBreakpointCondition = {
            text = "●⃠";
            texthl = "DapBreakpointCondition";
          };
          dapLogPoint = {
            text = "◆";
            texthl = "DapLogPoint";
          };
          dapBreakpointRejected = {
            text = "⨂";
            texthl = "DapBreakpointRejected";
          };
        };
        extensions = {
          dap-python.enable = true;
          dap-ui.enable = true;
          dap-virtual-text.enable = true;
        };
      };

      plugins.which-key.settings.spec = mkIf nixvim.plugins.which-key.enable [
        {
          __unkeyed-1 = "<leader>d";
          desc = "Debugger ";
        }
      ];
      keymaps = [
        {
          key = "<F5>";
          action = mkRaw "function() require('dap').continue() end";
          options = {
            desc = "Start debugger";
            silent = true;
          };
        }
        {
          # Shift-F5
          key = "<F17>";
          action = mkRaw "function() require('dap').terminate() end";
          options = {
            desc = "Stop debugger";
            silent = true;
          };
        }
        {
          # Shift-F9
          key = "<F21>";
          action = mkRaw ''
            function()
              vim.ui.input({ prompt = "Condition: " }, function(condition)
                        if condition then require("dap").set_breakpoint(condition) end end)
              end
          '';
          options = {
            desc = "Set conditional breakpoint";
            silent = true;
          };
        }
        {
          # Control-F5
          key = "<F29>";
          action = mkRaw "function() require('dap').restart_frame() end";
          options = {
            desc = "Restart debugger";
            silent = true;
          };
        }
        {
          key = "<F6>";
          action = mkRaw "function() require('dap').pause() end";
          options = {
            desc = "Pause debugger";
            silent = true;
          };
        }
        {
          key = "<F9>";
          action = mkRaw "function() require('dap').toggle_breakpoint() end";
          options = {
            desc = "Toggle breakpoint";
            silent = true;
          };
        }
        {
          key = "<F10>";
          action = mkRaw "function() require('dap').step_over() end";
          options = {
            desc = "Step over";
          };
        }
        {
          key = "<F11>";
          action = mkRaw "function() require('dap').step_into() end";
          options = {
            desc = "Step into";
            silent = true;
          };
        }
        {
          # Shift-F11
          key = "<F23>";
          action = mkRaw "function() require('dap').step_out() end";
          options = {
            desc = "Step out";
            silent = true;
          };
        }
        {
          key = "<leader>db";
          action = mkRaw "function() require('dap').toggle_breakpoint() end";
          options = {
            desc = "Toggle breakpoint (F9)";
            silent = true;
          };
        }
        {
          key = "<leader>dB";
          action = mkRaw "function() require('dap').clear_breakpoint() end";
          options = {
            desc = "Clear breakpoints";
            silent = true;
          };
        }
        {
          key = "<leader>dc";
          action = mkRaw "function() require('dap').continue() end";
          options = {
            desc = "Start/Continue (F5)";
            silent = true;
          };
        }
        {
          key = "<leader>dC";
          action = mkRaw ''
            function()
            vim.ui.input({ prompt = "Condition: " }, function(condition)
              if condition then require("dap").set_breakpoint(condition) end
             end)
             end
          '';
          options = {
            desc = "Conditional breakpoint (S-F9)";
            silent = true;
          };
        }
        {
          key = "<leader>do";
          action = mkRaw "function() require('dap').step_over() end";
          options = {
            desc = "Step over (F10)";
            silent = true;
          };
        }
        {
          key = "<leader>di";
          action = mkRaw "function() require('dap').step_into() end";
          options = {
            desc = "Step into (F11)";
            silent = true;
          };
        }
        {
          key = "<leader>dO";
          action = mkRaw "function() require('dap').step_out() end";
          options = {
            desc = "Step out (S-F11)";
            silent = true;
          };
        }
        {
          key = "<leader>dr";
          action = mkRaw "function() require('dap').restart_frame() end";
          options = {
            desc = "Restart debugger (C-F5)";
            silent = true;
          };
        }
        {
          key = "<leader>dp";
          action = mkRaw "function() require('dap').pause() end";
          options = {
            desc = "Pause debugger (F6)";
            silent = true;
          };
        }
        {
          key = "<leader>dq";
          action = mkRaw "function() require('dap').close() end";
          options = {
            desc = "Close session";
            silent = true;
          };
        }
        {
          key = "<leader>dQ";
          action = mkRaw "function() require('dap').terminate() end";
          options = {
            desc = "Terminate session (S-F5)";
            silent = true;
          };
        }

        {
          key = "<leader>dR";
          action = mkRaw "function() require('dap').repl.toggle() end";
          options = {
            desc = "Toggle repl";
            silent = true;
          };
        }
        {
          key = "<leader>ds";
          action = mkRaw "function() require('dap').run_to_cursor() end";
          options = {
            desc = "Run to cursor";
            silent = true;
          };
        }
        {
          key = "<leader>dE";
          action = mkRaw ''
            function()
              vim.ui.input({ prompt = "Expression: " },
                function(expr)
                  if expr then require("dapui").eval(expr, { enter = true }) end
                end)
                end
          '';
          options = {
            desc = "Evaluate expression";
            silent = true;
          };
        }
        {
          key = "<leader>dI";
          action = mkRaw "function() require('dapui').eval() end";
          options = {
            desc = "Evaluate input";
            silent = true;
          };
        }
        {
          key = "<leader>du";
          action = mkRaw "function() require('dapui').toggle() end";
          options = {
            desc = "Toggle debug ui";
            silent = true;
          };
        }
        {
          key = "<leader>dh";
          action = mkRaw "function() require('dap.ui.widgets').hover() end";
          options = {
            desc = "Debugger hover";
            silent = true;
          };
        }
      ];
    };
  };
}
