return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    dependencies = {
      -- Useful status updates for LSP.
      { "j-hui/fidget.nvim", opts = {} },
    },
    opts = {
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              codeLens = {
                enable = true,
              },
              completion = {
                callSnippet = "Replace",
              },
              doc = {
                privateName = { "^_" },
              },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
            },
          },
        },
        vtsls = {
          keys = {
            {
              "gD",
              function()
                local params = vim.lsp.util.make_position_params()
                require("config.util").lsp.execute({
                  command = "typescript.goToSourceDefinition",
                  arguments = { params.textDocument.uri, params.position },
                  open = true,
                })
              end,
              "Goto Source Definition",
            },
            {
              "gR",
              function()
                require("config.util").lsp.execute({
                  command = "typescript.findAllFileReferences",
                  arguments = { vim.uri_from_bufnr(0) },
                  open = true,
                })
              end,
              "File References",
            },
            {
              "<leader>co",
              require("config.util").lsp.action["source.organizeImports"],
              "Organize Imports",
            },
            {
              "<leader>cM",
              require("config.util").lsp.action["source.addMissingImports.ts"],
              "Add missing imports",
            },
            {
              "<leader>cu",
              require("config.util").lsp.action["source.removeUnused.ts"],
              "Remove unused imports",
            },
            {
              "<leader>cD",
              require("config.util").lsp.action["source.fixAll.ts"],
              "Fix all diagnostics",
            },
            {
              "<leader>cV",
              function()
                require("config.util").lsp.execute({ command = "typescript.selectTypeScriptVersion" })
              end,
              "Select TS workspace version",
            },
          },
          filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
            "vue",
          },
          settings = {
            complete_function_calls = true,
            enableMoveToFileCodeAction = true,
            autoUseWorkspaceTsdk = true,
            experimental = {
              completion = {
                enableServerSideFuzzyMatch = true,
              },
            },
            javascript = {
              preferences = {
                importModuleSpecifier = "relative",
              },
            },
            typescript = {
              preferences = {
                importModuleSpecifier = "relative",
              },
              tsserver = {
                experimental = {
                  enableProjectDiagnostics = false, -- when true it always open all json in the project?
                },
              },
              updateImportsOnFileMove = { enabled = "always" },
              suggest = {
                completeFunctionCalls = true,
              },
              inlayHints = {
                enumMemberValues = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                parameterNames = { enabled = "literals" },
                parameterTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                variableTypes = { enabled = false },
              },
            },
          },
        },
        eslint = {
          settings = {
            workingDirectories = { mode = "auto" },
          },
        },
        volar = {
          init_options = {
            vue = {
              hybridMode = true,
            },
          },
        },
        svelte = {},
        html = {},
        cssls = {},
        emmet_ls = {},
        marksman = {},
        nil_ls = {
          settings = {
            ["nil"] = {
              formatting = {
                command = { "nixpkgs-fmt" },
              },
            },
          },
        },
        bashls = {},
      },
    },
    config = function(_, opts)
      local lspconfig = require("lspconfig")

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("giuxtaposition-lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, expr)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = desc, expr = expr, silent = true })
          end

          local diagnostic_goto = function(count, severity)
            severity = severity and vim.diagnostic.severity[severity] or nil
            return function()
              vim.diagnostic.jump({ count = count, severity = severity })
            end
          end

          map("gd", require("telescope.builtin").lsp_definitions, "Goto Definition") --  To jump back, press <C-t>.
          map("gD", vim.lsp.buf.declaration, "Goto Declaration")
          map("gr", require("telescope.builtin").lsp_references, "Goto References")
          map("gI", require("telescope.builtin").lsp_implementations, "Goto Implementation")
          map("gt", require("telescope.builtin").lsp_type_definitions, "Type Definition")
          map("<leader>cs", require("telescope.builtin").lsp_document_symbols, "Document Symbols")
          map("<leader>cS", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Workspace Symbols")
          map("<leader>cr", function()
            local inc_rename = require("inc_rename")
            return ":" .. inc_rename.config.cmd_name .. " " .. vim.fn.expand("<cword>")
          end, "Rename", true)
          map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
          map("<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", "Show buffer diagnostics")
          map("<leader>cd", vim.diagnostic.open_float, "Show line diagnostics")
          map("]d", diagnostic_goto(1), "Next Diagnostic")
          map("[d", diagnostic_goto(-1), "Prev Diagnostic")
          map("]e", diagnostic_goto(1, "ERROR"), "Next Error")
          map("[e", diagnostic_goto(-1, "ERROR"), "Prev Error")
          map("]w", diagnostic_goto(1, "WARN"), "Next Warning")
          map("[w", diagnostic_goto(-1, "WARN"), "Prev Warning")
          map("K", vim.lsp.buf.hover, "Show documentation for what is under cursor")
          map("<leader>rs", ":LspRestart<CR>", "Restart LSP")

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map("<leader>uh", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, "Toggle Inlay Hints")
          end
        end,
      })

      vim.diagnostic.config({
        underline = true,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = require("config.icons").diagnostics.prefix,
        },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = require("config.icons").diagnostics.error,
            [vim.diagnostic.severity.WARN] = require("config.icons").diagnostics.warn,
            [vim.diagnostic.severity.HINT] = require("config.icons").diagnostics.hint,
            [vim.diagnostic.severity.INFO] = require("config.icons").diagnostics.info,
          },
        },
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()

      local function setup(server)
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
        }, opts.servers[server] or {})
        if server_opts.enabled == false then
          return
        end

        if server_opts.keys then
          server_opts.on_attach = function(client, bufnr)
            local map = function(keys, func, desc)
              vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
            end

            for _, value in pairs(server_opts.keys) do
              map(value[1], value[2], value[3])
            end
          end
        end

        lspconfig[server].setup(server_opts)
      end

      for server in pairs(opts.servers) do
        setup(server)
      end
    end,
  },
  {
    "mrcjkb/rustaceanvim",
    version = "^5", -- Recommended
    lazy = false, -- This plugin is already lazy
  },
}
