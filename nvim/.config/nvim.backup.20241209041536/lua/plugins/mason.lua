return {
    {
        "williamboman/mason.nvim",
        enabled = true,
        cmd = { "Mason", "MasonInstall", "MasonUpdate" },
        config = function(_, opts)
            require('mason').setup(opts)
        end
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = require "config.mason",
        dependencies = { "williamboman/mason.nvim" },
        cmd = {
            "MasonToolsInstall", "MasonToolsInstallSync",
            "MasonToolsUpdate", "MasonToolsUpdateSync",
            "MasonToolsClean",
        }
    }
}
