-- If you started neovim within `~/dev/xy/project-1` this would resolve to `project-1`
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

local workspace_dir = "/home/camilo/Workspace/" .. project_name

-- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
local config = {
  -- The command that starts the language server
  -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
  cmd = {

    -- 💀
    "java", -- or '/path/to/java17_or_newer/bin/java'
    -- depends on if `java` is in your $PATH env variable and if it points to the right version.

    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xms1g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",

    -- 💀
    "-jar",
    "/home/camilo/.config/jdtls/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar",
    -- "/path/to/jdtls_install_location/plugins/org.eclipse.equinox.launcher_VERSION_NUMBER.jar",
    -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                                       ^^^^^^^^^^^^^^
    -- Must point to the                                                     Change this to
    -- eclipse.jdt.ls installation                                           the actual version

    -- 💀
    "-configuration",
    "/home/camilo/.config/jdtls/config_linux/",
    -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^        ^^^^^^
    -- Must point to the                      Change to one of `linux`, `win` or `mac`
    -- eclipse.jdt.ls installation            Depending on your system.

    -- 💀
    -- See `data directory configuration` section in the README
    "-data",
    workspace_dir,
  },

  -- 💀
  -- This is the default if not provided, you can remove it. Or adjust as needed.
  -- One dedicated LSP server & client will be started per unique root_dir
  root_dir = require("jdtls.setup").find_root { ".git", "mvnw", "gradlew", "build.gradle" },

  -- Here you can configure eclipse.jdt.ls specific settings
  -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  -- for a list of options
  settings = {
    java = {
      -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
      -- And search for `interface RuntimeOption`
      -- The `name` is NOT arbitrary, but must match one of the elements from `enum ExecutionEnvironment` in the link above
      runtimes = {
        {
          name = "JavaSE-18",
          path = "/usr/lib/jvm/java-18-openjdk/",
        },
      },
    },
  },

  -- Language server `initializationOptions`
  -- You need to extend the `bundles` with paths to jar files
  -- if you want to use additional eclipse.jdt.ls plugins.
  --
  -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
  --
  -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
  init_options = {
    bundles = {
      vim.fn.glob(
        "/home/camilo/Documents/git/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar",
        1
      ),
    },
  },
}

config["on_attach"] = function(client, bufnr)
  -- With `hotcodereplace = 'auto' the debug adapter will try to apply code changes
  -- you make during a debug session immediately.
  -- Remove the option if you do not want that.
  -- You can use the `JdtHotcodeReplace` command to trigger it manually
  require("jdtls").setup_dap { hotcodereplace = "auto" }
end

local bundles = {
  vim.fn.glob(
    "/home/camilo/Documents/git/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar",
    1
  ),
}

vim.list_extend(bundles, vim.split(vim.fn.glob("/home/camilo/Documents/git/vscode-java-test/server/*.jar", 1), "\n"))
config["init_options"] = {
  bundles = bundles,
}

-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
require("jdtls").start_or_attach(config)

local status_ok, which_key = pcall(require, "which-key")
if not status_ok then return end

local opts = {
  mode = "n", -- NORMAL mode
  prefix = "<leader>",
  buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true, -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true, -- use `nowait` when creating keymaps
}

local mappings = {
  L = {
    name = "Java",
    o = { "<Cmd>lua require'jdtls'.organize_imports()<CR>", "Organize Imports" },
    v = { "<Cmd>lua require('jdtls').extract_variable()<CR>", "Extract Variable" },
    c = { "<Cmd>lua require('jdtls').extract_constant()<CR>", "Extract Constant" },
    t = { "<Cmd>lua require'jdtls'.test_nearest_method()<CR>", "Test Method" },
    T = { "<Cmd>lua require'jdtls'.test_class()<CR>", "Test Class" },
    u = { "<Cmd>JdtUpdateConfig<CR>", "Update Config" },
  },
  l = {
    name = "LSP",
    a = { "<Cmd> lua vim.lsp.buf.code_action() <CR>", "LSP code action" },
    f = { "<Cmd> lua vim.lsp.buf.formatting_sync() <CR>", "Format code" },
    h = { "<Cmd> lua vim.lsp.buf.signature_help() <CR>", "Signature help" },
    r = { "<Cmd> lua vim.lsp.buf.rename() <CR>", "Rename current symbol" },
    d = { "<Cmd> lua vim.diagnostic.open_float() <CR>", "Hover diagnostics" },
  },
  K = { "<Cmd> lua vim.lsp.buf.hover() <CR>", "Hover symbol details" },
  gD = { "<Cmd> lua vim.lsp.buf.declaration() <CR>", "Declaration of current symbol" },
  gT = { "<Cmd> vim.lsp.buf.type_definition() <CR>", "Definition of current type" },
  gI = { "<Cmd> vim.lsp.buf.implementation() <CR>", "Implementation of current symbol" },
  gd = { "<Cmd> vim.lsp.buf.definition() <CR>", "Show the definition of current symbol" },
  gr = { "<Cmd> vim.lsp.buf.references() <CR>", "References of current symbol" },
  gl = { "<Cmd> vim.diagnostic.open_float() <CR>", "Hover diagnostics" },
}

which_key.register(mappings, opts)
