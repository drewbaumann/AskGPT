# ChatGPT Highlight Plugin for KOReader

Welcome to the ChatGPT Highlight Plugin for KOReader! With this plugin, you can highlight text in your e-books and ask ChatGPT, a language model developed by OpenAI, to answer questions about the content. This can be a great way to deepen your understanding of the material and learn new things!

## Getting Started

To use this plugin, You'll need to do a few things:

Get [KoReader](https://github.com/koreader/koreader) installed on your e-reader. You can find instructions for doing this for a variety of devices [here](https://www.mobileread.com/forums/forumdisplay.php?f=276).

If you want to do this on a Kindle, you are going to have to jailbreak it. I recommend following [this guide](https://www.mobileread.com/forums/showthread.php?t=320564) to jailbreak your Kindle.

An API key from OpenAI. Once you have your API key, create a `api_key.lua` file in the following structure:

```lua
local API_KEY = {
  key = "your_api_key",
}

return API_KEY
```

## How To Use

To use the ChatGPT Highlight Plugin, simply highlight the text that you want to ask a question about, and select "Ask ChatGPT" from the menu. The plugin will then send your highlighted text to the ChatGPT API, and display the answer to your question in a pop-up window.

I am currently using this on a jailbroken Kindle Paperwhite with KOReader installed.

I hope you enjoy using this plugin and that it enhances your e-reading experience. If you have any feedback or suggestions, please let me know!
