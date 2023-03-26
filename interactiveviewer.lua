local TextViewer = require("ui/widget/textviewer")
local UIManager = require("ui/uimanager")
local _ = require("gettext")
local InputDialog = require("ui/widget/inputdialog")

local InteractiveViewer = TextViewer:extend {
  title = _("InteractiveViewer"),
  is_interactive = true,
}

function InteractiveViewer:init()
  TextViewer.init(self) -- Call the parent class's init() method
  self.buttons = {
    {
      text = _("Ask Another Question"),
      callback = function()
        self:askAnotherQuestion()
      end,
    },
    {
      text = _("Close"),
      callback = function()
        UIManager:close(self)
      end,
    },
  }
  if self.onAskQuestion then
    self.ask_question_callback = function(question)
      -- Pass the instance (self) to the callback function
      self.onAskQuestion(self, question)
    end
  end
end

function InteractiveViewer:update()
  TextViewer.update(self) -- Call the parent class's update() method
end

function InteractiveViewer:askAnotherQuestion()
  local input_dialog
  input_dialog = InputDialog:new {
    title = _("Ask another question"),
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
            self:onAskQuestion(question)
            UIManager:close(input_dialog)
          end,
        },
      },
    },
  }
  UIManager:show(input_dialog)
  input_dialog:onShowKeyboard()
end

function InteractiveViewer:onAskQuestion(question)
  -- This method should be overridden by the caller.
end

return InteractiveViewer
