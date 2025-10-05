// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(apiKey) => "${apiKey} total";

  static String m1(provider) => "Edit provider:${provider}";

  static String m2(endPoint) => "EndPoint";

  static String m3(endPoint) => "EndPoint:${endPoint}";

  static String m4(error) => "Error:${error}";

  static String m5(token) => "Knowledge base(${token}Tokens)";

  static String m6(errorContent) => "Loading error:${errorContent}";

  static String m7(token) => "Longest opening(${token}Tokens)";

  static String m8(charCount, maxCount) =>
      "You have exceeded the maximum context length of ${charCount}/${maxCount} characters.";

  static String m9(sec) => "Thought ${sec}s";

  static String m10(sec) => "Thinking...${sec}s";

  static String m11(num) => "${num} selected";

  static String m12(token) => "System internal prompt(${token}Tokens)";

  static String m13(token) => "System prompt(${token}Tokens)";

  static String m14(token) => "${token} Tokens available for chat";

  static String m15(lim) => "${lim} Tokens available for total context";

  static String m16(type) => "Type : ${type}";

  static String m17(token) => "UI interactions(${token}Tokens)";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "API_settings": MessageLookupByLibrary.simpleMessage("API settings"),
    "DEFAULT": MessageLookupByLibrary.simpleMessage("Default"),
    "about": MessageLookupByLibrary.simpleMessage("About"),
    "add": MessageLookupByLibrary.simpleMessage("Add"),
    "add_api_key": MessageLookupByLibrary.simpleMessage("Add API key"),
    "add_api_key_hint": MessageLookupByLibrary.simpleMessage(
      "No API keys yet \n Please press the + button to add one",
    ),
    "add_entries": MessageLookupByLibrary.simpleMessage("Add entries"),
    "add_model_hint": MessageLookupByLibrary.simpleMessage(
      "No models yet \n Please press the + button to add one",
    ),
    "add_persona": MessageLookupByLibrary.simpleMessage("Add persona"),
    "add_provider": MessageLookupByLibrary.simpleMessage("Add a provider"),
    "agent_delete_confirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure to delete this agent? \n All sessions related to this agent will be deleted.",
    ),
    "agent_desc_hint": MessageLookupByLibrary.simpleMessage(
      "Enter description for the agent",
    ),
    "agent_manage": MessageLookupByLibrary.simpleMessage("Agent management"),
    "agent_name_hint": MessageLookupByLibrary.simpleMessage("Name the agent"),
    "agent_sets": MessageLookupByLibrary.simpleMessage("Agent Settings"),
    "ai": MessageLookupByLibrary.simpleMessage("AI"),
    "any": MessageLookupByLibrary.simpleMessage("Any"),
    "api_key": MessageLookupByLibrary.simpleMessage("API Key"),
    "api_key_set": MessageLookupByLibrary.simpleMessage("API key set"),
    "api_key_total": m0,
    "api_settings": MessageLookupByLibrary.simpleMessage("API settings"),
    "auto_index_rules_1": MessageLookupByLibrary.simpleMessage(
      "When chat with",
    ),
    "auto_index_rules_2": MessageLookupByLibrary.simpleMessage("and"),
    "auto_index_rules_3": MessageLookupByLibrary.simpleMessage(
      "will be indexed",
    ),
    "auto_index_rules_set": MessageLookupByLibrary.simpleMessage(
      "Auto index rules setting",
    ),
    "auto_shrink_large_panel": MessageLookupByLibrary.simpleMessage(
      "Automatically shrink panels to fit the window",
    ),
    "avatar_change_hint": MessageLookupByLibrary.simpleMessage(
      "Click or drag a new image to change the avatar",
    ),
    "base_stat_OK": MessageLookupByLibrary.simpleMessage("OK"),
    "base_stat_PENDING": MessageLookupByLibrary.simpleMessage("Pending"),
    "base_stat_processing": MessageLookupByLibrary.simpleMessage("Processing"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cancel_long_press": MessageLookupByLibrary.simpleMessage(
      "Cancel (LongPress)",
    ),
    "chat": MessageLookupByLibrary.simpleMessage("Chat"),
    "check_manual": MessageLookupByLibrary.simpleMessage("Check manual"),
    "choose_agent_and_chat_hint": MessageLookupByLibrary.simpleMessage(
      "Select an agent and start chatting",
    ),
    "click_or_drop_files_here": MessageLookupByLibrary.simpleMessage(
      "Click to select or drop files here",
    ),
    "click_upload_image": MessageLookupByLibrary.simpleMessage(
      "Click to upload a image",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "confirm_adding_model": MessageLookupByLibrary.simpleMessage(
      "Confirm to add this model",
    ),
    "confirm_delete_provider": MessageLookupByLibrary.simpleMessage(
      "Are you sure to delete this provider?",
    ),
    "confirm_delete_session": MessageLookupByLibrary.simpleMessage(
      "Are you sure to delete this chat?",
    ),
    "confirm_long_press": MessageLookupByLibrary.simpleMessage(
      "Confirm (LongPress)",
    ),
    "content": MessageLookupByLibrary.simpleMessage("Content"),
    "create_new_agent": MessageLookupByLibrary.simpleMessage(
      "Create new agent",
    ),
    "create_new_model": MessageLookupByLibrary.simpleMessage(
      "Create new model",
    ),
    "create_new_rule": MessageLookupByLibrary.simpleMessage(
      "Create a new rule",
    ),
    "default_index_method": MessageLookupByLibrary.simpleMessage(
      "Default index method",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "delete_long_press": MessageLookupByLibrary.simpleMessage(
      "Delete (LongPress)",
    ),
    "disable": MessageLookupByLibrary.simpleMessage("Disable"),
    "drag_image_hint": MessageLookupByLibrary.simpleMessage("Drop image here"),
    "drop_files_hint": MessageLookupByLibrary.simpleMessage("Drop files here"),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "edit_entries": MessageLookupByLibrary.simpleMessage("Edit entries"),
    "edit_knowledge_base": MessageLookupByLibrary.simpleMessage(
      "Edit knowledge base",
    ),
    "edit_persona": MessageLookupByLibrary.simpleMessage("Edit persona"),
    "edit_provider": m1,
    "embedding_dimension": MessageLookupByLibrary.simpleMessage(
      "Embedding dimension",
    ),
    "embedding_model": MessageLookupByLibrary.simpleMessage("Embedding model"),
    "embedding_model_note": MessageLookupByLibrary.simpleMessage(
      "Note that this is an embedding model , which cannot be used to chat",
    ),
    "enable": MessageLookupByLibrary.simpleMessage("Enable"),
    "enable_ui_interactions": MessageLookupByLibrary.simpleMessage(
      "Enable UI interactions",
    ),
    "end_point": m2,
    "end_point_set": MessageLookupByLibrary.simpleMessage("EndPoint set"),
    "end_point_type": MessageLookupByLibrary.simpleMessage("EndPoint type"),
    "end_point_type_set": MessageLookupByLibrary.simpleMessage(
      "EndPoint type set",
    ),
    "end_point_with_holder": m3,
    "enlarge_context_or_simplify_prompt": MessageLookupByLibrary.simpleMessage(
      "Enlarge context or simplify prompt",
    ),
    "enter_end_point": MessageLookupByLibrary.simpleMessage(
      "Enter API endpoint",
    ),
    "enter_key_word_hint": MessageLookupByLibrary.simpleMessage(
      "Enter keywords separated by comma",
    ),
    "enter_knowledge_base_description": MessageLookupByLibrary.simpleMessage(
      "Enter knowledge base description",
    ),
    "enter_knowledge_base_name": MessageLookupByLibrary.simpleMessage(
      "Enter knowledge base name",
    ),
    "enter_opening_here": MessageLookupByLibrary.simpleMessage(
      "Enter opening here...",
    ),
    "enter_provider_details": MessageLookupByLibrary.simpleMessage(
      "Enter provider details",
    ),
    "enter_regex_hint": MessageLookupByLibrary.simpleMessage("Enter regex"),
    "enter_session_name": MessageLookupByLibrary.simpleMessage(
      "Enter new session name",
    ),
    "enter_sys_prompt_here": MessageLookupByLibrary.simpleMessage(
      "Enter system prompt here...",
    ),
    "error_occurred": MessageLookupByLibrary.simpleMessage("Error"),
    "error_occurred_with_error": m4,
    "file_manage": MessageLookupByLibrary.simpleMessage("File manage"),
    "fill_in_api_key": MessageLookupByLibrary.simpleMessage(
      "Fill in the API key",
    ),
    "fill_model_call_name": MessageLookupByLibrary.simpleMessage(
      "Model call name",
    ),
    "fill_reminder_null_if_blank": MessageLookupByLibrary.simpleMessage(
      "Write a reminder (null if left blank)",
    ),
    "finish_edit": MessageLookupByLibrary.simpleMessage("Finish editing"),
    "freq_penalty": MessageLookupByLibrary.simpleMessage("Frequency Penalty"),
    "front_page_hintLine_char1": MessageLookupByLibrary.simpleMessage("Use "),
    "front_page_hintLine_char2": MessageLookupByLibrary.simpleMessage(
      " to chat with ",
    ),
    "front_page_hintLine_char3": MessageLookupByLibrary.simpleMessage(""),
    "general_settings": MessageLookupByLibrary.simpleMessage(
      "General settings",
    ),
    "give_up_edit_confirm": MessageLookupByLibrary.simpleMessage(
      "Give up edit?",
    ),
    "go_back": MessageLookupByLibrary.simpleMessage("Go back"),
    "google_compatible_api": MessageLookupByLibrary.simpleMessage(
      "Google compatible API",
    ),
    "help": MessageLookupByLibrary.simpleMessage("Help"),
    "hide_cot": MessageLookupByLibrary.simpleMessage("Hide  thoughts"),
    "hide_knowledge_base_results": MessageLookupByLibrary.simpleMessage(
      "Hide knowledge base search results",
    ),
    "hide_source_code": MessageLookupByLibrary.simpleMessage(
      "Hide source code",
    ),
    "hover_to_see_session": MessageLookupByLibrary.simpleMessage(
      "Hover to preview session",
    ),
    "image_load_fail": MessageLookupByLibrary.simpleMessage(
      "Image load failed.",
    ),
    "index_all": MessageLookupByLibrary.simpleMessage("Index all"),
    "index_settings": MessageLookupByLibrary.simpleMessage("Index settings"),
    "keyword_index": MessageLookupByLibrary.simpleMessage("Keyword index"),
    "keyword_index_hint": MessageLookupByLibrary.simpleMessage(
      "When message contains any keywords, the whole content will be sent",
    ),
    "keyword_match": MessageLookupByLibrary.simpleMessage("Keyword match"),
    "knowledge_base": MessageLookupByLibrary.simpleMessage("Knowledge base"),
    "knowledge_base_and_contexts": MessageLookupByLibrary.simpleMessage(
      "Knowledge base & contexts",
    ),
    "knowledge_base_tokens": m5,
    "language_select": MessageLookupByLibrary.simpleMessage(
      "Select a language",
    ),
    "language_settings": MessageLookupByLibrary.simpleMessage(
      "Language settings",
    ),
    "language_switch_restart_note": MessageLookupByLibrary.simpleMessage(
      "Some changes may require a restart to take effect.",
    ),
    "loading_error": m6,
    "longest_opening": m7,
    "memory_content": MessageLookupByLibrary.simpleMessage("Memory content"),
    "memory_content_waring": MessageLookupByLibrary.simpleMessage(
      "Memory content cannot be empty",
    ),
    "memory_manage": MessageLookupByLibrary.simpleMessage("Memory manage"),
    "memory_name": MessageLookupByLibrary.simpleMessage("Memory name"),
    "memory_name_waring": MessageLookupByLibrary.simpleMessage(
      "Memory name cannot be empty",
    ),
    "model": MessageLookupByLibrary.simpleMessage("Model"),
    "model_ability": MessageLookupByLibrary.simpleMessage("Model ability"),
    "model_advance_properties": MessageLookupByLibrary.simpleMessage(
      "Model advance properties",
    ),
    "model_basic_info_pass_through_setting":
        MessageLookupByLibrary.simpleMessage(
          "Model basic info pass through settings",
        ),
    "model_call_name_hint": MessageLookupByLibrary.simpleMessage(
      "Enter call name (eg: qwen/qwen-7b-chat)",
    ),
    "model_context_not_enough": MessageLookupByLibrary.simpleMessage(
      "Reach prompt limit",
    ),
    "model_delete_confirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this model?",
    ),
    "model_family": MessageLookupByLibrary.simpleMessage("Model family"),
    "model_family_hint": MessageLookupByLibrary.simpleMessage(
      "Enter the model\'s family (eg: qwen3)",
    ),
    "model_friendly_name": MessageLookupByLibrary.simpleMessage(
      "Model friendly name",
    ),
    "model_friendly_name_hint": MessageLookupByLibrary.simpleMessage(
      "Enter the model\'s friendly name (eg: Qwen 7B)",
    ),
    "model_local_telling": MessageLookupByLibrary.simpleMessage(
      "Pass the local info",
    ),
    "model_management": MessageLookupByLibrary.simpleMessage(
      "Model management",
    ),
    "model_maximum_context_length": MessageLookupByLibrary.simpleMessage(
      "Model maximum context length",
    ),
    "model_maximum_generate_length": MessageLookupByLibrary.simpleMessage(
      "Model maximum generate length",
    ),
    "model_or_dimension_not_set": MessageLookupByLibrary.simpleMessage(
      "Model or dimension not set",
    ),
    "model_property": MessageLookupByLibrary.simpleMessage(
      "Model Property Settings",
    ),
    "model_select": MessageLookupByLibrary.simpleMessage("Select a model"),
    "model_sets": MessageLookupByLibrary.simpleMessage("Model settings"),
    "model_system_telling": MessageLookupByLibrary.simpleMessage(
      "Pass the system info (eg: macOS Sonoma)",
    ),
    "model_time_telling": MessageLookupByLibrary.simpleMessage(
      "Pass the current time",
    ),
    "modify_session_name": MessageLookupByLibrary.simpleMessage(
      "Modify session name",
    ),
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "new_chat_session": MessageLookupByLibrary.simpleMessage(
      "New chat session",
    ),
    "next_step": MessageLookupByLibrary.simpleMessage("Next step"),
    "no_agent": MessageLookupByLibrary.simpleMessage(
      "No agent , please add one",
    ),
    "no_embedding_model": MessageLookupByLibrary.simpleMessage(
      "No embedding model \n Embedding models are different from chat models,check whether you really got one.",
    ),
    "no_file": MessageLookupByLibrary.simpleMessage("No file"),
    "no_file_selected": MessageLookupByLibrary.simpleMessage(
      "No file selected",
    ),
    "no_history": MessageLookupByLibrary.simpleMessage("no chat history"),
    "no_index_method_warning": MessageLookupByLibrary.simpleMessage(
      "No index method selected, this content will never be inserted into conversation",
    ),
    "no_memory": MessageLookupByLibrary.simpleMessage("No memory"),
    "no_message": MessageLookupByLibrary.simpleMessage("no message"),
    "no_model": MessageLookupByLibrary.simpleMessage("No model yet"),
    "no_model_plz_add": MessageLookupByLibrary.simpleMessage(
      "No model yet, please add one first.",
    ),
    "no_persona": MessageLookupByLibrary.simpleMessage("No persona"),
    "no_preview": MessageLookupByLibrary.simpleMessage("No preview available"),
    "no_provider": MessageLookupByLibrary.simpleMessage("No providers "),
    "no_results": MessageLookupByLibrary.simpleMessage("No results"),
    "no_rules": MessageLookupByLibrary.simpleMessage("No rules"),
    "openai_compatible_api": MessageLookupByLibrary.simpleMessage(
      "OpenAI compatible API",
    ),
    "openai_completion_compatible_api": MessageLookupByLibrary.simpleMessage(
      "OpenAI Completion (Legacy) compatible API",
    ),
    "opening": MessageLookupByLibrary.simpleMessage("Opening"),
    "opening_set": MessageLookupByLibrary.simpleMessage("Opening settings"),
    "or_expand_window": MessageLookupByLibrary.simpleMessage(
      "or please make the window bigger",
    ),
    "over_maximum_context_length_hint": m8,
    "persona_description_hint": MessageLookupByLibrary.simpleMessage(
      "Describe yourself...",
    ),
    "plz_enter_content": MessageLookupByLibrary.simpleMessage(
      "Please enter content",
    ),
    "plz_enter_description": MessageLookupByLibrary.simpleMessage(
      "Please enter description",
    ),
    "plz_enter_name": MessageLookupByLibrary.simpleMessage(
      "Please enter your name",
    ),
    "plz_fill_model_call_name": MessageLookupByLibrary.simpleMessage(
      "Please fill in the model\'s call name",
    ),
    "plz_select_agent": MessageLookupByLibrary.simpleMessage(
      "Please select an agent",
    ),
    "plz_select_embedding_dimension": MessageLookupByLibrary.simpleMessage(
      "Please select embedding dimension",
    ),
    "plz_select_persona": MessageLookupByLibrary.simpleMessage(
      "Please select a persona",
    ),
    "plz_select_provider": MessageLookupByLibrary.simpleMessage(
      "Please select a provider",
    ),
    "preferences": MessageLookupByLibrary.simpleMessage("Preferences"),
    "pres_penalty": MessageLookupByLibrary.simpleMessage("Presence Penalty"),
    "provider_select": MessageLookupByLibrary.simpleMessage(
      "Select the provider",
    ),
    "quit": MessageLookupByLibrary.simpleMessage("Quit"),
    "reasoned": m9,
    "reasoning": m10,
    "regex_index": MessageLookupByLibrary.simpleMessage("Regex index"),
    "regex_index_hint": MessageLookupByLibrary.simpleMessage(
      "When message matches any regex, the whole content will be sent",
    ),
    "regex_match": MessageLookupByLibrary.simpleMessage("Regex match"),
    "rename": MessageLookupByLibrary.simpleMessage("Rename"),
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "search_any_chat_message": MessageLookupByLibrary.simpleMessage(
      "Search any chat message...",
    ),
    "searched_knowledge_base": MessageLookupByLibrary.simpleMessage(
      "Searched Knowledge Base",
    ),
    "searching_knowledge_base": MessageLookupByLibrary.simpleMessage(
      "Searching Knowledge Base...",
    ),
    "select_agent": MessageLookupByLibrary.simpleMessage("Select agent"),
    "select_api_type": MessageLookupByLibrary.simpleMessage(
      "Select the type of the API",
    ),
    "select_image_hint": MessageLookupByLibrary.simpleMessage(
      "Click to select or drop an image",
    ),
    "select_model_hint": MessageLookupByLibrary.simpleMessage(
      "Please select a model",
    ),
    "select_or_add_memory": MessageLookupByLibrary.simpleMessage(
      "Select or add a memory",
    ),
    "select_provider": MessageLookupByLibrary.simpleMessage("Select provider"),
    "selected_agent": m11,
    "send_a_message_hint": MessageLookupByLibrary.simpleMessage(
      "Send a message",
    ),
    "set_as_default": MessageLookupByLibrary.simpleMessage("Set as default"),
    "show_cot": MessageLookupByLibrary.simpleMessage("Show thoughts"),
    "show_knowledge_base_results": MessageLookupByLibrary.simpleMessage(
      "Show knowledge base search results",
    ),
    "show_source_code": MessageLookupByLibrary.simpleMessage(
      "Show source code",
    ),
    "start_conversation_with_selected_agent":
        MessageLookupByLibrary.simpleMessage(
          "Start conversation with selected agent",
        ),
    "support_formats": MessageLookupByLibrary.simpleMessage(
      "md,docx,csv,txt,json,html",
    ),
    "supports_files_api": MessageLookupByLibrary.simpleMessage(
      "Whether this provider supports files API?",
    ),
    "switch_persona": MessageLookupByLibrary.simpleMessage("Switch persona"),
    "sys_prompt": MessageLookupByLibrary.simpleMessage("System prompt"),
    "system_internal_prompt": m12,
    "system_prompt_tokens": m13,
    "temperature": MessageLookupByLibrary.simpleMessage("Temperature"),
    "title": MessageLookupByLibrary.simpleMessage("UNIChat"),
    "token_available_for_chat": m14,
    "top_p": MessageLookupByLibrary.simpleMessage("Top P"),
    "total_context_lim": m15,
    "type_with_holder": m16,
    "ui_edited": MessageLookupByLibrary.simpleMessage("Edited UI"),
    "ui_editing": MessageLookupByLibrary.simpleMessage("Editing UI"),
    "ui_interaction_set": MessageLookupByLibrary.simpleMessage(
      "UI interaction (BETA) settings",
    ),
    "ui_interactions": MessageLookupByLibrary.simpleMessage("UI interactions"),
    "ui_interactions_tokens": m17,
    "unsupported_format": MessageLookupByLibrary.simpleMessage(
      "Unsupported format",
    ),
    "user": MessageLookupByLibrary.simpleMessage("User"),
    "usr_persona_set": MessageLookupByLibrary.simpleMessage(
      "User Persona Settings",
    ),
    "vec_index_hint": MessageLookupByLibrary.simpleMessage(
      "Match the chunks of content which are similar to the query",
    ),
    "vector_index": MessageLookupByLibrary.simpleMessage("Vector index"),
    "view_all_provider_provide_model": MessageLookupByLibrary.simpleMessage(
      "Provider who provides this model",
    ),
    "website_manage": MessageLookupByLibrary.simpleMessage("Website manage"),
    "window_too_small_to_display_allPanels":
        MessageLookupByLibrary.simpleMessage(
          "The window is too small for fitting all the panels",
        ),
  };
}
