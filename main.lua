local Device = require("device")
local TextViewer = require("ui/widget/textviewer")
local InputDialog = require("ui/widget/inputdialog")
local UIManager = require("ui/uimanager")
local InputContainer = require("ui/widget/container/inputcontainer")
local API_KEY = require("api_key")
local _ = require("gettext")
local https = require("ssl.https")
local ltn12 = require("ltn12")
local json = require("json")

local ChatGPTHighlight = InputContainer:new {
    name = "chatgpthighlight",
    is_doc_only = true,
}

local function queryChatGPT(highlightedText, question, title, author)
    local api_key = API_KEY.key
    local api_url = "https://api.openai.com/v1/chat/completions"

    local headers = {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bearer " .. api_key,
    }

    local requestBody = json.encode({
        model = "gpt-3.5-turbo",
        messages = {
            {
                role = "system",
                content =
                "The following is a conversation with an AI assistant. The assistant is helpful, creative, clever, and very friendly. Answer as concisely as possible.",
            },
            {
                role = "user",
                content = "I'm reading something titled '" ..
                    title ..
                    "' by " .. author .. ". I have a question about the following highlighted text: " .. highlightedText,
            },
            {
                role = "user",
                content = question,
            },
        },
    })

    local responseBody = {}

    local res, code, responseHeaders = https.request {
        url = api_url,
        method = "POST",
        headers = headers,
        source = ltn12.source.string(requestBody),
        sink = ltn12.sink.table(responseBody),
    }

    if code ~= 200 then
        error("Error querying ChatGPT API: " .. code)
    end

    local response = json.decode(table.concat(responseBody))
    return response.choices[1].message.content
end

local function getBookTitleAndAuthor(ui)
    local title = ui.document:getProps().title or _("Unknown Title")
    local author = ui.document:getProps().authors or _("Unknown Author")
    return title, author
end

local function showChatGPTDialog(ui, highlightedText)
    local title, author = getBookTitleAndAuthor(ui)
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
