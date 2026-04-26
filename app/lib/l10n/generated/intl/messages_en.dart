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

  static String m0(count) => "Add ${count} models";

  static String m1(count) =>
      "All ${count} available API Keys failed to request, click for details";

  static String m2(apiKey) => "${apiKey} total";

  static String m3(num) => "${num} API Keys added";

  static String m4(branch) => "Branched from ${branch}";

  static String m5(branch) => "Branches ${branch}";

  static String m6(count) => "Called ${count} times";

  static String m7(currency) => "Est. Cost (${currency})";

  static String m8(dbName, from, to) =>
      "Downgrade occurred in ${dbName}: Attempting to open newer database (${from}) with an older app version (${to})";

  static String m9(provider) => "Edit provider:${provider}";

  static String m10(email) => "Email: ${email}";

  static String m11(endPoint) => "EndPoint";

  static String m12(endPoint) => "EndPoint:${endPoint}";

  static String m13(error) => "Error:${error}";

  static String m14(condition) => "while ${condition}";

  static String m15(token) => "Knowledge base(${token}Tokens)";

  static String m16(errorContent) => "Loading error:${errorContent}";

  static String m17(error) => "Failed to read logs: ${error}";

  static String m18(token) => "Longest opening(${token}Tokens)";

  static String m19(percent) => "${percent}% Related";

  static String m20(num) => "Added ${num} models";

  static String m21(charCount, maxCount) =>
      "You have exceeded the maximum context length of ${charCount}/${maxCount} characters.";

  static String m22(provider) =>
      " Are you sure to delete ${provider}?\\n All the records and key will be deleted as well.";

  static String m23(agent) =>
      "Set the selected model as the default model of \'${agent}\' ?";

  static String m24(num) => "${num} selected";

  static String m25(token) => "System internal prompt(${token}Tokens)";

  static String m26(token) => "System prompt(${token}Tokens)";

  static String m27(token) => "${token} Tokens available for chat";

  static String m28(lim) => "${lim} Tokens available for total context";

  static String m29(type) => "Type : ${type}";

  static String m30(token) => "UI interactions(${token}Tokens)";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "API_settings": MessageLookupByLibrary.simpleMessage("API settings"),
    "DEFAULT": MessageLookupByLibrary.simpleMessage("Default"),
    "abandon_and_exit": MessageLookupByLibrary.simpleMessage(
      "Abandon and Exit",
    ),
    "abandon_match_subtitle": MessageLookupByLibrary.simpleMessage(
      "Unsaved matching results will be lost.",
    ),
    "abandon_match_title": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to abandon?",
    ),
    "about": MessageLookupByLibrary.simpleMessage("About"),
    "add": MessageLookupByLibrary.simpleMessage("Add"),
    "add_api_key": MessageLookupByLibrary.simpleMessage("Add API key"),
    "add_api_key_hint": MessageLookupByLibrary.simpleMessage(
      "No API keys yet \n Please press the + button to add one",
    ),
    "add_confirmed_models": m0,
    "add_entries": MessageLookupByLibrary.simpleMessage("Add entries"),
    "add_memory": MessageLookupByLibrary.simpleMessage("Add memory"),
    "add_model": MessageLookupByLibrary.simpleMessage("Add model"),
    "add_model_hint": MessageLookupByLibrary.simpleMessage(
      "No models yet \n Please press the + button to add one",
    ),
    "add_other_provider": MessageLookupByLibrary.simpleMessage(
      "Add other provider",
    ),
    "add_parameter": MessageLookupByLibrary.simpleMessage("Add Parameter"),
    "add_persona": MessageLookupByLibrary.simpleMessage("Add persona"),
    "add_provider": MessageLookupByLibrary.simpleMessage("Add a provider"),
    "add_ver_flag": MessageLookupByLibrary.simpleMessage("Add version flags"),
    "advance_settings": MessageLookupByLibrary.simpleMessage(
      "Advance Settings",
    ),
    "agent": MessageLookupByLibrary.simpleMessage("Agent"),
    "agentEx": MessageLookupByLibrary.simpleMessage("Agent error"),
    "agentEx_agentNotFound": MessageLookupByLibrary.simpleMessage(
      "agent not found",
    ),
    "agentEx_agentNotLoaded": MessageLookupByLibrary.simpleMessage(
      "agent not loaded",
    ),
    "agentEx_failLoading_parse_error": MessageLookupByLibrary.simpleMessage(
      "agent data is corrupted",
    ),
    "agentEx_recursive_call": MessageLookupByLibrary.simpleMessage(
      "loading agent",
    ),
    "agentEx_unknownError": MessageLookupByLibrary.simpleMessage(
      "unknown error",
    ),
    "agentEx_versionMismatch": MessageLookupByLibrary.simpleMessage(
      "Core component version mismatch, please upgrade the application",
    ),
    "agent_delete_confirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure to delete this agent? \n All sessions related to this agent will be deleted.",
    ),
    "agent_desc_hint": MessageLookupByLibrary.simpleMessage(
      "Enter description for the agent",
    ),
    "agent_manage": MessageLookupByLibrary.simpleMessage("Agent management"),
    "agent_name_hint": MessageLookupByLibrary.simpleMessage("Name the agent"),
    "agent_override_editing_hint": MessageLookupByLibrary.simpleMessage(
      "You are editing the override configuration for this session. Changes will only apply to the current session and won\'t affect the global Agent settings.",
    ),
    "agent_override_title": MessageLookupByLibrary.simpleMessage(
      "Session Agent Override",
    ),
    "agent_sets": MessageLookupByLibrary.simpleMessage("Agent Settings"),
    "ai": MessageLookupByLibrary.simpleMessage("AI"),
    "all_rights_reserved": MessageLookupByLibrary.simpleMessage(
      "Copyright © 2026 LinChi all rights reserved.",
    ),
    "any": MessageLookupByLibrary.simpleMessage("Any"),
    "apiEx": MessageLookupByLibrary.simpleMessage("API error"),
    "apiEx_apikey_noAvailableKeys": MessageLookupByLibrary.simpleMessage(
      "currently no keys are available for using",
    ),
    "apiEx_apikey_noAvailableKeys_detailed": m1,
    "apiEx_modelNotAvailableForProvider": MessageLookupByLibrary.simpleMessage(
      "model not available for provider",
    ),
    "apiEx_modelNotFound": MessageLookupByLibrary.simpleMessage(
      "model not found",
    ),
    "apiEx_providerNotFound": MessageLookupByLibrary.simpleMessage(
      "provider not found",
    ),
    "apiEx_recursive_call": MessageLookupByLibrary.simpleMessage("calling api"),
    "apiEx_request_apiFail": MessageLookupByLibrary.simpleMessage(
      "api failed to respond",
    ),
    "apiEx_request_badRequest": MessageLookupByLibrary.simpleMessage(
      "bad request",
    ),
    "apiEx_request_emptyBody": MessageLookupByLibrary.simpleMessage(
      "the api returns an empty response",
    ),
    "apiEx_request_other": MessageLookupByLibrary.simpleMessage("api error "),
    "apiEx_request_timeout": MessageLookupByLibrary.simpleMessage(
      "request timeout",
    ),
    "apiEx_unknownError": MessageLookupByLibrary.simpleMessage("unknown error"),
    "api_key": MessageLookupByLibrary.simpleMessage("API Key"),
    "api_key_exhausted_subtitle": MessageLookupByLibrary.simpleMessage(
      "In this round of requests,all keys have failed:",
    ),
    "api_key_exhausted_title": MessageLookupByLibrary.simpleMessage(
      "API Key Status Report",
    ),
    "api_key_set": MessageLookupByLibrary.simpleMessage("API key set"),
    "api_key_total": m2,
    "api_keys_configure": MessageLookupByLibrary.simpleMessage(
      "API Keys configuration",
    ),
    "api_keys_configured": m3,
    "api_keys_not_set": MessageLookupByLibrary.simpleMessage(
      "Api Keys not added",
    ),
    "api_settings": MessageLookupByLibrary.simpleMessage("API settings"),
    "api_type": MessageLookupByLibrary.simpleMessage("API Type"),
    "audio": MessageLookupByLibrary.simpleMessage("Audio"),
    "auto_fetch_models": MessageLookupByLibrary.simpleMessage(
      "Auto Fetch Models",
    ),
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
    "back": MessageLookupByLibrary.simpleMessage("Back"),
    "base_stat_OK": MessageLookupByLibrary.simpleMessage("OK"),
    "base_stat_PENDING": MessageLookupByLibrary.simpleMessage("Pending"),
    "base_stat_processing": MessageLookupByLibrary.simpleMessage("Processing"),
    "basic_configure": MessageLookupByLibrary.simpleMessage(
      "Basic configuration",
    ),
    "branch_confirm": MessageLookupByLibrary.simpleMessage("Branch"),
    "branch_from_here": MessageLookupByLibrary.simpleMessage(
      "Branch from here",
    ),
    "branched_from": m4,
    "branches": m5,
    "cache_price_per_1k": MessageLookupByLibrary.simpleMessage(
      "Cache Read Price (per 1M tokens)",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cancel_long_press": MessageLookupByLibrary.simpleMessage(
      "Cancel (LongPress)",
    ),
    "chat": MessageLookupByLibrary.simpleMessage("Chat"),
    "chatEx": MessageLookupByLibrary.simpleMessage("Chat error"),
    "chatEx_failParsingMessage": MessageLookupByLibrary.simpleMessage(
      "fail to parse message",
    ),
    "chatEx_failToGenerateTitle": MessageLookupByLibrary.simpleMessage(
      "fail to generate title",
    ),
    "chatEx_failToSaveMessage": MessageLookupByLibrary.simpleMessage(
      "fail to save message",
    ),
    "chatEx_messageNotFound": MessageLookupByLibrary.simpleMessage(
      "message not found",
    ),
    "chatEx_modelNotSupportFileType": MessageLookupByLibrary.simpleMessage(
      "The model does not support this type of file",
    ),
    "chatEx_recursive_call": MessageLookupByLibrary.simpleMessage("chatting"),
    "chatEx_sessionNotFound": MessageLookupByLibrary.simpleMessage(
      "session not found",
    ),
    "chatEx_unknownError": MessageLookupByLibrary.simpleMessage(
      "unknown error",
    ),
    "check_manual": MessageLookupByLibrary.simpleMessage("Check manual"),
    "check_updates": MessageLookupByLibrary.simpleMessage("Check for updates"),
    "choose_agent_and_chat_hint": MessageLookupByLibrary.simpleMessage(
      "Select an agent and start chatting",
    ),
    "click_or_drop_files_here": MessageLookupByLibrary.simpleMessage(
      "Click to select or drop files here",
    ),
    "click_upload_image": MessageLookupByLibrary.simpleMessage(
      "Click to upload a image",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "completion": MessageLookupByLibrary.simpleMessage("Completion"),
    "completion_price_per_1k": MessageLookupByLibrary.simpleMessage(
      "Completion Price (per 1M tokens)",
    ),
    "configure_all_set": MessageLookupByLibrary.simpleMessage("Configured"),
    "configure_not_set": MessageLookupByLibrary.simpleMessage("Not configured"),
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
    "continue_editing": MessageLookupByLibrary.simpleMessage(
      "Continue Editing",
    ),
    "create_new_agent": MessageLookupByLibrary.simpleMessage(
      "Create new agent",
    ),
    "create_new_model": MessageLookupByLibrary.simpleMessage(
      "Create new model",
    ),
    "create_new_rule": MessageLookupByLibrary.simpleMessage(
      "Create a new rule",
    ),
    "create_variant": MessageLookupByLibrary.simpleMessage("Create Variant"),
    "currency": MessageLookupByLibrary.simpleMessage("Currency"),
    "dashboard_cache_saved": MessageLookupByLibrary.simpleMessage(
      "Cache Saved",
    ),
    "dashboard_call_times": m6,
    "dashboard_completion_tokens": MessageLookupByLibrary.simpleMessage(
      "Total Completion",
    ),
    "dashboard_est_cost": m7,
    "dashboard_history_record": MessageLookupByLibrary.simpleMessage(
      "Recent Call Logs",
    ),
    "dashboard_hour_record": MessageLookupByLibrary.simpleMessage(
      "Today\'s Hourly Logs",
    ),
    "dashboard_key_dist": MessageLookupByLibrary.simpleMessage(
      "API Key Distribution",
    ),
    "dashboard_model_dist": MessageLookupByLibrary.simpleMessage(
      "Model Usage Breakdown",
    ),
    "dashboard_no_record": MessageLookupByLibrary.simpleMessage(
      "No Call Records",
    ),
    "dashboard_prompt_tokens": MessageLookupByLibrary.simpleMessage(
      "Total Prompt",
    ),
    "dashboard_selected_period": MessageLookupByLibrary.simpleMessage(
      "Selected Period Details",
    ),
    "dashboard_total_tokens": MessageLookupByLibrary.simpleMessage(
      "Total Usage",
    ),
    "dashboard_usage_trend": MessageLookupByLibrary.simpleMessage("Call Trend"),
    "db_downgrade_content": MessageLookupByLibrary.simpleMessage(
      "If you see this error, it means you have opened data created by a newer version of the software with an older version. This may cause the application to crash or completely corrupt the data.\nTo protect your data, this startup has been blocked. Please update the software to a newer version first.",
    ),
    "db_downgrade_error": m8,
    "db_downgrade_title": MessageLookupByLibrary.simpleMessage(
      "Database Version Incompatible",
    ),
    "default_index_method": MessageLookupByLibrary.simpleMessage(
      "Default index method",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "delete_confirm": MessageLookupByLibrary.simpleMessage(
      "Confirm your delete.",
    ),
    "delete_keys_warning": MessageLookupByLibrary.simpleMessage(
      "Checking this will delete all existing API keys. Continue?",
    ),
    "delete_long_press": MessageLookupByLibrary.simpleMessage(
      "Delete (LongPress)",
    ),
    "delete_variant_confirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this model variant? This action cannot be undone.",
    ),
    "disable": MessageLookupByLibrary.simpleMessage("Disable"),
    "disable_persona": MessageLookupByLibrary.simpleMessage("Disable Persona"),
    "discard_changes": MessageLookupByLibrary.simpleMessage("Discard Changes"),
    "download": MessageLookupByLibrary.simpleMessage("Download"),
    "drag_image_hint": MessageLookupByLibrary.simpleMessage("Drop image here"),
    "drop_files_hint": MessageLookupByLibrary.simpleMessage("Drop files here"),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "edit_entries": MessageLookupByLibrary.simpleMessage("Edit entries"),
    "edit_knowledge_base": MessageLookupByLibrary.simpleMessage(
      "Edit knowledge base",
    ),
    "edit_model_variant": MessageLookupByLibrary.simpleMessage(
      "Edit Model Variant",
    ),
    "edit_more": MessageLookupByLibrary.simpleMessage("Edit more"),
    "edit_persona": MessageLookupByLibrary.simpleMessage("Edit persona"),
    "edit_provider": m9,
    "email_with_holder": m10,
    "embedding": MessageLookupByLibrary.simpleMessage("Embedding"),
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
    "endPoint_might_not_valid": MessageLookupByLibrary.simpleMessage(
      "Address might not be valid",
    ),
    "endPoint_not_set": MessageLookupByLibrary.simpleMessage(
      "API end point not set",
    ),
    "end_point": m11,
    "end_point_preview": MessageLookupByLibrary.simpleMessage(
      "API end point preview",
    ),
    "end_point_set": MessageLookupByLibrary.simpleMessage("EndPoint set"),
    "end_point_type": MessageLookupByLibrary.simpleMessage("EndPoint type"),
    "end_point_type_set": MessageLookupByLibrary.simpleMessage(
      "EndPoint type set",
    ),
    "end_point_with_holder": m12,
    "enlarge_context_or_simplify_prompt": MessageLookupByLibrary.simpleMessage(
      "Enlarge context or simplify prompt",
    ),
    "enter_cache_price": MessageLookupByLibrary.simpleMessage(
      "Please enter Cache Read price",
    ),
    "enter_completion_price": MessageLookupByLibrary.simpleMessage(
      "Please enter Completion price",
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
    "enter_prompt_price": MessageLookupByLibrary.simpleMessage(
      "Please enter Prompt price",
    ),
    "enter_provider_details": MessageLookupByLibrary.simpleMessage(
      "Enter provider details",
    ),
    "enter_regex_hint": MessageLookupByLibrary.simpleMessage("Enter regex"),
    "enter_session_name": MessageLookupByLibrary.simpleMessage(
      "Enter new session name",
    ),
    "enter_sys_prompt_here": MessageLookupByLibrary.simpleMessage(
      "Enter system prompt here... \n MarkDown is supported , enter \"/\" for more options.",
    ),
    "error_details": MessageLookupByLibrary.simpleMessage("Error Details"),
    "error_message": MessageLookupByLibrary.simpleMessage("Error Message"),
    "error_occurred": MessageLookupByLibrary.simpleMessage("Error"),
    "error_occurred_with_error": m13,
    "ex_and": MessageLookupByLibrary.simpleMessage(" and "),
    "ex_while": m14,
    "fetch_failed": MessageLookupByLibrary.simpleMessage("Fetch Failed"),
    "fetching_models": MessageLookupByLibrary.simpleMessage(
      "Fetching models...",
    ),
    "file": MessageLookupByLibrary.simpleMessage("File"),
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
    "front_page_hintLine_char1": MessageLookupByLibrary.simpleMessage("Use "),
    "front_page_hintLine_char2": MessageLookupByLibrary.simpleMessage(
      " to chat with ",
    ),
    "front_page_hintLine_char3": MessageLookupByLibrary.simpleMessage(""),
    "front_page_titleSlogan": MessageLookupByLibrary.simpleMessage(
      "How can I help you?",
    ),
    "full_settings": MessageLookupByLibrary.simpleMessage("Full Settings"),
    "general_settings": MessageLookupByLibrary.simpleMessage(
      "General settings",
    ),
    "generate_message": MessageLookupByLibrary.simpleMessage(
      "Generate message",
    ),
    "generate_title": MessageLookupByLibrary.simpleMessage("Generate title"),
    "generate_title_hint": MessageLookupByLibrary.simpleMessage(
      "Generate a title for this chat will overwrite the previous one",
    ),
    "generating_title": MessageLookupByLibrary.simpleMessage(
      "Generating conversation title...",
    ),
    "get_api_key": MessageLookupByLibrary.simpleMessage("Get API Key"),
    "get_help": MessageLookupByLibrary.simpleMessage("Get Help"),
    "github_repo": MessageLookupByLibrary.simpleMessage("GitHub Repository"),
    "give_up_edit_confirm": MessageLookupByLibrary.simpleMessage(
      "Give up edit?",
    ),
    "go_back": MessageLookupByLibrary.simpleMessage("Go back"),
    "google_compatible_api": MessageLookupByLibrary.simpleMessage(
      "Google compatible API",
    ),
    "got_it": MessageLookupByLibrary.simpleMessage("Got it"),
    "help": MessageLookupByLibrary.simpleMessage("Help"),
    "help_guides": MessageLookupByLibrary.simpleMessage("Help & Guides"),
    "help_links": MessageLookupByLibrary.simpleMessage("Help Links"),
    "hide_cot": MessageLookupByLibrary.simpleMessage("Hide  thoughts"),
    "hide_document": MessageLookupByLibrary.simpleMessage("Hide Docs"),
    "hide_knowledge_base_results": MessageLookupByLibrary.simpleMessage(
      "Hide knowledge base search results",
    ),
    "hide_source_code": MessageLookupByLibrary.simpleMessage(
      "Hide source code",
    ),
    "hover_to_see_session": MessageLookupByLibrary.simpleMessage(
      "Hover to preview session",
    ),
    "image2imageGenerate": MessageLookupByLibrary.simpleMessage(
      "Image to Image Generation",
    ),
    "imageGenerate": MessageLookupByLibrary.simpleMessage("Image Generation"),
    "image_load_fail": MessageLookupByLibrary.simpleMessage(
      "Image load failed.",
    ),
    "index_all": MessageLookupByLibrary.simpleMessage("Index all"),
    "index_settings": MessageLookupByLibrary.simpleMessage("Index settings"),
    "invalid_number": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid number",
    ),
    "keyword_index": MessageLookupByLibrary.simpleMessage("Keyword index"),
    "keyword_index_hint": MessageLookupByLibrary.simpleMessage(
      "When message contains any keywords, the whole content will be sent",
    ),
    "keyword_match": MessageLookupByLibrary.simpleMessage("Keyword match"),
    "knowledge_base": MessageLookupByLibrary.simpleMessage("Knowledge base"),
    "knowledge_base_and_contexts": MessageLookupByLibrary.simpleMessage(
      "Knowledge base & contexts",
    ),
    "knowledge_base_tokens": m15,
    "language_select": MessageLookupByLibrary.simpleMessage(
      "Select a language",
    ),
    "language_settings": MessageLookupByLibrary.simpleMessage(
      "Language settings",
    ),
    "language_switch_restart_note": MessageLookupByLibrary.simpleMessage(
      "Some changes may require a restart to take effect.",
    ),
    "limit_model_generate_length": MessageLookupByLibrary.simpleMessage(
      "Limit model maximum generate length",
    ),
    "loading_error": m16,
    "log_clear": MessageLookupByLibrary.simpleMessage("Clear logs"),
    "log_copied_to_clipboard": MessageLookupByLibrary.simpleMessage(
      "Logs copied to clipboard",
    ),
    "log_copy": MessageLookupByLibrary.simpleMessage("Copy logs"),
    "log_enable_global_catch": MessageLookupByLibrary.simpleMessage(
      "Enable global log capture (partial interception takes effect after restart)",
    ),
    "log_enable_global_catch_hint": MessageLookupByLibrary.simpleMessage(
      "When enabled, console outputs and uncaught errors are automatically recorded locally.",
    ),
    "log_file_not_init": MessageLookupByLibrary.simpleMessage(
      "Log file not initialized",
    ),
    "log_loading": MessageLookupByLibrary.simpleMessage("Loading logs..."),
    "log_none": MessageLookupByLibrary.simpleMessage("No logs"),
    "log_read_fail": m17,
    "log_refresh": MessageLookupByLibrary.simpleMessage("Refresh logs"),
    "log_settings": MessageLookupByLibrary.simpleMessage("Log capture"),
    "long_press": MessageLookupByLibrary.simpleMessage("Long press"),
    "longest_opening": m18,
    "match_confirmed": MessageLookupByLibrary.simpleMessage("Confirmed"),
    "match_conflict": MessageLookupByLibrary.simpleMessage("Match Conflict"),
    "match_review_title": MessageLookupByLibrary.simpleMessage(
      "Review Model Matches",
    ),
    "match_similarity": m19,
    "match_suggested": MessageLookupByLibrary.simpleMessage("Suggested"),
    "match_unsupported": MessageLookupByLibrary.simpleMessage("Unmatched"),
    "matching_models": MessageLookupByLibrary.simpleMessage(
      "Matching models...",
    ),
    "maximize": MessageLookupByLibrary.simpleMessage("Maximize"),
    "memory_content": MessageLookupByLibrary.simpleMessage("Memory content"),
    "memory_content_waring": MessageLookupByLibrary.simpleMessage(
      "Memory content cannot be empty",
    ),
    "memory_manage": MessageLookupByLibrary.simpleMessage("Memory manage"),
    "memory_name": MessageLookupByLibrary.simpleMessage("Memory name"),
    "memory_name_waring": MessageLookupByLibrary.simpleMessage(
      "Memory name cannot be empty",
    ),
    "message_no_content": MessageLookupByLibrary.simpleMessage(
      "Something went wrong , the model returns a message without content.",
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
    "model_breakdown": MessageLookupByLibrary.simpleMessage("Model Breakdown"),
    "model_call_name_hint": MessageLookupByLibrary.simpleMessage(
      "Enter call name (eg: qwen/qwen-7b-chat)",
    ),
    "model_configure": MessageLookupByLibrary.simpleMessage(
      "Model configuration",
    ),
    "model_configure_not_set": MessageLookupByLibrary.simpleMessage(
      "Model not set",
    ),
    "model_configured": m20,
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
    "model_friendly_name_exists": MessageLookupByLibrary.simpleMessage(
      "Friendly name already exists",
    ),
    "model_friendly_name_hint": MessageLookupByLibrary.simpleMessage(
      "Enter the model\'s friendly name (eg: Qwen 7B)",
    ),
    "model_list": MessageLookupByLibrary.simpleMessage("Model List"),
    "model_local_telling": MessageLookupByLibrary.simpleMessage(
      "Pass the local info",
    ),
    "model_management": MessageLookupByLibrary.simpleMessage(
      "Model Management",
    ),
    "model_management_official_hint": MessageLookupByLibrary.simpleMessage(
      "Tip: Official models are automatically kept up-to-date to ensure the best experience and do not support manual editing.",
    ),
    "model_maximum_context_length": MessageLookupByLibrary.simpleMessage(
      "Model maximum context length",
    ),
    "model_maximum_generate_length": MessageLookupByLibrary.simpleMessage(
      "Model maximum generate length",
    ),
    "model_not_found": MessageLookupByLibrary.simpleMessage(
      "Model not found , please check your spelling",
    ),
    "model_or_dimension_not_set": MessageLookupByLibrary.simpleMessage(
      "Model or dimension not set",
    ),
    "model_param_frequency_penalty": MessageLookupByLibrary.simpleMessage(
      "Frequency Penalty",
    ),
    "model_param_include_reasoning": MessageLookupByLibrary.simpleMessage(
      "Include Reasoning",
    ),
    "model_param_logit_bias": MessageLookupByLibrary.simpleMessage(
      "Logit Bias",
    ),
    "model_param_max_tokens": MessageLookupByLibrary.simpleMessage(
      "Max Completion Tokens",
    ),
    "model_param_min_p": MessageLookupByLibrary.simpleMessage("Min P"),
    "model_param_presence_penalty": MessageLookupByLibrary.simpleMessage(
      "Presence Penalty",
    ),
    "model_param_reasoning": MessageLookupByLibrary.simpleMessage("Reasoning"),
    "model_param_repetition_penalty": MessageLookupByLibrary.simpleMessage(
      "Repetition Penalty",
    ),
    "model_param_response_format": MessageLookupByLibrary.simpleMessage(
      "Response Format",
    ),
    "model_param_seed": MessageLookupByLibrary.simpleMessage("Seed"),
    "model_param_stop": MessageLookupByLibrary.simpleMessage("Stop Sequences"),
    "model_param_structured_outputs": MessageLookupByLibrary.simpleMessage(
      "Structured Outputs",
    ),
    "model_param_temperature": MessageLookupByLibrary.simpleMessage(
      "Temperature",
    ),
    "model_param_thinking": MessageLookupByLibrary.simpleMessage("Thinking"),
    "model_param_tool_choice": MessageLookupByLibrary.simpleMessage(
      "Tool Choice",
    ),
    "model_param_tools": MessageLookupByLibrary.simpleMessage("Tools List"),
    "model_param_top_a": MessageLookupByLibrary.simpleMessage("Top A"),
    "model_param_top_k": MessageLookupByLibrary.simpleMessage("Top K"),
    "model_param_top_p": MessageLookupByLibrary.simpleMessage("Top P"),
    "model_pricing_settings": MessageLookupByLibrary.simpleMessage(
      "Model Pricing Settings",
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
    "model_unavailable": MessageLookupByLibrary.simpleMessage(
      "Current model is unavailable, please select a new one.",
    ),
    "modify_session_name": MessageLookupByLibrary.simpleMessage(
      "Modify session name",
    ),
    "my_api_no_key": MessageLookupByLibrary.simpleMessage(
      "My API does not need an API key",
    ),
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "name_new_branch": MessageLookupByLibrary.simpleMessage(
      "Name your new branch",
    ),
    "name_not_set": MessageLookupByLibrary.simpleMessage("Unnamed"),
    "new_chat_session": MessageLookupByLibrary.simpleMessage(
      "New chat session",
    ),
    "new_version_available": MessageLookupByLibrary.simpleMessage(
      "New version available",
    ),
    "next_step": MessageLookupByLibrary.simpleMessage("Next step"),
    "no_agent": MessageLookupByLibrary.simpleMessage(
      "No agent , please add one",
    ),
    "no_api_key_added_warning": MessageLookupByLibrary.simpleMessage(
      "Please add an API key or check \'No Key Needed\' first.",
    ),
    "no_data_period": MessageLookupByLibrary.simpleMessage(
      "No data in this period",
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
    "no_key_needed": MessageLookupByLibrary.simpleMessage("No API Key Needed"),
    "no_limit": MessageLookupByLibrary.simpleMessage("No limit"),
    "no_memory": MessageLookupByLibrary.simpleMessage("No memory"),
    "no_message": MessageLookupByLibrary.simpleMessage("no message"),
    "no_model": MessageLookupByLibrary.simpleMessage("No model yet"),
    "no_model_plz_add": MessageLookupByLibrary.simpleMessage(
      "No model yet, please add one first.",
    ),
    "no_models_found": MessageLookupByLibrary.simpleMessage(
      "No models were found. Please verify your API configuration or endpoint.",
    ),
    "no_persona": MessageLookupByLibrary.simpleMessage("No persona"),
    "no_pop_out_announcement": MessageLookupByLibrary.simpleMessage(
      "Don\'t show this announcement again",
    ),
    "no_preview": MessageLookupByLibrary.simpleMessage("No preview available"),
    "no_provider": MessageLookupByLibrary.simpleMessage("No providers "),
    "no_results": MessageLookupByLibrary.simpleMessage("No results"),
    "no_rules": MessageLookupByLibrary.simpleMessage("No rules"),
    "official_website": MessageLookupByLibrary.simpleMessage(
      "Official Website",
    ),
    "openai_compatible_api": MessageLookupByLibrary.simpleMessage(
      "OpenAI compatible API",
    ),
    "openai_completion_compatible_api": MessageLookupByLibrary.simpleMessage(
      "OpenAI Completion (Legacy) compatible API",
    ),
    "opening": MessageLookupByLibrary.simpleMessage("Opening"),
    "opening_configure_title": MessageLookupByLibrary.simpleMessage(
      "Opening Statement configuration",
    ),
    "opening_message_hint": MessageLookupByLibrary.simpleMessage(
      "Sent automatically when a new chat starts (Markdown supported)",
    ),
    "opening_message_label": MessageLookupByLibrary.simpleMessage(
      "Opening Message",
    ),
    "opening_set": MessageLookupByLibrary.simpleMessage("Opening settings"),
    "opening_slogan_hint": MessageLookupByLibrary.simpleMessage(
      "Display a custom slogan when no session is active",
    ),
    "opening_slogan_label": MessageLookupByLibrary.simpleMessage(
      "Custom Slogan",
    ),
    "or_expand_window": MessageLookupByLibrary.simpleMessage(
      "or please make the window bigger",
    ),
    "over_maximum_context_length_hint": m21,
    "personaEX_personaNotFound": MessageLookupByLibrary.simpleMessage(
      "persona not found",
    ),
    "personaEX_unknownError": MessageLookupByLibrary.simpleMessage(
      "unknown error",
    ),
    "personaEx": MessageLookupByLibrary.simpleMessage("Persona error"),
    "personaEx_failLoading_parse_error": MessageLookupByLibrary.simpleMessage(
      "persona data is corrupted",
    ),
    "personaEx_recursive_call": MessageLookupByLibrary.simpleMessage(
      " while loading persona",
    ),
    "persona_additonal_information": MessageLookupByLibrary.simpleMessage(
      "Additional information about the persona",
    ),
    "persona_description_hint": MessageLookupByLibrary.simpleMessage(
      "Describe yourself...",
    ),
    "persona_system_disabled": MessageLookupByLibrary.simpleMessage(
      "Persona System Disabled",
    ),
    "plz_enter": MessageLookupByLibrary.simpleMessage("Please enter "),
    "plz_enter_a_number_bigger_than_zero": MessageLookupByLibrary.simpleMessage(
      "Enter a >0 number",
    ),
    "plz_enter_content": MessageLookupByLibrary.simpleMessage(
      "Please enter content",
    ),
    "plz_enter_description": MessageLookupByLibrary.simpleMessage(
      "Please enter description",
    ),
    "plz_enter_digit": MessageLookupByLibrary.simpleMessage("Enter a digit"),
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
    "preview_session": MessageLookupByLibrary.simpleMessage("Preview session"),
    "previous_step": MessageLookupByLibrary.simpleMessage("Previous Step"),
    "price_not_empty": MessageLookupByLibrary.simpleMessage(
      "Price cannot be empty",
    ),
    "prompt": MessageLookupByLibrary.simpleMessage("Prompt"),
    "prompt_price_per_1k": MessageLookupByLibrary.simpleMessage(
      "Prompt Price (per 1M tokens)",
    ),
    "provider_delete_warning": m22,
    "provider_select": MessageLookupByLibrary.simpleMessage(
      "Select the provider",
    ),
    "quick_chat": MessageLookupByLibrary.simpleMessage("Quick Chat"),
    "quick_chat_enabled": MessageLookupByLibrary.simpleMessage(
      "Quick Chat Enabled",
    ),
    "quit": MessageLookupByLibrary.simpleMessage("Quit"),
    "reasoned": MessageLookupByLibrary.simpleMessage("Thought for a moment"),
    "reasoning": MessageLookupByLibrary.simpleMessage("Thinking..."),
    "regex_index": MessageLookupByLibrary.simpleMessage("Regex index"),
    "regex_index_hint": MessageLookupByLibrary.simpleMessage(
      "When message matches any regex, the whole content will be sent",
    ),
    "regex_match": MessageLookupByLibrary.simpleMessage("Regex match"),
    "related_docs": MessageLookupByLibrary.simpleMessage("Documentation"),
    "remark": MessageLookupByLibrary.simpleMessage("Remark"),
    "rename": MessageLookupByLibrary.simpleMessage("Rename"),
    "request_daily_limit": MessageLookupByLibrary.simpleMessage(
      "Request per day",
    ),
    "request_per_minute": MessageLookupByLibrary.simpleMessage(
      "Request per minute",
    ),
    "restore": MessageLookupByLibrary.simpleMessage("Restore"),
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "save_and_exit": MessageLookupByLibrary.simpleMessage("Save and Exit"),
    "save_to_agent_settings": m23,
    "search_any_chat_message": MessageLookupByLibrary.simpleMessage(
      "Search any chat message...",
    ),
    "search_for_models": MessageLookupByLibrary.simpleMessage("Search model"),
    "search_provider": MessageLookupByLibrary.simpleMessage("Search provider"),
    "searched_knowledge_base": MessageLookupByLibrary.simpleMessage(
      "Searched Knowledge Base",
    ),
    "searching_knowledge_base": MessageLookupByLibrary.simpleMessage(
      "Searching Knowledge Base...",
    ),
    "select_agent": MessageLookupByLibrary.simpleMessage("Select agent"),
    "select_agent_default_persona": MessageLookupByLibrary.simpleMessage(
      "Default persona for the agent",
    ),
    "select_api_type": MessageLookupByLibrary.simpleMessage(
      "Select the type of the API",
    ),
    "select_image_hint": MessageLookupByLibrary.simpleMessage(
      "Click to select or drop an image",
    ),
    "select_model": MessageLookupByLibrary.simpleMessage("Select Model"),
    "select_model_hint": MessageLookupByLibrary.simpleMessage(
      "Please select a model",
    ),
    "select_or_add_memory": MessageLookupByLibrary.simpleMessage(
      "Select or add a memory",
    ),
    "select_parameter": MessageLookupByLibrary.simpleMessage(
      "Select parameter to add",
    ),
    "select_provider": MessageLookupByLibrary.simpleMessage("Select provider"),
    "selected_agent": m24,
    "send_a_message_hint": MessageLookupByLibrary.simpleMessage(
      "Send a message (MD  supported), enter \"/\" for more options",
    ),
    "set_as_default": MessageLookupByLibrary.simpleMessage("Set as default"),
    "setup_add_agent": MessageLookupByLibrary.simpleMessage(
      "Next, let\'s add a Agent",
    ),
    "setup_add_agent_hint": MessageLookupByLibrary.simpleMessage(
      "Agent is a highly customize AI assistant，\n Through UNIChat\'s powerful agent engine, \n You can create whoever you wish!",
    ),
    "setup_add_persona": MessageLookupByLibrary.simpleMessage(
      "Now, add a persona",
    ),
    "setup_add_persona_hint": MessageLookupByLibrary.simpleMessage(
      "AI learn about you through personas,\n you can be \"The true me\"or let the AIs calls you \"Master\" :-D ",
    ),
    "setup_agent_hint": MessageLookupByLibrary.simpleMessage("Create a agent"),
    "setup_api_prepared": MessageLookupByLibrary.simpleMessage(
      "I\'ve got my apiKeys",
    ),
    "setup_finished": MessageLookupByLibrary.simpleMessage(
      "Now we\'re ready to go!",
    ),
    "setup_finished_btn": MessageLookupByLibrary.simpleMessage(
      "Unlock the brand new Ai chat experience ->",
    ),
    "setup_knowledgeBase": MessageLookupByLibrary.simpleMessage(
      "Create a knowledge base",
    ),
    "setup_persona": MessageLookupByLibrary.simpleMessage("Create a persona"),
    "setup_pre_warn_content": MessageLookupByLibrary.simpleMessage(
      "# UNIChat Development Announcement\n\n**To All UNIChat Users:**\n\nThank you for choosing UNIChat!\n\nUNIChat is currently entering the **Stable** phase. While core features are now mature and functional, we are still refining the experience before the final widespread release. Please keep the following in mind:\n\n---\n\n### 1. ⚠ Stability and Risk Disclaimer\n\nAlthough we have reached the stable phase, minor regressions or hardware-specific issues may still occur during rapid updates.\n\n### 2. 🐞 Bug Reporting and Support\n\nIf you encounter any bugs or unexpected behavior, please report them to us via:\n\n*   Submit an **Issue** on our **GitHub Repository**.\n*   Please include your OS version, app version (found in Settings), and clear steps to reproduce the issue.\n\n### 3. 📖 Documentation and The Art of Asking Questions\n\nTo ensure efficient communication and problem-solving, we encourage you to:\n\n*   **Consult the Docs:** Check our official documentation at [https://unichat.wejoinnwk.com](https://unichat.wejoinnwk.com) first. Many answers are already available there.\n*   **The Art of Asking Questions:** High-quality feedback is the fastest way to get solutions. Please be specific, concise, and provide enough context. We suggest following the principles in **[The Art of Asking Questions](https://github.com/ryanhanwu/How-To-Ask-Questions-The-Smart-Way/blob/main/README-en.md)** to help us solve your problem efficiently.\n\n### 4. 🌐 Open Source and Community\n\nUNIChat remains an open-source project and we warmly welcome contributions, whether they are bug fixes, documentation improvements, or feature suggestions via **Pull Requests**.\n\n---\n\n**Acknowledgement:** Your feedback is instrumental in making UNIChat better for everyone. Thank you for your support!",
    ),
    "setup_pre_warning": MessageLookupByLibrary.simpleMessage(
      "Before we go on : ",
    ),
    "setup_provider_add": MessageLookupByLibrary.simpleMessage(
      "Let\'s add a Api Provider first",
    ),
    "setup_provider_add_hint": MessageLookupByLibrary.simpleMessage(
      "You can check the document on the right to lear about it.",
    ),
    "setup_start": MessageLookupByLibrary.simpleMessage("Start"),
    "show_all_models": MessageLookupByLibrary.simpleMessage("Show all models"),
    "show_available_models": MessageLookupByLibrary.simpleMessage(
      "Show available models",
    ),
    "show_cot": MessageLookupByLibrary.simpleMessage("Show thoughts"),
    "show_document": MessageLookupByLibrary.simpleMessage("Show Docs"),
    "show_knowledge_base_results": MessageLookupByLibrary.simpleMessage(
      "Show knowledge base search results",
    ),
    "show_source_code": MessageLookupByLibrary.simpleMessage(
      "Show source code",
    ),
    "sidebar_agent": MessageLookupByLibrary.simpleMessage("Agents"),
    "sidebar_chat": MessageLookupByLibrary.simpleMessage("Chat"),
    "sidebar_show_title": MessageLookupByLibrary.simpleMessage(
      "Show Sidebar Text Titles",
    ),
    "skip": MessageLookupByLibrary.simpleMessage("Skip"),
    "skip_to_quick_chat": MessageLookupByLibrary.simpleMessage(
      "Skip and quick chat",
    ),
    "slogan": MessageLookupByLibrary.simpleMessage(
      "A powerful AI agent integrated ChatApp",
    ),
    "star_github": MessageLookupByLibrary.simpleMessage(
      "Star us on GitHub plz(≧∇BSD)",
    ),
    "start_conversation_with_selected_agent":
        MessageLookupByLibrary.simpleMessage(
          "Start conversation with selected agent",
        ),
    "status_code": MessageLookupByLibrary.simpleMessage("Status Code"),
    "support_formats": MessageLookupByLibrary.simpleMessage(
      "md,docx,csv,txt,json,html",
    ),
    "supports_files_api": MessageLookupByLibrary.simpleMessage(
      "Whether this provider supports files API?",
    ),
    "swipe_right_to_see_session": MessageLookupByLibrary.simpleMessage(
      "Swipe right on the title to preview session",
    ),
    "switch_persona": MessageLookupByLibrary.simpleMessage("Switch persona"),
    "sys_prompt": MessageLookupByLibrary.simpleMessage("System prompt"),
    "system_internal_prompt": m25,
    "system_prompt_tokens": m26,
    "textGenerate": MessageLookupByLibrary.simpleMessage("Text Generation"),
    "thinking": MessageLookupByLibrary.simpleMessage("Thinking"),
    "thinking_mode_disabled": MessageLookupByLibrary.simpleMessage("Disabled"),
    "thinking_mode_enabled": MessageLookupByLibrary.simpleMessage("Enabled"),
    "thinking_mode_high": MessageLookupByLibrary.simpleMessage("High"),
    "thinking_mode_low": MessageLookupByLibrary.simpleMessage("Low"),
    "thinking_mode_medium": MessageLookupByLibrary.simpleMessage("Medium"),
    "thinking_mode_xhigh": MessageLookupByLibrary.simpleMessage("XHigh"),
    "title": MessageLookupByLibrary.simpleMessage("UNIChat"),
    "toggle_session_selector": MessageLookupByLibrary.simpleMessage(
      "Toggle session selector",
    ),
    "token_available_for_chat": m27,
    "token_daily_limit": MessageLookupByLibrary.simpleMessage(
      "Token limit per day",
    ),
    "token_usage": MessageLookupByLibrary.simpleMessage("Token Usage"),
    "toolCall": MessageLookupByLibrary.simpleMessage("Tool Calling"),
    "total_context_lim": m28,
    "total_tokens": MessageLookupByLibrary.simpleMessage("Total Tokens"),
    "type_with_holder": m29,
    "ui_edited": MessageLookupByLibrary.simpleMessage("Edited UI"),
    "ui_editing": MessageLookupByLibrary.simpleMessage("Editing UI"),
    "ui_interaction_set": MessageLookupByLibrary.simpleMessage(
      "UI interaction (BETA) settings",
    ),
    "ui_interactions": MessageLookupByLibrary.simpleMessage("UI interactions"),
    "ui_interactions_tokens": m30,
    "unknown": MessageLookupByLibrary.simpleMessage("unknown"),
    "unsaved_changes_message": MessageLookupByLibrary.simpleMessage(
      "Detected unsaved changes. Do you want to save before exiting?",
    ),
    "unsaved_changes_title": MessageLookupByLibrary.simpleMessage(
      "Unsaved Changes",
    ),
    "unsupported_format": MessageLookupByLibrary.simpleMessage(
      "Unsupported format",
    ),
    "usage_trend": MessageLookupByLibrary.simpleMessage("Usage Trend"),
    "user": MessageLookupByLibrary.simpleMessage("User"),
    "usr_persona_set": MessageLookupByLibrary.simpleMessage(
      "User Persona Settings",
    ),
    "valid": MessageLookupByLibrary.simpleMessage("Valid"),
    "vec_index_hint": MessageLookupByLibrary.simpleMessage(
      "Match the chunks of content which are similar to the query",
    ),
    "vector_index": MessageLookupByLibrary.simpleMessage("Vector index"),
    "version_preview": MessageLookupByLibrary.simpleMessage(
      "V 1.0 Beta Preview",
    ),
    "video": MessageLookupByLibrary.simpleMessage("Video"),
    "view_all_provider_provide_model": MessageLookupByLibrary.simpleMessage(
      "Provider who provides this model",
    ),
    "visual": MessageLookupByLibrary.simpleMessage("Visual Understanding"),
    "website_manage": MessageLookupByLibrary.simpleMessage("Website manage"),
    "window_too_small_to_display_allPanels":
        MessageLookupByLibrary.simpleMessage(
          "The window is too small for fitting all the panels",
        ),
  };
}
