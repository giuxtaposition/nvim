return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix = "   ",
          selection_caret = "  ",
          entry_prefix = "  ",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
              results_width = 0.8,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          file_ignore_patterns = { "node_modules" },
          winblend = 0,
          border = {},
          borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          color_devicons = true,
          path_display = { "truncate " },
          mappings = {
            n = {
              ["q"] = actions.close,
            },
            i = {
              ["<C-k>"] = actions.move_selection_previous, -- move to prev result
              ["<C-j>"] = actions.move_selection_next, -- move to next result
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<C-f>"] = actions.preview_scrolling_down,
              ["<C-b>"] = actions.preview_scrolling_up,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            file_ignore_patterns = { "node_modules", ".git" },
          },
          live_grep = {
            additional_args = function(_)
              return { "--hidden" }
            end,
            file_ignore_patterns = { "node_modules", ".git" },
          },
        },
      })

      telescope.load_extension("fzf")
    end,
    keys = {
      {
        "<leader>,",
        "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",
        desc = "Switch Buffer",
      },
      -- find
      { "<leader>fb", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Buffers" },
      {
        "<leader>fc",
        function()
          require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
        end,
        desc = "Find Config File",
      },
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Fuzzy find files in cwd" },
      {
        "<leader>fo",
        "<cmd>Telescope oldfiles<cr>",
        desc = "Fuzzy find recent files",
      },
      { "<leader>fx", "<cmd>Telescope resume<cr>", desc = "Resume last telescope window" },

      -- git
      { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "commits" },
      { "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "status" },

      -- search
      { "<leader>sr", "<cmd>Telescope registers<cr>", desc = "List registers" },
      { "<leader>sg", "<cmd>Telescope live_grep<cr>", desc = "Find string in cwd" },
      { "<leader>sw", "<cmd>Telescope grep_string<cr>", desc = "Find string under cursor in cwd" },
      { "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
      { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Key Maps" },
    },
  },
}