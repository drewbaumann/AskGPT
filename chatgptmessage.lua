local Blitbuffer = require("ffi/blitbuffer")
local CenterContainer = require("ui/widget/container/centercontainer")
local Device = require("device")
local FrameContainer = require("ui/widget/container/framecontainer")
local Geom = require("ui/geometry")
local GestureRange = require("ui/gesturerange")
local TextBoxWidget = require("ui/widget/textboxwidget")
local InputContainer = require("ui/widget/container/inputcontainer")
local UIManager = require("ui/uimanager")
local Input = Device.input
local Screen = Device.screen
local Size = require("ui/size")
local Font = require("ui/font")

local ChatGPTMessage = InputContainer:extend {
  modal = true,
  timeout = nil, -- in seconds
  text = nil,    -- The text to display.
  width = nil,   -- The width. Keep it nil to use original width.
  height = nil,  -- The height. Keep it nil to use original height.
  dismiss_callback = function()
  end,
}

function ChatGPTMessage:init()
  if Device:hasKeys() then
    self.key_events.AnyKeyPressed = { { Input.group.Any } }
  end
  if Device:isTouchDevice() then
    self.ges_events.TapClose = {
      GestureRange:new {
        ges = "tap",
        range = Geom:new {
          x = 0, y = 0,
          w = Screen:getWidth(),
          h = Screen:getHeight(),
        }
      }
    }
  end

  local answer_text_widget = TextBoxWidget:new {
    text = self.text,
    face = Font:getFace("cfont", 22),
    width = self.width or Device.screen:getWidth() * 0.9,
    height = self.height or Device.screen:getHeight() * 0.7,
  }

  local frame = FrameContainer:new {
    background = Blitbuffer.COLOR_WHITE,
    padding = Size.padding.fullscreen,
    answer_text_widget,
  }
  self[1] = CenterContainer:new {
    dimen = Screen:getSize(),
    frame,
  }
end

function ChatGPTMessage:onCloseWidget()
  UIManager:setDirty(nil, function()
    return "ui", self[1][1].dimen
  end)
end

function ChatGPTMessage:onShow()
  UIManager:setDirty(self, function()
    return "ui", self[1][1].dimen
  end)

  return true
end

function ChatGPTMessage:onTapClose()
  self.dismiss_callback()
  UIManager:close(self)
end

ChatGPTMessage.onAnyKeyPressed = ChatGPTMessage.onTapClose

return ChatGPTMessage
