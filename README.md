# AskGPT: ChatGPT Highlight Plugin for KOReader

Introducing AskGPT, a new plugin for KOReader that allows you to ask questions about the parts of the book you're reading and receive insightful answers from ChatGPT, an AI language model. With AskGPT, you can have a more interactive and engaging reading experience, and gain a deeper understanding of the content.

## Getting Started

To use this plugin, You'll need to do a few things:

Get [KoReader](https://github.com/koreader/koreader) installed on your e-reader. You can find instructions for doing this for a variety of devices [here](https://www.mobileread.com/forums/forumdisplay.php?f=276).

If you want to do this on a Kindle, you are going to have to jailbreak it. I recommend following [this guide](https://www.mobileread.com/forums/showthread.php?t=320564) to jailbreak your Kindle.

Acquire an API key from an API account on OpenAI (with credits). Once you have your API key, create a `configuration.lua` file in the following structure or modify and rename the `configuration.lua.sample` file:

> **Note:** The prior `api_key.lua` style configuration is deprecated. Please use the new `configuration.lua` style configuration.

```lua
local CONFIGURATION = {
    api_key = "YOUR_API_KEY",
    model = "gpt-4o-mini",
    base_url = "https://api.openai.com/v1/chat/completions"
}

return CONFIGURATION
```

In this new format you can specify the model you want to use, the API key, and the base URL for the API. The model is optional and defaults to `gpt-4o-mini`. The base URL is also optional and defaults to `https://api.openai.com/v1/chat/completions`. This is useful if you want to use a different model or a different API endpoint (such as via Azure or another LLM that uses the same API style as OpenAI).

For example, you could use a local API via a tool like [Ollama](https://ollama.com/blog/openai-compatibility) and set the base url to point to your computers IP address and port.

```lua
local CONFIGURATION = {
    api_key = "ollama",
    model = "zephyr",
    base_url = "http://192.168.1.87:11434/v1/chat/completions",
    additional_parameters = {}
}

return CONFIGURATION
```

## Other Features

Additionally, as other extra features are rolled out, they will be optional and can be set in the `features` table in the `configuration.lua` file.

### Translation

To enable translation, simply add a translation prompt to your features.custom_prompts configuration. The prompt should specify the target language and any other translation preferences. For example this one is for French:

```lua
local CONFIGURATION = {
    api_key = "YOUR_API_KEY",
    model = "gpt-4o-mini",
    base_url = "https://api.openai.com/v1/chat/completions",
    features = {
        custom_prompts = {
            translation = "Please translate the following text to French with definition."
        }
    }
}
```

### Custom Prompts

You can customize the prompts used for different interactions by adding them to the `features.custom_prompts` section. Each prompt (except 'system') will automatically generate a button in the interface. The button's name will be the capitalized version of the prompt key.

For example, this configuration:

```lua
local CONFIGURATION = {
    api_key = "YOUR_API_KEY",
    model = "gpt-4o-mini",
    base_url = "https://api.openai.com/v1/chat/completions",
    features = {
        custom_prompts = {
            summarize = "Please summarize the following text.",
            translate = "Please translate the following text to French."
        }
    }
}
```

Will generate buttons labeled "Summarize" and "Translate" in the interface.

## Installation

If you clone this project, you should be able to put the directory, `askgpt.koplugin`, in the `koreader/plugins` directory and it should work. If you want to use the plugin without cloning the project, you can download the zip file from the releases page and extract the `askgpt.koplugin` directory to the `koreader/plugins` directory. If for some reason you extract the files of this repository in another directory, rename it before moving it to the `koreader/plugins` directory.

## How To Use

To use AskGPT, simply highlight the text that you want to ask a question about, and select "Ask ChatGPT" from the menu. The plugin will then send your highlighted text to the ChatGPT API, and display the answer to your question in a pop-up window.

I hope you enjoy using this plugin and that it enhances your e-reading experience. If you have any feedback or suggestions, please let me know!

If you want to support development, become a [Sponsor on GitHub](https://github.com/sponsors/drewbaumann).

License: GPLv3
