local dap, dapui = require("dap"), require("dapui")
dapui.setup()



dap.adapters.gdb = {
  type = "executable",
  command = "gdb",
  args = { "-i", "dap" }
}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

dap.configurations.c = {
  {
    name = "Launch",
    type = "gdb",
    request = "launch",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = "${workspaceFolder}",
  },
  {
    name = "Attach",
    type = "gdb",
    request = "attach",
    program = function()
      return require('dap.utils').pick_process
    end,
    cwd = "${workspaceFolder}",
  },
  {
    name = "Launch an executable",
    type = "gdb",
    request = "launch",
    program = function()
      return coroutine.create(function(coro)
        local opts = {}
        pickers
            .new(opts, {
              prompt_title = "Path to executable",
              finder = finders.new_oneshot_job({ "fd", "--hidden", "--no-ignore", "--type", "x" }, {}),
              sorter = conf.generic_sorter(opts),
              attach_mappings = function(buffer_number)
                actions.select_default:replace(function()
                  actions.close(buffer_number)
                  coroutine.resume(coro, action_state.get_selected_entry()[1])
                end)
                return true
              end,
            })
            :find()
      end)
    end,
  },
}
dap.configurations.h = dap.configurations.c;
dap.configurations.cpp = dap.configurations.c;
dap.configurations.hpp = dap.configurations.c;



dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
  dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  dapui.close()
end




local opts = {
  mode = "n",     -- NORMAL mode
  prefix = "<leader>",
  buffer = nil,   -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true,  -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true,  -- use `nowait` when creating keymaps
}
local bug = "󰨮";

local mappings = {


  ["<F5>"] = { function() require("dap").continue() end, "Debugger: Start" },
  ["<F17>"] = { function() require("dap").terminate() end, "Debugger: Stop" }, -- Shift+F5
  ["<F21>"] = {                                                                -- Shift+F9
    function()
      vim.ui.input({ prompt = "Condition: " }, function(condition)
        if condition then require("dap").set_breakpoint(condition) end
      end)
    end,
    "Debugger: Conditional Breakpoint",
  },
  ["<F29>"] = { function() require("dap").restart_frame() end, "Debugger: Restart" }, -- Control+F5
  ["<F6>"] = { function() require("dap").pause() end, "Debugger: Pause" },
  ["<F9>"] = { function() require("dap").toggle_breakpoint() end, "Debugger: Toggle Breakpoint" },
  ["<F10>"] = { function() require("dap").step_over() end, "Debugger: Step Over" },
  ["<F11>"] = { function() require("dap").step_into() end, "Debugger: Step Into" },
  ["<F23>"] = { function() require("dap").step_out() end, "Debugger: Step Out" }, -- Shift+F11
  d = {
    name = bug .. "Debugger",
    b = { function() require("dap").toggle_breakpoint() end, "Toggle Breakpoint (F9)" },
    B = { function() require("dap").clear_breakpoints() end, "Clear Breakpoints" },
    c = { function() require("dap").continue() end, "Start/Continue (F5)" },
    C = {
      function()
        vim.ui.input({ prompt = "Condition: " }, function(condition)
          if condition then require("dap").set_breakpoint(condition) end
        end)
      end, "Conditional Breakpoint (S-F9)",
    },
    i = { function() require("dap").step_into() end, "Step Into (F11)" },
    o = { function() require("dap").step_over() end, "Step Over (F10)" },
    O = { function() require("dap").step_out() end, "Step Out (S-F11)" },
    q = { function() require("dap").close() end, "Close Session" },
    Q = { function() require("dap").terminate() end, "Terminate Session (S-F5)" },
    p = { function() require("dap").pause() end, "Pause (F6)" },
    r = { function() require("dap").restart_frame() end, "Restart (C-F5)" },
    R = { function() require("dap").repl.toggle() end, "Toggle REPL" },
    s = { function() require("dap").run_to_cursor() end, "Run To Cursor" },
    E = {
      function()
        vim.ui.input({ prompt = "Expression: " }, function(expr)
          if expr then require("dapui").eval(expr, { enter = true }) end
        end)
      end, "Evaluate Input",
    },

  },
  E = { function() require("dapui").eval() end, "Evaluate Input" },
  u = { function() require("dapui").toggle() end, "Toggle Debugger UI" },
  h = { function() require("dap.ui.widgets").hover() end, "Debugger Hover" },
}

require("which-key").register(mappings, opts)
