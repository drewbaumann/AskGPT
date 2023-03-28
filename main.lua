local Device = require("device")
local InputContainer = require("ui/widget/container/inputcontainer")
local _ = require("gettext")

local showChatGPTDialog = require("dialogs")

local AskGPT = InputContainer:new {
  name = "askgpt",
  is_doc_only = true,
}

function AskGPT:init()
  self.ui.highlight:addToHighlightDialog("askgpt_ChatGPT", function(_reader_highlight_instance)
    return {
      text = _("Ask ChatGPT"),
      enabled = Device:hasClipboard(),
      callback = function()
        showChatGPTDialog(self.ui, _reader_highlight_instance.selected_text.text)
      end,
    }
  end)
end

return AskGPT
