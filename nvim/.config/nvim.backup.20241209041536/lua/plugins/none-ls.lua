return {
    {
        "nvimtools/none-ls.nvim",
        enabled = false,
        opts = function()
            return require("config.null-ls")
        end,
    },
}
