# uniChat

uniChat is a powerful, cross-platform AI agent client built with Flutter. It's designed to be an ultimate AI executing system, providing a rich and interactive experience for communicating with various language models.

## 🌟 Features

- **🤖 Agent-based Framework**: Create and manage multiple AI agents, each with its own configurable model, system prompts, and parameters.
- **💬 Core Chat Functionality**: Supports text messages and file attachments, including images, PDFs, and text files.
- **🔌 Multi-Provider Support**: Easily switch between different LLM providers like OpenAI, Google Gemini, or even your custom API endpoints.
- **✨ UIQL (User Interface Query Language)**: A unique command-based language that allows the AI to dynamically create, update, and interact with UI components like charts, tables, and buttons.
- **⚙️ Comprehensive Settings**: A detailed settings panel to manage API providers, keys, and models.
- **💾 Local Data Persistence**: All your chat sessions, messages, and agent configurations are saved locally using a `sqflite` database.
- **📱 Cross-Platform**: Built with Flutter, uniChat is designed to run on Android, iOS, macOS, Windows, Linux, and Web.

## 🔧 Project Structure

The project is organized into the following main directories:

- `lib/`: Contains the core Dart code for the application.
  - `Agent/`: Manages the AI agents, including their creation, configuration, and state.
  - `Chat/`: Implements the main chat interface, message handling, and UI panels.
    - `panels/`: Contains the various UIQL panels that can be dynamically rendered.
  - `Editor/`: The visual node editor (beta).
  - `llm_provider/`: Handles communication with different LLM APIs.
  - `settings_page/`: The settings UI for managing APIs and models.
  - `utils/`: Utility classes and services, including database and file handling.
- `assets/`: Contains static assets like images and shaders.
- `android/`, `ios/`, `linux/`, `macos/`, `web/`, `windows/`: Platform-specific code and configurations.

## 🛠️ Key Technologies

- **Flutter**: The core framework for building the cross-platform UI.
- **Riverpod**: For state management.
- **sqflite**: For local database storage.
- **http**: For making API requests to LLM providers.
- **fl_chart**, **webview_flutter**, and more: For rendering dynamic UIQL panels.

## 🤝 Contributing

Contributions are welcome! If you have any ideas, suggestions, or bug reports, please open an issue or submit a pull request.