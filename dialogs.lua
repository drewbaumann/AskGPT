local TextViewer = require("ui/widget/textviewer")
local InputDialog = require("ui/widget/inputdialog")
local UIManager = require("ui/uimanager")
local _ = require("gettext")

local queryChatGPT = require("gpt_query")

local function showChatGPTDialog(ui, highlightedText)
  local title, author =
      ui.document:getProps().title or _("Unknown Title"),
      ui.document:getProps().authors or _("Unknown Author")
  local input_dialog
  input_dialog = InputDialog:new {
    title = _("Ask a question about the highlighted text"),
    input_hint = _("Type your question here..."),
    input_type = "text",
    buttons = {
      {
        {
          text = _("Cancel"),
          callback = function()
            UIManager:close(input_dialog)
          end,
        },
        {
          text = _("Submit"),
          callback = function()
            local question = input_dialog:getInputText()
            local answer = queryChatGPT(highlightedText, question, title, author)
            UIManager:close(input_dialog)
            local result_text = _("Highlighted text: ") .. "\"" .. highlightedText .. "\"" ..
                "\n\n" .. _("Question: ") .. question ..
                "\n\n" .. _("Answer: ") .. answer
            UIManager:show(TextViewer:new {
              title = _("ChatGPT Response"),
              text = result_text,
            })
          end,
        },
      },
    },
  }
  UIManager:show(input_dialog)
  input_dialog:onShowKeyboard()
end

return showChatGPTDialog
