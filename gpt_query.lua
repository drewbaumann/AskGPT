local API_KEY = require("api_key")
local https = require("ssl.https")
local ltn12 = require("ltn12")
local json = require("json")

local function queryChatGPT(message_history)
  local api_key = API_KEY.key
  local api_url = "https://api.openai.com/v1/chat/completions"

  local headers = {
    ["Content-Type"] = "application/json",
    ["Authorization"] = "Bearer " .. api_key,
  }

  local requestBody = json.encode({
    model = "gpt-4o",
    messages = message_history,
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

return queryChatGPT
