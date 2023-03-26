local InputDialog = require("ui/widget/inputdialog")
local TextViewer = require("ui/widget/textviewer")
local InteractiveViewer = require("interactiveviewer")
local UIManager = require("ui/uimanager")
local _ = require("gettext")

local queryChatGPT = require("gpt_query")

local function showChatGPTDialog(ui, highlightedText, message_history)
  local title, author =
      ui.document:getProps().title or _("Unknown Title"),
      ui.document:getProps().authors or _("Unknown Author")
  local message_history = message_history or {
    {
      role = "system",
      content =
      "The following is a conversation with an AI assistant. The assistant is helpful, creative, clever, and very friendly. Answer as concisely as possible.",
    },
  }
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
            local InfoMessage = require("ui/widget/infomessage")
            local loading = InfoMessage:new {
              text = _("Loading..."),
              timeout = 1,
            }
            UIManager:show(loading)

            -- Give context to the question
            local context_message = {
              role = "user",
              content = "I'm reading something titled '" ..
                  title ..
                  "' by " .. author .. ". I have a question about the following highlighted text: " .. highlightedText,
            }
            table.insert(message_history, context_message)

            -- Ask the question
            local question = input_dialog:getInputText()
            local question_message = {
              role = "user",
              content = question,
            }
            table.insert(message_history, question_message)

            local answer = queryChatGPT(message_history)
            -- Save the answer to the message history
            local answer_message = {
              role = "assistant",
              content = answer,
            }

            table.insert(message_history, answer_message)
            UIManager:close(input_dialog)
            local result_text = _("Highlighted text: ") .. "\"" .. highlightedText .. "\"" ..
                "\n\n" .. _("Question: ") .. question ..
                "\n\n" .. _("Answer: ") .. answer

            local function createResultText(highlightedText, message_history)
              local result_text = _("Highlighted text: ") .. "\"" .. highlightedText .. "\"\n\n"

              for _, message in ipairs(message_history) do
                if message.role == "user" then
                  result_text = result_text .. _("Question: ") .. message.content .. "\n\n"
                else
                  result_text = result_text .. _("Answer: ") .. message.content .. "\n\n"
                end
              end

              return result_text
            end

            local function handleNewQuestion(interactive_viewer, question)
              -- Add the new question to the message history
              table.insert(message_history, { role = "user", content = question })

              -- Send the query to ChatGPT with the updated message_history
              local answer = queryChatGPT(message_history)

              -- Add the answer to the message history
              table.insert(message_history, { role = "assistant", content = answer })

              -- Update the result text
              local result_text = createResultText(highlightedText, message_history)

              -- Update the text and refresh the viewer
              interactive_viewer.text = result_text
              interactive_viewer:update()
            end

            local interactive_viewer = InteractiveViewer:new {
              title = _("ChatGPT Response"),
              text = result_text,
              onAskQuestion = handleNewQuestion, -- Pass the callback function
            }

            UIManager:show(interactive_viewer)
          end,
        },
      },
    },
  }
  UIManager:show(input_dialog)
  input_dialog:onShowKeyboard()
end

return showChatGPTDialog
