local Device = require("device")
local InputContainer = require("ui/widget/container/inputcontainer")
local NetworkMgr = require("ui/network/manager")
local _ = require("gettext")
local UIManager = require("ui/uimanager")
local queryChatGPT = require("gpt_query")
local Dispatcher = require("dispatcher")
local showChatGPTDialog = require("dialogs")
local UpdateChecker = require("update_checker")
local InfoMessage = require("ui/widget/infomessage")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local apikeyset = require("apikeyset")




local AskGPTSettings = WidgetContainer:extend {
  name = 'askgptsettings',
}

function AskGPTSettings:init()
  if not self.ui or not self.ui.menu then return end
  self.ui.menu:registerToMainMenu(self)
end

function AskGPTSettings:addToMainMenu(menu_items)
  menu_items.askgpt_settings = {
    text = _("Ask GPT Settings"),
    sorting_hint = "more_tools",
    keep_menu_open = true,
    callback = function()
      local apikeyset = apikeyset:new {
        title = _("Market View"),
        text = _("Input a ticker symbol"),
      }
      UIManager:show(apikeyset)
    end
  }
end

local AskGPT = InputContainer:new {
  name = "askgpt",
  is_doc_only = true,
}
-- Flag to ensure the update message is shown only once per session
local updateMessageShown = false

function AskGPT:init()
  self.ui.highlight:addToHighlightDialog("askgpt_ChatGPT", function(_reader_highlight_instance)
    return {
      text = _("Ask ChatGPT"),
      enabled = Device:hasClipboard(),
      callback = function()
        NetworkMgr:runWhenOnline(function()
          if not updateMessageShown then
            UpdateChecker.checkForUpdates()
            updateMessageShown = true -- Set flag to true so it won't show again
          end
          showChatGPTDialog(self.ui, _reader_highlight_instance.selected_text.text)
        end)
      end,
    }
  end)
  self.ui.highlight:addToHighlightDialog("askgpt_QuickAsk", function(_reader_highlight_instance)
    return {
      text = _("Dict Quick Ask"),
      enabled = Device:hasClipboard(),
      callback = function()
        NetworkMgr:runWhenOnline(function()
          if not updateMessageShown then
            UpdateChecker.checkForUpdates()
            updateMessageShown = true -- Set flag to true so it won't show again
          end
          QuerySingleWord(_reader_highlight_instance.selected_text.text, self.ui.document:getProps().title)
        end)
      end,
    }
  end)
end

function AskGPT:onDictButtonsReady(dict_popup, buttons)
  if dict_popup.is_wiki_fullpage then
    return
  else
    if buttons[2] then
      table.insert(buttons[2], 1, { -- Insert inside the first button group
        id = "GPTDefinition",
        text = _("askChat"),
        font_bold = true,
        callback = function()
          NetworkMgr:runWhenOnline(function()
            if not updateMessageShown then
              UpdateChecker.checkForUpdates()
              updateMessageShown = true
            end
            QuerySingleWord(dict_popup.word, self.ui.document:getProps().title)
          end)
        end
      })
    end
  end
end

function QuerySingleWord(queryWord, title)
  local InfoMessage = require("ui/widget/infomessage")
  local systemDialog = {
    role = "system",
    content = "You are a helpful translation assistant. Provide direct translations without additional commentary."
  }
  local queryDialog = { systemDialog, {
    role = "user",
    content = "What is the definition of this word: " .. queryWord .. " given that the name of the book is: " .. title
  } }
  local loading = InfoMessage:new {
    text = _("Loading..."),
    timeout = 0.1
  }
  UIManager:show(loading)
  UIManager:scheduleIn(0.1, function()
    UIManager:show(InfoMessage:new {
      text = _(queryChatGPT(queryDialog)),
    })
  end)
end

return AskGPTSettings, AskGPT
