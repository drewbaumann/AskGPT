local InputDialog = require("ui/widget/inputdialog")
local ChatGPTViewer = require("chatgptviewer")
local UIManager = require("ui/uimanager")
local InfoMessage = require("ui/widget/infomessage")
local _ = require("gettext")

local queryChatGPT = require("gpt_query")

local CONFIGURATION = nil
local success, result = pcall(function() return require("configuration") end)
if success then
  CONFIGURATION = result
else
  print("configuration.lua not found, skipping...")
end

local function translateText(text, target_language)
  local translation_message = {
    role = "user",
    content = "Translate the following text to " .. target_language .. ": " .. text
  }
  local translation_history = {
    {
      role = "system",
      content = "You are a helpful translation assistant. Provide direct translations without additional commentary."
    },
    translation_message
  }
  return queryChatGPT(translation_history)
end

local function createResultText(highlightedText, message_history)
  local result_text = _("Highlighted text: ") .. "\"" .. highlightedText .. "\"\n\n"

  for i = 3, #message_history do
    if message_history[i].role == "user" then
      result_text = result_text .. _("User: ") .. message_history[i].content .. "\n\n"
    else
      result_text = result_text .. _("ChatGPT: ") .. message_history[i].content .. "\n\n"
    end
  end

  return result_text
end

local function showLoadingDialog()
  local loading = InfoMessage:new{
    text = _("Loading..."),
    timeout = 0.1
  }
  UIManager:show(loading)
end

local function showChatGPTDialog(ui, highlightedText, message_history)
  local title, author =
    ui.document:getProps().title or _("Unknown Title"),
    ui.document:getProps().authors or _("Unknown Author")
  local message_history = message_history or {{
    role = "system",
    content = "The following is a conversation with an AI assistant. The assistant is helpful, creative, clever, and very friendly. Answer as concisely as possible."
  }}

  local function handleNewQuestion(chatgpt_viewer, question)
    -- Add the new question to the message history
    table.insert(message_history, {
      role = "user",
      content = question
    })

    -- Send the query to ChatGPT with the updated message_history
    local answer = queryChatGPT(message_history)

    -- Add the answer to the message history
    table.insert(message_history, {
      role = "assistant",
      content = answer
    })

    -- Update the result text
    local result_text = createResultText(highlightedText, message_history)

    -- Update the text and refresh the viewer
    chatgpt_viewer:update(result_text)
  end

  local input_dialog
  input_dialog = InputDialog:new{
    title = _("Ask a question about the highlighted text"),
    input_hint = _("Type your question here..."),
    input_type = "text",
    buttons = {{{
      text = _("Cancel"),
      callback = function()
        UIManager:close(input_dialog)
      end
    }, {
      text = _("Ask"),
      callback = function()
        local question = input_dialog:getInputText()
        UIManager:close(input_dialog)
        showLoadingDialog()

        -- do the actual work after a short delay to allow the loading dialog to show
        UIManager:scheduleIn(0.1, function()
          -- Give context to the question
          local context_message = {
            role = "user",
            content = "I'm reading something titled '" .. title .. "' by " .. author ..
              ". I have a question about the following highlighted text: " .. highlightedText
          }
          table.insert(message_history, context_message)

          -- Ask the question
          local question_message = {
            role = "user",
            content = question
          }
          table.insert(message_history, question_message)

          local answer = queryChatGPT(message_history)
          -- Save the answer to the message history
          local answer_message = {
            role = "assistant",
            content = answer
          }
          table.insert(message_history, answer_message)

          local result_text = createResultText(highlightedText, message_history)

          local chatgpt_viewer = ChatGPTViewer:new {
            title = _("AskGPT"),
            text = result_text,
            onAskQuestion = handleNewQuestion
          }

          UIManager:show(chatgpt_viewer)
        end)
      end
    }, {
      text = _("Translate"),
      callback = function()
        showLoadingDialog()

        UIManager:scheduleIn(0.1, function()
          local translated_text
          if CONFIGURATION and CONFIGURATION.features and CONFIGURATION.features.language then
            translated_text = translateText(highlightedText, CONFIGURATION.features.language)
          else
            translated_text = _("Translation configuration not found.")
          end

          -- Add the translation request to message history
          table.insert(message_history, {
            role = "user",
            content = "Translate to " .. (CONFIGURATION.features.language or "unknown language") .. ": " .. highlightedText
          })

          -- Add the translation response to message history
          table.insert(message_history, {
            role = "assistant",
            content = translated_text
          })

          local result_text = createResultText(highlightedText, message_history)
          local chatgpt_viewer = ChatGPTViewer:new {
            title = _("Translation"),
            text = result_text,
            onAskQuestion = handleNewQuestion
          }

          UIManager:show(chatgpt_viewer)
        end)
      end
    }}}
  }
  UIManager:show(input_dialog)
end

return showChatGPTDialog