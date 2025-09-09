local UIManager = require("ui/uimanager")
local _ = require("gettext")
local InputDialog = require("ui/widget/inputdialog")
local apikeyset
local CONFIGURATION = ""
local success, result = pcall(function() return require("configuration") end)
if success then
    CONFIGURATION = result
else
    print("configuration.lua not found, skipping...")
end

-- Attempt to load the api_key module. IN A LATER VERSION, THIS WILL BE REMOVED
apikeyset = InputDialog:extend {
    name = 'apikeyset',
    title = _("Set API Key"),
    input = (CONFIGURATION.api_key ~= "" and CONFIGURATION.api_key or "Please Enter API Key"),
    buttons = {
        {
            {
                text = _("Cancel"),
                id = "close",
                callback = function()
                    UIManager:close(apikeyset)
                end,
            },
            {
                text = _("Save"),
                is_enter_default = true,
                callback = function()
                    UIManager:close(apikeyset)
                end,
            },
        }
    },
}


return apikeyset
