local Device = require("device")
local InputContainer = require("ui/widget/container/inputcontainer")
local _ = require("gettext")

local showChatGPTDialog = require("dialogs")

local ChatGPTHighlight = InputContainer:new {
  name = "chatgpthighlight",
  is_doc_only = true,
}

function ChatGPTHighlight:init()
  self.ui.highlight:addToHighlightDialog("chatgpthighlight_ChatGPT", function(_reader_highlight_instance)
    return {
      text = _("Ask ChatGPT"),
      enabled = Device:hasClipboard(),
      callback = function()
        showChatGPTDialog(self.ui, _reader_highlight_instance.selected_text.text)
      end,
    }
  end)
end

return ChatGPTHighlight
