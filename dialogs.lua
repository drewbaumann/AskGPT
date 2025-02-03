local InputDialog = require("ui/widget/inputdialog")
local ChatGPTViewer = require("chatgptviewer")
local UIManager = require("ui/uimanager")
local InfoMessage = require("ui/widget/infomessage")
local _ = require("gettext")

local queryChatGPT = require("gpt_query")

local CONFIGURATION = nil
local buttons, input_dialog

local success, result = pcall(function() return require("configuration") end)
if success then
  CONFIGURATION = result
else
  print("configuration.lua not found, skipping...")
end

local function translateText(text)
  if not text or text == "" then
    return _("Error: No text provided for translation")
  end

  local translation_prompt = CONFIGURATION 
    and CONFIGURATION.features 
    and CONFIGURATION.features.custom_prompts 
    and CONFIGURATION.features.custom_prompts.translation
    or "You are a skilled translator and language expert. First explain the meaning of the text in the original language, then provide an accurate translation to English."

  local translation_message = {
    role = "user",
    content = "For the following text:\n\n\"" .. text .. "\"\n\n1. First explain what this means/expresses in the original language\n2. Then translate it as specified in your instructions"
  }
  local translation_history = {
    {
      role = "system",
      content = translation_prompt
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
  if not highlightedText or highlightedText == "" then
    UIManager:show(InfoMessage:new{
      text = _("Please highlight some text first."),
    })
    return
  end

  local title, author =
    ui.document:getProps().title or _("Unknown Title"),
    ui.document:getProps().authors or _("Unknown Author")
  
  local default_prompt = "The following is a conversation with an AI assistant. The assistant is helpful, creative, clever, and very friendly. Answer as concisely as possible."
  local system_prompt = CONFIGURATION 
    and CONFIGURATION.features 
    and CONFIGURATION.features.custom_prompts 
    and CONFIGURATION.features.custom_prompts.system
    or default_prompt

  local message_history = message_history or {{
    role = "system",
    content = system_prompt
  }}

  local function handleNewQuestion(chatgpt_viewer, question)
    table.insert(message_history, {
      role = "user",
      content = question
    })

    local answer = queryChatGPT(message_history)

    table.insert(message_history, {
      role = "assistant",
      content = answer
    })

    local result_text = createResultText(highlightedText, message_history)

    chatgpt_viewer:update(result_text)
  end

  buttons = {
    {
      text = _("Cancel"),
      callback = function()
        UIManager:close(input_dialog)
      end
    },
    {
      text = _("Ask"),
      callback = function()
        local question = input_dialog:getInputText()
        UIManager:close(input_dialog)
        showLoadingDialog()

        UIManager:scheduleIn(0.1, function()
          local context_message = {
            role = "user",
            content = "I'm reading something titled '" .. title .. "' by " .. author .. 
              ". I have a question about the following highlighted text: " .. highlightedText
          }
          table.insert(message_history, context_message)

          local question_message = {
            role = "user",
            content = question
          }
          table.insert(message_history, question_message)

          local answer = queryChatGPT(message_history)
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
    }
  }

  -- Add buttons for each custom prompt
  if CONFIGURATION and CONFIGURATION.features and CONFIGURATION.features.custom_prompts then
    for prompt_name, prompt in pairs(CONFIGURATION.features.custom_prompts) do
      if prompt_name ~= "system" and type(prompt) == "string" then  -- Ensure prompt is valid
        table.insert(buttons, {
          text = _(prompt_name:gsub("^%l", string.upper)),  -- Capitalize first letter
          callback = function()
            showLoadingDialog()

            UIManager:scheduleIn(0.1, function()
              message_history = {  -- Reset message history for new prompt
                {
                  role = "system",
                  content = prompt
                },
                {
                  role = "user",
                  content = "I'm reading something titled '" .. title .. "' by " .. author .. 
                    "'. Here's the text I want you to process: " .. highlightedText
                }
              }
              
              local success, response = pcall(queryChatGPT, message_history)
              
              if not success then
                UIManager:show(InfoMessage:new{
                  text = _("Error: Failed to get response from ChatGPT"),
                })
                return
              end

              table.insert(message_history, { 
                role = "assistant", 
                content = response 
              })

              local result_text = createResultText(highlightedText, message_history)

              local chatgpt_viewer = ChatGPTViewer:new {
                title = _(prompt_name:gsub("^%l", string.upper)),
                text = result_text,
                onAskQuestion = handleNewQuestion
              }

              UIManager:show(chatgpt_viewer)
            end)
          end
        })
      end
    end
  end

  input_dialog = InputDialog:new{
    title = _("Ask a question about the highlighted text"),
    input_hint = _("Type your question here..."),
    input_type = "text",
    buttons = {buttons}
  }
  UIManager:show(input_dialog)
end

return showChatGPTDialog