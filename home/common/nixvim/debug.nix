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
  cfg = config.baseline.nixvim.debug;
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

      plugins.which-key.registrations."<leader>d" = "󰨮 Debugger ";

      keymaps = [
        {
          key = "<F5>";
          action = "function() require('dap').continue() end";
          lua = true;
          options = {
            desc = "Start debugger";
            silent = true;
          };
        }
        {
          # Shift-F5
          key = "<F17>";
          action = "function() require('dap').terminate() end";
          lua = true;
          options = {
            desc = "Stop debugger";
            silent = true;
          };
        }
        {
          # Shift-F9
          key = "<F21>";
          action = ''
            function()
              vim.ui.input({ prompt = "Condition: " }, function(condition)
                        if condition then require("dap").set_breakpoint(condition) end end)
              end
          '';
          lua = true;
          options = {
            desc = "Set conditional breakpoint";
            silent = true;
          };
        }
        {
          # Control-F5
          key = "<F29>";
          action = "function() require('dap').restart_frame() end";
          lua = true;
          options = {
            desc = "Restart debugger";
            silent = true;
          };
        }
        {
          key = "<F6>";
          action = "function() require('dap').pause() end";
          lua = true;
          options = {
            desc = "Pause debugger";
            silent = true;
          };
        }
        {
          key = "<F9>";
          action = "function() require('dap').toggle_breakpoint() end";
          lua = true;
          options = {
            desc = "Toggle breakpoint";
            silent = true;
          };
        }
        {
          key = "<F10>";
          action = "function() require('dap').step_over() end";
          lua = true;
          options = {
            desc = "Step over";
          };
        }
        {
          key = "<F11>";
          action = "function() require('dap').step_into() end";
          lua = true;
          options = {
            desc = "Step into";
            silent = true;
          };
        }
        {
          # Shift-F11
          key = "<F23>";
          action = "function() require('dap').step_out() end";
          lua = true;
          options = {
            desc = "Step out";
            silent = true;
          };
        }
        {
          key = "<leader>db";
          action = "function() require('dap').toggle_breakpoint() end";
          lua = true;
          options = {
            desc = "Toggle breakpoint (F9)";
            silent = true;
          };
        }
        {
          key = "<leader>dB";
          action = "function() require('dap').clear_breakpoint() end";
          lua = true;
          options = {
            desc = "Clear breakpoints";
            silent = true;
          };
        }
        {
          key = "<leader>dc";
          action = "function() require('dap').continue() end";
          lua = true;
          options = {
            desc = "Start/Continue (F5)";
            silent = true;
          };
        }
        {
          key = "<leader>dC";
          action = ''
            function()
            vim.ui.input({ prompt = "Condition: " }, function(condition)
              if condition then require("dap").set_breakpoint(condition) end
             end)
             end
          '';
          lua = true;
          options = {
            desc = "Conditional breakpoint (S-F9)";
            silent = true;
          };
        }
        {
          key = "<leader>do";
          action = "function() require('dap').step_over() end";
          lua = true;
          options = {
            desc = "Step over (F10)";
            silent = true;
          };
        }
        {
          key = "<leader>di";
          action = "function() require('dap').step_into() end";
          lua = true;
          options = {
            desc = "Step into (F11)";
            silent = true;
          };
        }
        {
          key = "<leader>dO";
          action = "function() require('dap').step_out() end";
          lua = true;
          options = {
            desc = "Step out (S-F11)";
            silent = true;
          };
        }
        {
          key = "<leader>dr";
          action = "function() require('dap').restart_frame() end";
          lua = true;
          options = {
            desc = "Restart debugger (C-F5)";
            silent = true;
          };
        }
        {
          key = "<leader>dp";
          action = "function() require('dap').pause() end";
          lua = true;
          options = {
            desc = "Pause debugger (F6)";
            silent = true;
          };
        }
        {
          key = "<leader>dq";
          action = "function() require('dap').close() end";
          lua = true;
          options = {
            desc = "Close session";
            silent = true;
          };
        }
        {
          key = "<leader>dQ";
          action = "function() require('dap').terminate() end";
          lua = true;
          options = {
            desc = "Terminate session (S-F5)";
            silent = true;
          };
        }

        {
          key = "<leader>dR";
          action = "function() require('dap').repl.toggle() end";
          lua = true;
          options = {
            desc = "Toggle repl";
            silent = true;
          };
        }
        {
          key = "<leader>ds";
          action = "function() require('dap').run_to_cursor() end";
          lua = true;
          options = {
            desc = "Run to cursor";
            silent = true;
          };
        }
        {
          key = "<leader>dE";
          action = ''
            function()
              vim.ui.input({ prompt = "Expression: " },
                function(expr)
                  if expr then require("dapui").eval(expr, { enter = true }) end
                end)
                end
          '';
          lua = true;
          options = {
            desc = "Evaluate expression";
            silent = true;
          };
        }
        {
          key = "<leader>dI";
          action = "function() require('dapui').eval() end";
          lua = true;
          options = {
            desc = "Evaluate input";
            silent = true;
          };
        }
        {
          key = "<leader>du";
          action = "function() require('dapui').toggle() end";
          lua = true;
          options = {
            desc = "Toggle debug ui";
            silent = true;
          };
        }
        {
          key = "<leader>dh";
          action = "function() require('dap.ui.widgets').hover() end";
          lua = true;
          options = {
            desc = "Debugger hover";
            silent = true;
          };
        }
      ];
    };
  };
}
