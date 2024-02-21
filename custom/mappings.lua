local M = {}

M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
    ["n"] = {"nzzzv", "zz after move to next find"},
    ["N"] = {"Nzzzv", "zz after move to prev find"},
    ["<CR>"] = {"ciw", "ciw in normal mode"},
  },
  v = {
    ["J"] = {":m '>+1<CR>gv=gv", "move selected lines up"},
    ["K"] = {":m '<-2<CR>gv=gv", "move selected lines down"},
  }
}

M.nvterm = {
  plugin = true,

  t = {
    ["<A-t>"] = {
      function()
        require("nvterm.terminal").toggle "horizontal"
      end,
      "toggle horizontal term",
    },
  },

  n = {
    -- toggle in normal mode

    ["<A-t>"] = {
      function()
        require("nvterm.terminal").toggle "horizontal"
      end,
      "toggle horizontal term",
    },
  },
}

M.dap = {
  plugin = true,
  n = {
    ["<leader>db"] = { "<cmd> DapToggleBreakpoint <CR>" },
    ["<leader>dus"] = {
      function ()
        local widgets = require('dap.ui.widgets');
        local sidebar = widgets.sidebar(widgets.scopes);
        sidebar.open();
      end,
      "Open debugging sidebar"
    }
  }
}

M.crates = {
  plugin = true,
  n = {
    ["<leader>rcu"] = {
      function ()
        require('crates').upgrade_all_crates()
      end,
      "update crates"
    }
  }
}

return M
