// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `UNIChat`
  String get title {
    return Intl.message('UNIChat', name: 'title', desc: '', args: []);
  }

  /// `No agent , please add one`
  String get no_agent {
    return Intl.message(
      'No agent , please add one',
      name: 'no_agent',
      desc: '',
      args: [],
    );
  }

  /// `no chat history`
  String get no_history {
    return Intl.message(
      'no chat history',
      name: 'no_history',
      desc: '',
      args: [],
    );
  }

  /// `Hover to preview session`
  String get hover_to_see_session {
    return Intl.message(
      'Hover to preview session',
      name: 'hover_to_see_session',
      desc: '',
      args: [],
    );
  }

  /// `Swipe right on the title to preview session`
  String get swipe_right_to_see_session {
    return Intl.message(
      'Swipe right on the title to preview session',
      name: 'swipe_right_to_see_session',
      desc: '',
      args: [],
    );
  }

  /// `Preview session`
  String get preview_session {
    return Intl.message(
      'Preview session',
      name: 'preview_session',
      desc: '',
      args: [],
    );
  }

  /// `no message`
  String get no_message {
    return Intl.message('no message', name: 'no_message', desc: '', args: []);
  }

  /// `Generate title`
  String get generate_title {
    return Intl.message(
      'Generate title',
      name: 'generate_title',
      desc: '',
      args: [],
    );
  }

  /// `Generate a title for this chat will overwrite the previous one`
  String get generate_title_hint {
    return Intl.message(
      'Generate a title for this chat will overwrite the previous one',
      name: 'generate_title_hint',
      desc: '',
      args: [],
    );
  }

  /// `Rename`
  String get rename {
    return Intl.message('Rename', name: 'rename', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Are you sure to delete this chat?`
  String get confirm_delete_session {
    return Intl.message(
      'Are you sure to delete this chat?',
      name: 'confirm_delete_session',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Confirm (LongPress)`
  String get confirm_long_press {
    return Intl.message(
      'Confirm (LongPress)',
      name: 'confirm_long_press',
      desc: '',
      args: [],
    );
  }

  /// `Modify session name`
  String get modify_session_name {
    return Intl.message(
      'Modify session name',
      name: 'modify_session_name',
      desc: '',
      args: [],
    );
  }

  /// `Enter new session name`
  String get enter_session_name {
    return Intl.message(
      'Enter new session name',
      name: 'enter_session_name',
      desc: '',
      args: [],
    );
  }

  /// `The window is too small for fitting all the panels`
  String get window_too_small_to_display_allPanels {
    return Intl.message(
      'The window is too small for fitting all the panels',
      name: 'window_too_small_to_display_allPanels',
      desc: '',
      args: [],
    );
  }

  /// `Automatically shrink panels to fit the window`
  String get auto_shrink_large_panel {
    return Intl.message(
      'Automatically shrink panels to fit the window',
      name: 'auto_shrink_large_panel',
      desc: '',
      args: [],
    );
  }

  /// `or please make the window bigger`
  String get or_expand_window {
    return Intl.message(
      'or please make the window bigger',
      name: 'or_expand_window',
      desc: '',
      args: [],
    );
  }

  /// `Finish editing`
  String get finish_edit {
    return Intl.message(
      'Finish editing',
      name: 'finish_edit',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure to delete this provider?`
  String get confirm_delete_provider {
    return Intl.message(
      'Are you sure to delete this provider?',
      name: 'confirm_delete_provider',
      desc: '',
      args: [],
    );
  }

  /// `Loading error:{errorContent}`
  String loading_error(Object errorContent) {
    return Intl.message(
      'Loading error:$errorContent',
      name: 'loading_error',
      desc: '',
      args: [errorContent],
    );
  }

  /// `API settings`
  String get api_settings {
    return Intl.message(
      'API settings',
      name: 'api_settings',
      desc: '',
      args: [],
    );
  }

  /// `Add a provider`
  String get add_provider {
    return Intl.message(
      'Add a provider',
      name: 'add_provider',
      desc: '',
      args: [],
    );
  }

  /// `No providers `
  String get no_provider {
    return Intl.message(
      'No providers ',
      name: 'no_provider',
      desc: '',
      args: [],
    );
  }

  /// `Type : {type}`
  String type_with_holder(Object type) {
    return Intl.message(
      'Type : $type',
      name: 'type_with_holder',
      desc: '',
      args: [type],
    );
  }

  /// `EndPoint:{endPoint}`
  String end_point_with_holder(Object endPoint) {
    return Intl.message(
      'EndPoint:$endPoint',
      name: 'end_point_with_holder',
      desc: '',
      args: [endPoint],
    );
  }

  /// `Edit provider:{provider}`
  String edit_provider(Object provider) {
    return Intl.message(
      'Edit provider:$provider',
      name: 'edit_provider',
      desc: '',
      args: [provider],
    );
  }

  /// `Select provider`
  String get select_provider {
    return Intl.message(
      'Select provider',
      name: 'select_provider',
      desc: '',
      args: [],
    );
  }

  /// `Enter provider details`
  String get enter_provider_details {
    return Intl.message(
      'Enter provider details',
      name: 'enter_provider_details',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message('Name', name: 'name', desc: '', args: []);
  }

  /// `EndPoint`
  String end_point(Object endPoint) {
    return Intl.message(
      'EndPoint',
      name: 'end_point',
      desc: '',
      args: [endPoint],
    );
  }

  /// `EndPoint set`
  String get end_point_set {
    return Intl.message(
      'EndPoint set',
      name: 'end_point_set',
      desc: '',
      args: [],
    );
  }

  /// `Enter API endpoint`
  String get enter_end_point {
    return Intl.message(
      'Enter API endpoint',
      name: 'enter_end_point',
      desc: '',
      args: [],
    );
  }

  /// `EndPoint type`
  String get end_point_type {
    return Intl.message(
      'EndPoint type',
      name: 'end_point_type',
      desc: '',
      args: [],
    );
  }

  /// `EndPoint type set`
  String get end_point_type_set {
    return Intl.message(
      'EndPoint type set',
      name: 'end_point_type_set',
      desc: '',
      args: [],
    );
  }

  /// `API Key`
  String get api_key {
    return Intl.message('API Key', name: 'api_key', desc: '', args: []);
  }

  /// `Add API key`
  String get add_api_key {
    return Intl.message('Add API key', name: 'add_api_key', desc: '', args: []);
  }

  /// `API key set`
  String get api_key_set {
    return Intl.message('API key set', name: 'api_key_set', desc: '', args: []);
  }

  /// `My API does not need an API key`
  String get my_api_no_key {
    return Intl.message(
      'My API does not need an API key',
      name: 'my_api_no_key',
      desc: '',
      args: [],
    );
  }

  /// `No API Key Needed`
  String get no_key_needed {
    return Intl.message(
      'No API Key Needed',
      name: 'no_key_needed',
      desc: '',
      args: [],
    );
  }

  /// `Checking this will delete all existing API keys. Continue?`
  String get delete_keys_warning {
    return Intl.message(
      'Checking this will delete all existing API keys. Continue?',
      name: 'delete_keys_warning',
      desc: '',
      args: [],
    );
  }

  /// `{apiKey} total`
  String api_key_total(Object apiKey) {
    return Intl.message(
      '$apiKey total',
      name: 'api_key_total',
      desc: '',
      args: [apiKey],
    );
  }

  /// `Auto Fetch Models`
  String get auto_fetch_models {
    return Intl.message(
      'Auto Fetch Models',
      name: 'auto_fetch_models',
      desc: '',
      args: [],
    );
  }

  /// `Fetching models...`
  String get fetching_models {
    return Intl.message(
      'Fetching models...',
      name: 'fetching_models',
      desc: '',
      args: [],
    );
  }

  /// `Matching models...`
  String get matching_models {
    return Intl.message(
      'Matching models...',
      name: 'matching_models',
      desc: '',
      args: [],
    );
  }

  /// `No models were found. Please verify your API configuration or endpoint.`
  String get no_models_found {
    return Intl.message(
      'No models were found. Please verify your API configuration or endpoint.',
      name: 'no_models_found',
      desc: '',
      args: [],
    );
  }

  /// `Review Model Matches`
  String get match_review_title {
    return Intl.message(
      'Review Model Matches',
      name: 'match_review_title',
      desc: '',
      args: [],
    );
  }

  /// `Confirmed`
  String get match_confirmed {
    return Intl.message(
      'Confirmed',
      name: 'match_confirmed',
      desc: '',
      args: [],
    );
  }

  /// `Suggested`
  String get match_suggested {
    return Intl.message(
      'Suggested',
      name: 'match_suggested',
      desc: '',
      args: [],
    );
  }

  /// `Unmatched`
  String get match_unsupported {
    return Intl.message(
      'Unmatched',
      name: 'match_unsupported',
      desc: '',
      args: [],
    );
  }

  /// `Add {count} models`
  String add_confirmed_models(Object count) {
    return Intl.message(
      'Add $count models',
      name: 'add_confirmed_models',
      desc: '',
      args: [count],
    );
  }

  /// `Please add an API key or check 'No Key Needed' first.`
  String get no_api_key_added_warning {
    return Intl.message(
      'Please add an API key or check \'No Key Needed\' first.',
      name: 'no_api_key_added_warning',
      desc: '',
      args: [],
    );
  }

  /// `No API keys yet \n Please press the + button to add one`
  String get add_api_key_hint {
    return Intl.message(
      'No API keys yet \n Please press the + button to add one',
      name: 'add_api_key_hint',
      desc: '',
      args: [],
    );
  }

  /// `Fill in the API key`
  String get fill_in_api_key {
    return Intl.message(
      'Fill in the API key',
      name: 'fill_in_api_key',
      desc: '',
      args: [],
    );
  }

  /// `Write a reminder (null if left blank)`
  String get fill_reminder_null_if_blank {
    return Intl.message(
      'Write a reminder (null if left blank)',
      name: 'fill_reminder_null_if_blank',
      desc: '',
      args: [],
    );
  }

  /// `Model`
  String get model {
    return Intl.message('Model', name: 'model', desc: '', args: []);
  }

  /// `No models yet \n Please press the + button to add one`
  String get add_model_hint {
    return Intl.message(
      'No models yet \n Please press the + button to add one',
      name: 'add_model_hint',
      desc: '',
      args: [],
    );
  }

  /// `Model call name`
  String get fill_model_call_name {
    return Intl.message(
      'Model call name',
      name: 'fill_model_call_name',
      desc: '',
      args: [],
    );
  }

  /// `Enter call name (eg: qwen/qwen-7b-chat)`
  String get model_call_name_hint {
    return Intl.message(
      'Enter call name (eg: qwen/qwen-7b-chat)',
      name: 'model_call_name_hint',
      desc: '',
      args: [],
    );
  }

  /// `Model friendly name`
  String get model_friendly_name {
    return Intl.message(
      'Model friendly name',
      name: 'model_friendly_name',
      desc: '',
      args: [],
    );
  }

  /// `Enter the model's friendly name (eg: Qwen 7B)`
  String get model_friendly_name_hint {
    return Intl.message(
      'Enter the model\'s friendly name (eg: Qwen 7B)',
      name: 'model_friendly_name_hint',
      desc: '',
      args: [],
    );
  }

  /// `Model family`
  String get model_family {
    return Intl.message(
      'Model family',
      name: 'model_family',
      desc: '',
      args: [],
    );
  }

  /// `Enter the model's family (eg: qwen3)`
  String get model_family_hint {
    return Intl.message(
      'Enter the model\'s family (eg: qwen3)',
      name: 'model_family_hint',
      desc: '',
      args: [],
    );
  }

  /// `Please fill in the model's call name`
  String get plz_fill_model_call_name {
    return Intl.message(
      'Please fill in the model\'s call name',
      name: 'plz_fill_model_call_name',
      desc: '',
      args: [],
    );
  }

  /// `Confirm to add this model`
  String get confirm_adding_model {
    return Intl.message(
      'Confirm to add this model',
      name: 'confirm_adding_model',
      desc: '',
      args: [],
    );
  }

  /// `Note that this is an embedding model , which cannot be used to chat`
  String get embedding_model_note {
    return Intl.message(
      'Note that this is an embedding model , which cannot be used to chat',
      name: 'embedding_model_note',
      desc: '',
      args: [],
    );
  }

  /// `Model ability`
  String get model_ability {
    return Intl.message(
      'Model ability',
      name: 'model_ability',
      desc: '',
      args: [],
    );
  }

  /// `Please select a model`
  String get select_model_hint {
    return Intl.message(
      'Please select a model',
      name: 'select_model_hint',
      desc: '',
      args: [],
    );
  }

  /// `No results`
  String get no_results {
    return Intl.message('No results', name: 'no_results', desc: '', args: []);
  }

  /// `Create new model`
  String get create_new_model {
    return Intl.message(
      'Create new model',
      name: 'create_new_model',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to abandon?`
  String get abandon_match_title {
    return Intl.message(
      'Are you sure you want to abandon?',
      name: 'abandon_match_title',
      desc: '',
      args: [],
    );
  }

  /// `Unsaved matching results will be lost.`
  String get abandon_match_subtitle {
    return Intl.message(
      'Unsaved matching results will be lost.',
      name: 'abandon_match_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Continue Editing`
  String get continue_editing {
    return Intl.message(
      'Continue Editing',
      name: 'continue_editing',
      desc: '',
      args: [],
    );
  }

  /// `Abandon and Exit`
  String get abandon_and_exit {
    return Intl.message(
      'Abandon and Exit',
      name: 'abandon_and_exit',
      desc: '',
      args: [],
    );
  }

  /// `Fetch Failed`
  String get fetch_failed {
    return Intl.message(
      'Fetch Failed',
      name: 'fetch_failed',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message('Retry', name: 'retry', desc: '', args: []);
  }

  /// `Friendly name already exists`
  String get model_friendly_name_exists {
    return Intl.message(
      'Friendly name already exists',
      name: 'model_friendly_name_exists',
      desc: '',
      args: [],
    );
  }

  /// `Match Conflict`
  String get match_conflict {
    return Intl.message(
      'Match Conflict',
      name: 'match_conflict',
      desc: '',
      args: [],
    );
  }

  /// `Create Variant`
  String get create_variant {
    return Intl.message(
      'Create Variant',
      name: 'create_variant',
      desc: '',
      args: [],
    );
  }

  /// `Select Model`
  String get select_model {
    return Intl.message(
      'Select Model',
      name: 'select_model',
      desc: '',
      args: [],
    );
  }

  /// `{percent}% Related`
  String match_similarity(Object percent) {
    return Intl.message(
      '$percent% Related',
      name: 'match_similarity',
      desc: '',
      args: [percent],
    );
  }

  /// `Show all models`
  String get show_all_models {
    return Intl.message(
      'Show all models',
      name: 'show_all_models',
      desc: '',
      args: [],
    );
  }

  /// `Show available models`
  String get show_available_models {
    return Intl.message(
      'Show available models',
      name: 'show_available_models',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Please enter `
  String get plz_enter {
    return Intl.message('Please enter ', name: 'plz_enter', desc: '', args: []);
  }

  /// `Add`
  String get add {
    return Intl.message('Add', name: 'add', desc: '', args: []);
  }

  /// `Go back`
  String get go_back {
    return Intl.message('Go back', name: 'go_back', desc: '', args: []);
  }

  /// `Next step`
  String get next_step {
    return Intl.message('Next step', name: 'next_step', desc: '', args: []);
  }

  /// `Select the type of the API`
  String get select_api_type {
    return Intl.message(
      'Select the type of the API',
      name: 'select_api_type',
      desc: '',
      args: [],
    );
  }

  /// `OpenAI compatible API`
  String get openai_compatible_api {
    return Intl.message(
      'OpenAI compatible API',
      name: 'openai_compatible_api',
      desc: '',
      args: [],
    );
  }

  /// `Google compatible API`
  String get google_compatible_api {
    return Intl.message(
      'Google compatible API',
      name: 'google_compatible_api',
      desc: '',
      args: [],
    );
  }

  /// `OpenAI Completion (Legacy) compatible API`
  String get openai_completion_compatible_api {
    return Intl.message(
      'OpenAI Completion (Legacy) compatible API',
      name: 'openai_completion_compatible_api',
      desc: '',
      args: [],
    );
  }

  /// `Whether this provider supports files API?`
  String get supports_files_api {
    return Intl.message(
      'Whether this provider supports files API?',
      name: 'supports_files_api',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error_occurred {
    return Intl.message('Error', name: 'error_occurred', desc: '', args: []);
  }

  /// `Error:{error}`
  String error_occurred_with_error(Object error) {
    return Intl.message(
      'Error:$error',
      name: 'error_occurred_with_error',
      desc: '',
      args: [error],
    );
  }

  /// `Please select an agent`
  String get plz_select_agent {
    return Intl.message(
      'Please select an agent',
      name: 'plz_select_agent',
      desc: '',
      args: [],
    );
  }

  /// `No persona`
  String get no_persona {
    return Intl.message('No persona', name: 'no_persona', desc: '', args: []);
  }

  /// `Please select a persona`
  String get plz_select_persona {
    return Intl.message(
      'Please select a persona',
      name: 'plz_select_persona',
      desc: '',
      args: [],
    );
  }

  /// `Quick Chat`
  String get quick_chat {
    return Intl.message(
      'Quick Chat',
      name: 'quick_chat',
      desc: 'Quick chat agent name',
      args: [],
    );
  }

  /// `Quick Chat Enabled`
  String get quick_chat_enabled {
    return Intl.message(
      'Quick Chat Enabled',
      name: 'quick_chat_enabled',
      desc: '',
      args: [],
    );
  }

  /// `Current model is unavailable, please select a new one.`
  String get model_unavailable {
    return Intl.message(
      'Current model is unavailable, please select a new one.',
      name: 'model_unavailable',
      desc: '',
      args: [],
    );
  }

  /// `Save this selection to agent settings?`
  String get save_to_agent_settings {
    return Intl.message(
      'Save this selection to agent settings?',
      name: 'save_to_agent_settings',
      desc: '',
      args: [],
    );
  }

  /// `Agent`
  String get agent {
    return Intl.message('Agent', name: 'agent', desc: '', args: []);
  }

  /// `Select an agent and start chatting`
  String get choose_agent_and_chat_hint {
    return Intl.message(
      'Select an agent and start chatting',
      name: 'choose_agent_and_chat_hint',
      desc: '',
      args: [],
    );
  }

  /// `How can I help you?`
  String get front_page_titleSlogan {
    return Intl.message(
      'How can I help you?',
      name: 'front_page_titleSlogan',
      desc: '',
      args: [],
    );
  }

  /// `Use `
  String get front_page_hintLine_char1 {
    return Intl.message(
      'Use ',
      name: 'front_page_hintLine_char1',
      desc: '',
      args: [],
    );
  }

  /// ` to chat with `
  String get front_page_hintLine_char2 {
    return Intl.message(
      ' to chat with ',
      name: 'front_page_hintLine_char2',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get front_page_hintLine_char3 {
    return Intl.message(
      '',
      name: 'front_page_hintLine_char3',
      desc: '',
      args: [],
    );
  }

  /// `Generate message`
  String get generate_message {
    return Intl.message(
      'Generate message',
      name: 'generate_message',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong , the model returns a message without content.`
  String get message_no_content {
    return Intl.message(
      'Something went wrong , the model returns a message without content.',
      name: 'message_no_content',
      desc: '',
      args: [],
    );
  }

  /// `Drop files here`
  String get drop_files_hint {
    return Intl.message(
      'Drop files here',
      name: 'drop_files_hint',
      desc: '',
      args: [],
    );
  }

  /// `Generating conversation title...`
  String get generating_title {
    return Intl.message(
      'Generating conversation title...',
      name: 'generating_title',
      desc: '',
      args: [],
    );
  }

  /// `Send a message (MD  supported), enter "/" for more options`
  String get send_a_message_hint {
    return Intl.message(
      'Send a message (MD  supported), enter "/" for more options',
      name: 'send_a_message_hint',
      desc: '',
      args: [],
    );
  }

  /// `Editing UI`
  String get ui_editing {
    return Intl.message('Editing UI', name: 'ui_editing', desc: '', args: []);
  }

  /// `Edited UI`
  String get ui_edited {
    return Intl.message('Edited UI', name: 'ui_edited', desc: '', args: []);
  }

  /// `Show source code`
  String get show_source_code {
    return Intl.message(
      'Show source code',
      name: 'show_source_code',
      desc: '',
      args: [],
    );
  }

  /// `Hide source code`
  String get hide_source_code {
    return Intl.message(
      'Hide source code',
      name: 'hide_source_code',
      desc: '',
      args: [],
    );
  }

  /// `Thinking...`
  String get reasoning {
    return Intl.message('Thinking...', name: 'reasoning', desc: '', args: []);
  }

  /// `Thought for a moment`
  String get reasoned {
    return Intl.message(
      'Thought for a moment',
      name: 'reasoned',
      desc: '',
      args: [],
    );
  }

  /// `Show thoughts`
  String get show_cot {
    return Intl.message('Show thoughts', name: 'show_cot', desc: '', args: []);
  }

  /// `Hide  thoughts`
  String get hide_cot {
    return Intl.message('Hide  thoughts', name: 'hide_cot', desc: '', args: []);
  }

  /// `Searching Knowledge Base...`
  String get searching_knowledge_base {
    return Intl.message(
      'Searching Knowledge Base...',
      name: 'searching_knowledge_base',
      desc: '',
      args: [],
    );
  }

  /// `Searched Knowledge Base`
  String get searched_knowledge_base {
    return Intl.message(
      'Searched Knowledge Base',
      name: 'searched_knowledge_base',
      desc: '',
      args: [],
    );
  }

  /// `Show knowledge base search results`
  String get show_knowledge_base_results {
    return Intl.message(
      'Show knowledge base search results',
      name: 'show_knowledge_base_results',
      desc: '',
      args: [],
    );
  }

  /// `Hide knowledge base search results`
  String get hide_knowledge_base_results {
    return Intl.message(
      'Hide knowledge base search results',
      name: 'hide_knowledge_base_results',
      desc: '',
      args: [],
    );
  }

  /// `Agent Settings`
  String get agent_sets {
    return Intl.message(
      'Agent Settings',
      name: 'agent_sets',
      desc: '',
      args: [],
    );
  }

  /// `Click to select or drop an image`
  String get select_image_hint {
    return Intl.message(
      'Click to select or drop an image',
      name: 'select_image_hint',
      desc: '',
      args: [],
    );
  }

  /// `Model settings`
  String get model_sets {
    return Intl.message(
      'Model settings',
      name: 'model_sets',
      desc: '',
      args: [],
    );
  }

  /// `System prompt`
  String get sys_prompt {
    return Intl.message(
      'System prompt',
      name: 'sys_prompt',
      desc: '',
      args: [],
    );
  }

  /// `Knowledge base & contexts`
  String get knowledge_base_and_contexts {
    return Intl.message(
      'Knowledge base & contexts',
      name: 'knowledge_base_and_contexts',
      desc: '',
      args: [],
    );
  }

  /// `UI interaction (BETA) settings`
  String get ui_interaction_set {
    return Intl.message(
      'UI interaction (BETA) settings',
      name: 'ui_interaction_set',
      desc: '',
      args: [],
    );
  }

  /// `User Persona Settings`
  String get usr_persona_set {
    return Intl.message(
      'User Persona Settings',
      name: 'usr_persona_set',
      desc: '',
      args: [],
    );
  }

  /// `Opening Statement configuration`
  String get opening_configure_title {
    return Intl.message(
      'Opening Statement configuration',
      name: 'opening_configure_title',
      desc: '',
      args: [],
    );
  }

  /// `Custom Slogan`
  String get opening_slogan_label {
    return Intl.message(
      'Custom Slogan',
      name: 'opening_slogan_label',
      desc: '',
      args: [],
    );
  }

  /// `Display a custom slogan when no session is active`
  String get opening_slogan_hint {
    return Intl.message(
      'Display a custom slogan when no session is active',
      name: 'opening_slogan_hint',
      desc: '',
      args: [],
    );
  }

  /// `Opening Message`
  String get opening_message_label {
    return Intl.message(
      'Opening Message',
      name: 'opening_message_label',
      desc: '',
      args: [],
    );
  }

  /// `Sent automatically when a new chat starts (Markdown supported)`
  String get opening_message_hint {
    return Intl.message(
      'Sent automatically when a new chat starts (Markdown supported)',
      name: 'opening_message_hint',
      desc: '',
      args: [],
    );
  }

  /// `Opening settings`
  String get opening_set {
    return Intl.message(
      'Opening settings',
      name: 'opening_set',
      desc: '',
      args: [],
    );
  }

  /// `Enable`
  String get enable {
    return Intl.message('Enable', name: 'enable', desc: '', args: []);
  }

  /// `Disable`
  String get disable {
    return Intl.message('Disable', name: 'disable', desc: '', args: []);
  }

  /// `Cancel (LongPress)`
  String get cancel_long_press {
    return Intl.message(
      'Cancel (LongPress)',
      name: 'cancel_long_press',
      desc: '',
      args: [],
    );
  }

  /// `Reach prompt limit`
  String get model_context_not_enough {
    return Intl.message(
      'Reach prompt limit',
      name: 'model_context_not_enough',
      desc: '',
      args: [],
    );
  }

  /// `System internal prompt({token}Tokens)`
  String system_internal_prompt(Object token) {
    return Intl.message(
      'System internal prompt(${token}Tokens)',
      name: 'system_internal_prompt',
      desc: '',
      args: [token],
    );
  }

  /// `System prompt({token}Tokens)`
  String system_prompt_tokens(Object token) {
    return Intl.message(
      'System prompt(${token}Tokens)',
      name: 'system_prompt_tokens',
      desc: '',
      args: [token],
    );
  }

  /// `Knowledge base({token}Tokens)`
  String knowledge_base_tokens(Object token) {
    return Intl.message(
      'Knowledge base(${token}Tokens)',
      name: 'knowledge_base_tokens',
      desc: '',
      args: [token],
    );
  }

  /// `Longest opening({token}Tokens)`
  String longest_opening(Object token) {
    return Intl.message(
      'Longest opening(${token}Tokens)',
      name: 'longest_opening',
      desc: '',
      args: [token],
    );
  }

  /// `UI interactions({token}Tokens)`
  String ui_interactions_tokens(Object token) {
    return Intl.message(
      'UI interactions(${token}Tokens)',
      name: 'ui_interactions_tokens',
      desc: '',
      args: [token],
    );
  }

  /// `Knowledge base`
  String get knowledge_base {
    return Intl.message(
      'Knowledge base',
      name: 'knowledge_base',
      desc: '',
      args: [],
    );
  }

  /// `Opening`
  String get opening {
    return Intl.message('Opening', name: 'opening', desc: '', args: []);
  }

  /// `UI interactions`
  String get ui_interactions {
    return Intl.message(
      'UI interactions',
      name: 'ui_interactions',
      desc: '',
      args: [],
    );
  }

  /// `Enlarge context or simplify prompt`
  String get enlarge_context_or_simplify_prompt {
    return Intl.message(
      'Enlarge context or simplify prompt',
      name: 'enlarge_context_or_simplify_prompt',
      desc: '',
      args: [],
    );
  }

  /// `{token} Tokens available for chat`
  String token_available_for_chat(Object token) {
    return Intl.message(
      '$token Tokens available for chat',
      name: 'token_available_for_chat',
      desc: '',
      args: [token],
    );
  }

  /// `{lim} Tokens available for total context`
  String total_context_lim(Object lim) {
    return Intl.message(
      '$lim Tokens available for total context',
      name: 'total_context_lim',
      desc: '',
      args: [lim],
    );
  }

  /// `Name the agent`
  String get agent_name_hint {
    return Intl.message(
      'Name the agent',
      name: 'agent_name_hint',
      desc: '',
      args: [],
    );
  }

  /// `Enter description for the agent`
  String get agent_desc_hint {
    return Intl.message(
      'Enter description for the agent',
      name: 'agent_desc_hint',
      desc: '',
      args: [],
    );
  }

  /// `Select a model`
  String get model_select {
    return Intl.message(
      'Select a model',
      name: 'model_select',
      desc: '',
      args: [],
    );
  }

  /// `Select the provider`
  String get provider_select {
    return Intl.message(
      'Select the provider',
      name: 'provider_select',
      desc: '',
      args: [],
    );
  }

  /// `Model Property Settings`
  String get model_property {
    return Intl.message(
      'Model Property Settings',
      name: 'model_property',
      desc: '',
      args: [],
    );
  }

  /// `Model maximum context length`
  String get model_maximum_context_length {
    return Intl.message(
      'Model maximum context length',
      name: 'model_maximum_context_length',
      desc: '',
      args: [],
    );
  }

  /// `Model maximum generate length`
  String get model_maximum_generate_length {
    return Intl.message(
      'Model maximum generate length',
      name: 'model_maximum_generate_length',
      desc: '',
      args: [],
    );
  }

  /// `Model basic info pass through settings`
  String get model_basic_info_pass_through_setting {
    return Intl.message(
      'Model basic info pass through settings',
      name: 'model_basic_info_pass_through_setting',
      desc: '',
      args: [],
    );
  }

  /// `Pass the current time`
  String get model_time_telling {
    return Intl.message(
      'Pass the current time',
      name: 'model_time_telling',
      desc: '',
      args: [],
    );
  }

  /// `Pass the system info (eg: macOS Sonoma)`
  String get model_system_telling {
    return Intl.message(
      'Pass the system info (eg: macOS Sonoma)',
      name: 'model_system_telling',
      desc: '',
      args: [],
    );
  }

  /// `Pass the local info`
  String get model_local_telling {
    return Intl.message(
      'Pass the local info',
      name: 'model_local_telling',
      desc: '',
      args: [],
    );
  }

  /// `Model advance properties`
  String get model_advance_properties {
    return Intl.message(
      'Model advance properties',
      name: 'model_advance_properties',
      desc: '',
      args: [],
    );
  }

  /// `No model yet`
  String get no_model {
    return Intl.message('No model yet', name: 'no_model', desc: '', args: []);
  }

  /// `No embedding model \n Embedding models are different from chat models,check whether you really got one.`
  String get no_embedding_model {
    return Intl.message(
      'No embedding model \n Embedding models are different from chat models,check whether you really got one.',
      name: 'no_embedding_model',
      desc: '',
      args: [],
    );
  }

  /// `Please select a provider`
  String get plz_select_provider {
    return Intl.message(
      'Please select a provider',
      name: 'plz_select_provider',
      desc: '',
      args: [],
    );
  }

  /// `Enter system prompt here... \n MarkDown is supported , enter "/" for more options.`
  String get enter_sys_prompt_here {
    return Intl.message(
      'Enter system prompt here... \n MarkDown is supported , enter "/" for more options.',
      name: 'enter_sys_prompt_here',
      desc: '',
      args: [],
    );
  }

  /// `Enter opening here...`
  String get enter_opening_here {
    return Intl.message(
      'Enter opening here...',
      name: 'enter_opening_here',
      desc: '',
      args: [],
    );
  }

  /// `You have exceeded the maximum context length of {charCount}/{maxCount} characters.`
  String over_maximum_context_length_hint(Object charCount, Object maxCount) {
    return Intl.message(
      'You have exceeded the maximum context length of $charCount/$maxCount characters.',
      name: 'over_maximum_context_length_hint',
      desc: '',
      args: [charCount, maxCount],
    );
  }

  /// `Search any chat message...`
  String get search_any_chat_message {
    return Intl.message(
      'Search any chat message...',
      name: 'search_any_chat_message',
      desc: '',
      args: [],
    );
  }

  /// `Start conversation with selected agent`
  String get start_conversation_with_selected_agent {
    return Intl.message(
      'Start conversation with selected agent',
      name: 'start_conversation_with_selected_agent',
      desc: '',
      args: [],
    );
  }

  /// `Enable UI interactions`
  String get enable_ui_interactions {
    return Intl.message(
      'Enable UI interactions',
      name: 'enable_ui_interactions',
      desc: '',
      args: [],
    );
  }

  /// `Agent management`
  String get agent_manage {
    return Intl.message(
      'Agent management',
      name: 'agent_manage',
      desc: '',
      args: [],
    );
  }

  /// `Create new agent`
  String get create_new_agent {
    return Intl.message(
      'Create new agent',
      name: 'create_new_agent',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure to delete this agent? \n All sessions related to this agent will be deleted.`
  String get agent_delete_confirm {
    return Intl.message(
      'Are you sure to delete this agent? \n All sessions related to this agent will be deleted.',
      name: 'agent_delete_confirm',
      desc: '',
      args: [],
    );
  }

  /// `No model yet, please add one first.`
  String get no_model_plz_add {
    return Intl.message(
      'No model yet, please add one first.',
      name: 'no_model_plz_add',
      desc: '',
      args: [],
    );
  }

  /// `Provider who provides this model`
  String get view_all_provider_provide_model {
    return Intl.message(
      'Provider who provides this model',
      name: 'view_all_provider_provide_model',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this model?`
  String get model_delete_confirm {
    return Intl.message(
      'Are you sure you want to delete this model?',
      name: 'model_delete_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Image load failed.`
  String get image_load_fail {
    return Intl.message(
      'Image load failed.',
      name: 'image_load_fail',
      desc: '',
      args: [],
    );
  }

  /// `Click to upload a image`
  String get click_upload_image {
    return Intl.message(
      'Click to upload a image',
      name: 'click_upload_image',
      desc: '',
      args: [],
    );
  }

  /// `Set as default`
  String get set_as_default {
    return Intl.message(
      'Set as default',
      name: 'set_as_default',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message('Edit', name: 'edit', desc: '', args: []);
  }

  /// `Delete (LongPress)`
  String get delete_long_press {
    return Intl.message(
      'Delete (LongPress)',
      name: 'delete_long_press',
      desc: '',
      args: [],
    );
  }

  /// `Default`
  String get DEFAULT {
    return Intl.message('Default', name: 'DEFAULT', desc: '', args: []);
  }

  /// `Switch persona`
  String get switch_persona {
    return Intl.message(
      'Switch persona',
      name: 'switch_persona',
      desc: '',
      args: [],
    );
  }

  /// `Default persona for the agent`
  String get select_agent_default_persona {
    return Intl.message(
      'Default persona for the agent',
      name: 'select_agent_default_persona',
      desc: '',
      args: [],
    );
  }

  /// `Additional information about the persona`
  String get persona_additonal_information {
    return Intl.message(
      'Additional information about the persona',
      name: 'persona_additonal_information',
      desc: '',
      args: [],
    );
  }

  /// `Add persona`
  String get add_persona {
    return Intl.message('Add persona', name: 'add_persona', desc: '', args: []);
  }

  /// `Edit persona`
  String get edit_persona {
    return Intl.message(
      'Edit persona',
      name: 'edit_persona',
      desc: '',
      args: [],
    );
  }

  /// `Give up edit?`
  String get give_up_edit_confirm {
    return Intl.message(
      'Give up edit?',
      name: 'give_up_edit_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Edit entries`
  String get edit_entries {
    return Intl.message(
      'Edit entries',
      name: 'edit_entries',
      desc: '',
      args: [],
    );
  }

  /// `Add entries`
  String get add_entries {
    return Intl.message('Add entries', name: 'add_entries', desc: '', args: []);
  }

  /// `Please enter your name`
  String get plz_enter_name {
    return Intl.message(
      'Please enter your name',
      name: 'plz_enter_name',
      desc: '',
      args: [],
    );
  }

  /// `Please enter content`
  String get plz_enter_content {
    return Intl.message(
      'Please enter content',
      name: 'plz_enter_content',
      desc: '',
      args: [],
    );
  }

  /// `Content`
  String get content {
    return Intl.message('Content', name: 'content', desc: '', args: []);
  }

  /// `Click or drag a new image to change the avatar`
  String get avatar_change_hint {
    return Intl.message(
      'Click or drag a new image to change the avatar',
      name: 'avatar_change_hint',
      desc: '',
      args: [],
    );
  }

  /// `Describe yourself...`
  String get persona_description_hint {
    return Intl.message(
      'Describe yourself...',
      name: 'persona_description_hint',
      desc: '',
      args: [],
    );
  }

  /// `Please enter description`
  String get plz_enter_description {
    return Intl.message(
      'Please enter description',
      name: 'plz_enter_description',
      desc: '',
      args: [],
    );
  }

  /// `Drop image here`
  String get drag_image_hint {
    return Intl.message(
      'Drop image here',
      name: 'drag_image_hint',
      desc: '',
      args: [],
    );
  }

  /// `Preferences`
  String get preferences {
    return Intl.message('Preferences', name: 'preferences', desc: '', args: []);
  }

  /// `API settings`
  String get API_settings {
    return Intl.message(
      'API settings',
      name: 'API_settings',
      desc: '',
      args: [],
    );
  }

  /// `Model management`
  String get model_management {
    return Intl.message(
      'Model management',
      name: 'model_management',
      desc: '',
      args: [],
    );
  }

  /// `General settings`
  String get general_settings {
    return Intl.message(
      'General settings',
      name: 'general_settings',
      desc: '',
      args: [],
    );
  }

  /// `Language settings`
  String get language_settings {
    return Intl.message(
      'Language settings',
      name: 'language_settings',
      desc: '',
      args: [],
    );
  }

  /// `Select a language`
  String get language_select {
    return Intl.message(
      'Select a language',
      name: 'language_select',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message('About', name: 'about', desc: '', args: []);
  }

  /// `Chat`
  String get chat {
    return Intl.message('Chat', name: 'chat', desc: '', args: []);
  }

  /// `Quit`
  String get quit {
    return Intl.message('Quit', name: 'quit', desc: '', args: []);
  }

  /// `New chat session`
  String get new_chat_session {
    return Intl.message(
      'New chat session',
      name: 'new_chat_session',
      desc: '',
      args: [],
    );
  }

  /// `Toggle session selector`
  String get toggle_session_selector {
    return Intl.message(
      'Toggle session selector',
      name: 'toggle_session_selector',
      desc: '',
      args: [],
    );
  }

  /// `Help`
  String get help {
    return Intl.message('Help', name: 'help', desc: '', args: []);
  }

  /// `Check manual`
  String get check_manual {
    return Intl.message(
      'Check manual',
      name: 'check_manual',
      desc: '',
      args: [],
    );
  }

  /// `Some changes may require a restart to take effect.`
  String get language_switch_restart_note {
    return Intl.message(
      'Some changes may require a restart to take effect.',
      name: 'language_switch_restart_note',
      desc: '',
      args: [],
    );
  }

  /// `Edit knowledge base`
  String get edit_knowledge_base {
    return Intl.message(
      'Edit knowledge base',
      name: 'edit_knowledge_base',
      desc: '',
      args: [],
    );
  }

  /// `Enter knowledge base name`
  String get enter_knowledge_base_name {
    return Intl.message(
      'Enter knowledge base name',
      name: 'enter_knowledge_base_name',
      desc: '',
      args: [],
    );
  }

  /// `Enter knowledge base description`
  String get enter_knowledge_base_description {
    return Intl.message(
      'Enter knowledge base description',
      name: 'enter_knowledge_base_description',
      desc: '',
      args: [],
    );
  }

  /// `Embedding model`
  String get embedding_model {
    return Intl.message(
      'Embedding model',
      name: 'embedding_model',
      desc: '',
      args: [],
    );
  }

  /// `Embedding dimension`
  String get embedding_dimension {
    return Intl.message(
      'Embedding dimension',
      name: 'embedding_dimension',
      desc: '',
      args: [],
    );
  }

  /// `Please select embedding dimension`
  String get plz_select_embedding_dimension {
    return Intl.message(
      'Please select embedding dimension',
      name: 'plz_select_embedding_dimension',
      desc: '',
      args: [],
    );
  }

  /// `Default index method`
  String get default_index_method {
    return Intl.message(
      'Default index method',
      name: 'default_index_method',
      desc: '',
      args: [],
    );
  }

  /// `New version available`
  String get new_version_available {
    return Intl.message(
      'New version available',
      name: 'new_version_available',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get download {
    return Intl.message('Download', name: 'download', desc: '', args: []);
  }

  /// `File manage`
  String get file_manage {
    return Intl.message('File manage', name: 'file_manage', desc: '', args: []);
  }

  /// `Website manage`
  String get website_manage {
    return Intl.message(
      'Website manage',
      name: 'website_manage',
      desc: '',
      args: [],
    );
  }

  /// `Memory manage`
  String get memory_manage {
    return Intl.message(
      'Memory manage',
      name: 'memory_manage',
      desc: '',
      args: [],
    );
  }

  /// `Auto index rules setting`
  String get auto_index_rules_set {
    return Intl.message(
      'Auto index rules setting',
      name: 'auto_index_rules_set',
      desc: '',
      args: [],
    );
  }

  /// `Vector index`
  String get vector_index {
    return Intl.message(
      'Vector index',
      name: 'vector_index',
      desc: '',
      args: [],
    );
  }

  /// `Keyword index`
  String get keyword_index {
    return Intl.message(
      'Keyword index',
      name: 'keyword_index',
      desc: '',
      args: [],
    );
  }

  /// `Regex index`
  String get regex_index {
    return Intl.message('Regex index', name: 'regex_index', desc: '', args: []);
  }

  /// `Model or dimension not set`
  String get model_or_dimension_not_set {
    return Intl.message(
      'Model or dimension not set',
      name: 'model_or_dimension_not_set',
      desc: '',
      args: [],
    );
  }

  /// `Click to select or drop files here`
  String get click_or_drop_files_here {
    return Intl.message(
      'Click to select or drop files here',
      name: 'click_or_drop_files_here',
      desc: '',
      args: [],
    );
  }

  /// `md,docx,csv,txt,json,html`
  String get support_formats {
    return Intl.message(
      'md,docx,csv,txt,json,html',
      name: 'support_formats',
      desc: '',
      args: [],
    );
  }

  /// `No file`
  String get no_file {
    return Intl.message('No file', name: 'no_file', desc: '', args: []);
  }

  /// `No file selected`
  String get no_file_selected {
    return Intl.message(
      'No file selected',
      name: 'no_file_selected',
      desc: '',
      args: [],
    );
  }

  /// `Unsupported format`
  String get unsupported_format {
    return Intl.message(
      'Unsupported format',
      name: 'unsupported_format',
      desc: '',
      args: [],
    );
  }

  /// `Index settings`
  String get index_settings {
    return Intl.message(
      'Index settings',
      name: 'index_settings',
      desc: '',
      args: [],
    );
  }

  /// `No index method selected, this content will never be inserted into conversation`
  String get no_index_method_warning {
    return Intl.message(
      'No index method selected, this content will never be inserted into conversation',
      name: 'no_index_method_warning',
      desc: '',
      args: [],
    );
  }

  /// `Match the chunks of content which are similar to the query`
  String get vec_index_hint {
    return Intl.message(
      'Match the chunks of content which are similar to the query',
      name: 'vec_index_hint',
      desc: '',
      args: [],
    );
  }

  /// `When message contains any keywords, the whole content will be sent`
  String get keyword_index_hint {
    return Intl.message(
      'When message contains any keywords, the whole content will be sent',
      name: 'keyword_index_hint',
      desc: '',
      args: [],
    );
  }

  /// `When message matches any regex, the whole content will be sent`
  String get regex_index_hint {
    return Intl.message(
      'When message matches any regex, the whole content will be sent',
      name: 'regex_index_hint',
      desc: '',
      args: [],
    );
  }

  /// `No preview available`
  String get no_preview {
    return Intl.message(
      'No preview available',
      name: 'no_preview',
      desc: '',
      args: [],
    );
  }

  /// `Enter keywords separated by comma`
  String get enter_key_word_hint {
    return Intl.message(
      'Enter keywords separated by comma',
      name: 'enter_key_word_hint',
      desc: '',
      args: [],
    );
  }

  /// `Enter regex`
  String get enter_regex_hint {
    return Intl.message(
      'Enter regex',
      name: 'enter_regex_hint',
      desc: '',
      args: [],
    );
  }

  /// `No memory`
  String get no_memory {
    return Intl.message('No memory', name: 'no_memory', desc: '', args: []);
  }

  /// `Select or add a memory`
  String get select_or_add_memory {
    return Intl.message(
      'Select or add a memory',
      name: 'select_or_add_memory',
      desc: '',
      args: [],
    );
  }

  /// `Add memory`
  String get add_memory {
    return Intl.message('Add memory', name: 'add_memory', desc: '', args: []);
  }

  /// `Memory name`
  String get memory_name {
    return Intl.message('Memory name', name: 'memory_name', desc: '', args: []);
  }

  /// `Memory name cannot be empty`
  String get memory_name_waring {
    return Intl.message(
      'Memory name cannot be empty',
      name: 'memory_name_waring',
      desc: '',
      args: [],
    );
  }

  /// `Memory content`
  String get memory_content {
    return Intl.message(
      'Memory content',
      name: 'memory_content',
      desc: '',
      args: [],
    );
  }

  /// `Memory content cannot be empty`
  String get memory_content_waring {
    return Intl.message(
      'Memory content cannot be empty',
      name: 'memory_content_waring',
      desc: '',
      args: [],
    );
  }

  /// `Create a new rule`
  String get create_new_rule {
    return Intl.message(
      'Create a new rule',
      name: 'create_new_rule',
      desc: '',
      args: [],
    );
  }

  /// `No rules`
  String get no_rules {
    return Intl.message('No rules', name: 'no_rules', desc: '', args: []);
  }

  /// `When chat with`
  String get auto_index_rules_1 {
    return Intl.message(
      'When chat with',
      name: 'auto_index_rules_1',
      desc: '',
      args: [],
    );
  }

  /// `Select agent`
  String get select_agent {
    return Intl.message(
      'Select agent',
      name: 'select_agent',
      desc: '',
      args: [],
    );
  }

  /// `{num} selected`
  String selected_agent(Object num) {
    return Intl.message(
      '$num selected',
      name: 'selected_agent',
      desc: '',
      args: [num],
    );
  }

  /// `and`
  String get auto_index_rules_2 {
    return Intl.message('and', name: 'auto_index_rules_2', desc: '', args: []);
  }

  /// `will be indexed`
  String get auto_index_rules_3 {
    return Intl.message(
      'will be indexed',
      name: 'auto_index_rules_3',
      desc: '',
      args: [],
    );
  }

  /// `AI`
  String get ai {
    return Intl.message('AI', name: 'ai', desc: '', args: []);
  }

  /// `User`
  String get user {
    return Intl.message('User', name: 'user', desc: '', args: []);
  }

  /// `Any`
  String get any {
    return Intl.message('Any', name: 'any', desc: '', args: []);
  }

  /// `Index all`
  String get index_all {
    return Intl.message('Index all', name: 'index_all', desc: '', args: []);
  }

  /// `Keyword match`
  String get keyword_match {
    return Intl.message(
      'Keyword match',
      name: 'keyword_match',
      desc: '',
      args: [],
    );
  }

  /// `Regex match`
  String get regex_match {
    return Intl.message('Regex match', name: 'regex_match', desc: '', args: []);
  }

  /// `OK`
  String get base_stat_OK {
    return Intl.message('OK', name: 'base_stat_OK', desc: '', args: []);
  }

  /// `Processing`
  String get base_stat_processing {
    return Intl.message(
      'Processing',
      name: 'base_stat_processing',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get base_stat_PENDING {
    return Intl.message(
      'Pending',
      name: 'base_stat_PENDING',
      desc: '',
      args: [],
    );
  }

  /// `A powerful AI agent integrated ChatApp`
  String get slogan {
    return Intl.message(
      'A powerful AI agent integrated ChatApp',
      name: 'slogan',
      desc: '',
      args: [],
    );
  }

  /// `Start`
  String get setup_start {
    return Intl.message('Start', name: 'setup_start', desc: '', args: []);
  }

  /// `Before we go on : `
  String get setup_pre_warning {
    return Intl.message(
      'Before we go on : ',
      name: 'setup_pre_warning',
      desc: '',
      args: [],
    );
  }

  /// `# UNIChat Development Announcement\n\n**To All UNIChat Users:**\n\nThank you for your interest in and trying out UNIChat!\n\nUNIChat is currently in its **early Alpha version** stage. This means the software is not yet complete, and many features are still under planning and active development. Please keep the following points in mind while using the application:\n\n---\n\n### 1. ⚠️ Version Status and Data Risk\n\n1.  **Incomplete Functionality:** Many core features may not yet be implemented, or they might be incomplete, unstable, or provide a sub-optimal user experience.\n2.  **Risk of Data Structure Changes:** As the software is undergoing rapid iteration, we **cannot guarantee** that the data structure will not undergo significant changes in the future. Consequently, **user data (such as chat history, settings, etc.) in the current version might not be inheritable or compatible with subsequent updates.** Please be aware of this and exercise caution with storing important data.\n\n### 2. 🐛 Bug and Issue Reporting\n\nIf you encounter any bugs or problems during use, we strongly encourage you to report them to us via the following channels:\n\n* Submit an **Issue** on our **GitHub Repository**.\n* Send an email to **[Please insert your Email address here]**.\n\n### 3. 📖 Documentation and The Art of Asking Questions\n\nWe are committed to clear documentation and encourage high-quality communication:\n\n* **Check Documentation First:** Before asking a question or submitting feedback, please prioritize checking the project's **official documentation**: [Please insert Documentation Link here]. Many basic queries might already be answered there.\n* **The Art of Asking Questions:** If you decide to ask a question or file an Issue, to ensure we can resolve it efficiently, please follow these principles:\n    1.  **Be Clear and Specific:** Clearly describe the problem you are facing, the expected behavior, and what actually occurred.\n    2.  **Provide Steps to Reproduce:** Include **detailed steps** on how to reproduce the issue ("How to operate to cause this error").\n    3.  **Include Environment Info:** Provide relevant environment information, such as your operating system and software version number.\n\n### 4. 🌐 Open Source and Contributions\n\nUNIChat is an open-source project **licensed under the Apache License 2.0**.\n\nWe warmly welcome all developers to review, study, and utilize our code. If you are interested in contributing to UNIChat—whether through code improvements, documentation, or feature implementation—we welcome your **Pull Requests**!\n\n---\n\n**Acknowledgement:** Your early usage and feedback are invaluable to us. Thank you for your patience and support as we work towards the official release of UNIChat!`
  String get setup_pre_warn_content {
    return Intl.message(
      '# UNIChat Development Announcement\n\n**To All UNIChat Users:**\n\nThank you for your interest in and trying out UNIChat!\n\nUNIChat is currently in its **early Alpha version** stage. This means the software is not yet complete, and many features are still under planning and active development. Please keep the following points in mind while using the application:\n\n---\n\n### 1. ⚠️ Version Status and Data Risk\n\n1.  **Incomplete Functionality:** Many core features may not yet be implemented, or they might be incomplete, unstable, or provide a sub-optimal user experience.\n2.  **Risk of Data Structure Changes:** As the software is undergoing rapid iteration, we **cannot guarantee** that the data structure will not undergo significant changes in the future. Consequently, **user data (such as chat history, settings, etc.) in the current version might not be inheritable or compatible with subsequent updates.** Please be aware of this and exercise caution with storing important data.\n\n### 2. 🐛 Bug and Issue Reporting\n\nIf you encounter any bugs or problems during use, we strongly encourage you to report them to us via the following channels:\n\n* Submit an **Issue** on our **GitHub Repository**.\n* Send an email to **[Please insert your Email address here]**.\n\n### 3. 📖 Documentation and The Art of Asking Questions\n\nWe are committed to clear documentation and encourage high-quality communication:\n\n* **Check Documentation First:** Before asking a question or submitting feedback, please prioritize checking the project\'s **official documentation**: [Please insert Documentation Link here]. Many basic queries might already be answered there.\n* **The Art of Asking Questions:** If you decide to ask a question or file an Issue, to ensure we can resolve it efficiently, please follow these principles:\n    1.  **Be Clear and Specific:** Clearly describe the problem you are facing, the expected behavior, and what actually occurred.\n    2.  **Provide Steps to Reproduce:** Include **detailed steps** on how to reproduce the issue ("How to operate to cause this error").\n    3.  **Include Environment Info:** Provide relevant environment information, such as your operating system and software version number.\n\n### 4. 🌐 Open Source and Contributions\n\nUNIChat is an open-source project **licensed under the Apache License 2.0**.\n\nWe warmly welcome all developers to review, study, and utilize our code. If you are interested in contributing to UNIChat—whether through code improvements, documentation, or feature implementation—we welcome your **Pull Requests**!\n\n---\n\n**Acknowledgement:** Your early usage and feedback are invaluable to us. Thank you for your patience and support as we work towards the official release of UNIChat!',
      name: 'setup_pre_warn_content',
      desc: '',
      args: [],
    );
  }

  /// `Got it`
  String get got_it {
    return Intl.message('Got it', name: 'got_it', desc: '', args: []);
  }

  /// `Long press`
  String get long_press {
    return Intl.message('Long press', name: 'long_press', desc: '', args: []);
  }

  /// `Create a agent`
  String get setup_agent_hint {
    return Intl.message(
      'Create a agent',
      name: 'setup_agent_hint',
      desc: '',
      args: [],
    );
  }

  /// `Create a knowledge base`
  String get setup_knowledgeBase {
    return Intl.message(
      'Create a knowledge base',
      name: 'setup_knowledgeBase',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get skip {
    return Intl.message('Skip', name: 'skip', desc: '', args: []);
  }

  /// `Create a persona`
  String get setup_persona {
    return Intl.message(
      'Create a persona',
      name: 'setup_persona',
      desc: '',
      args: [],
    );
  }

  /// `Now we're ready to go!`
  String get setup_finished {
    return Intl.message(
      'Now we\'re ready to go!',
      name: 'setup_finished',
      desc: '',
      args: [],
    );
  }

  /// `Unlock the brand new Ai chat experience ->`
  String get setup_finished_btn {
    return Intl.message(
      'Unlock the brand new Ai chat experience ->',
      name: 'setup_finished_btn',
      desc: '',
      args: [],
    );
  }

  /// `Let's add a Api Provider first`
  String get setup_provider_add {
    return Intl.message(
      'Let\'s add a Api Provider first',
      name: 'setup_provider_add',
      desc: '',
      args: [],
    );
  }

  /// `You can check the document on the right to lear about it.`
  String get setup_provider_add_hint {
    return Intl.message(
      'You can check the document on the right to lear about it.',
      name: 'setup_provider_add_hint',
      desc: '',
      args: [],
    );
  }

  /// `I've got my apiKeys`
  String get setup_api_prepared {
    return Intl.message(
      'I\'ve got my apiKeys',
      name: 'setup_api_prepared',
      desc: '',
      args: [],
    );
  }

  /// `Next, let's add a Agent`
  String get setup_add_agent {
    return Intl.message(
      'Next, let\'s add a Agent',
      name: 'setup_add_agent',
      desc: '',
      args: [],
    );
  }

  /// `Agent is a highly customize AI assistant，\n Through UNIChat's powerful agent engine, \n You can create whoever you wish!`
  String get setup_add_agent_hint {
    return Intl.message(
      'Agent is a highly customize AI assistant，\n Through UNIChat\'s powerful agent engine, \n You can create whoever you wish!',
      name: 'setup_add_agent_hint',
      desc: '',
      args: [],
    );
  }

  /// `Now, add a persona`
  String get setup_add_persona {
    return Intl.message(
      'Now, add a persona',
      name: 'setup_add_persona',
      desc: '',
      args: [],
    );
  }

  /// `AI learn about you through personas,\n you can be "The true me"or let the AIs calls you "Master" :-D `
  String get setup_add_persona_hint {
    return Intl.message(
      'AI learn about you through personas,\n you can be "The true me"or let the AIs calls you "Master" :-D ',
      name: 'setup_add_persona_hint',
      desc: '',
      args: [],
    );
  }

  /// `Star us on GitHub plz(≧∇BSD)`
  String get star_github {
    return Intl.message(
      'Star us on GitHub plz(≧∇BSD)',
      name: 'star_github',
      desc: '',
      args: [],
    );
  }

  /// `Show Docs`
  String get show_document {
    return Intl.message('Show Docs', name: 'show_document', desc: '', args: []);
  }

  /// `Hide Docs`
  String get hide_document {
    return Intl.message('Hide Docs', name: 'hide_document', desc: '', args: []);
  }

  // skipped getter for the 'comment@forApiSettings' key

  /// ` Are you sure to delete {provider}?\n All the records and key will be deleted as well.`
  String provider_delete_warning(Object provider) {
    return Intl.message(
      ' Are you sure to delete $provider?\\n All the records and key will be deleted as well.',
      name: 'provider_delete_warning',
      desc: '',
      args: [provider],
    );
  }

  /// `Search provider`
  String get search_provider {
    return Intl.message(
      'Search provider',
      name: 'search_provider',
      desc: '',
      args: [],
    );
  }

  /// `Add other provider`
  String get add_other_provider {
    return Intl.message(
      'Add other provider',
      name: 'add_other_provider',
      desc: '',
      args: [],
    );
  }

  /// `Unnamed`
  String get name_not_set {
    return Intl.message('Unnamed', name: 'name_not_set', desc: '', args: []);
  }

  /// `Valid`
  String get valid {
    return Intl.message('Valid', name: 'valid', desc: '', args: []);
  }

  /// `Address might not be valid`
  String get endPoint_might_not_valid {
    return Intl.message(
      'Address might not be valid',
      name: 'endPoint_might_not_valid',
      desc: '',
      args: [],
    );
  }

  /// `API end point not set`
  String get endPoint_not_set {
    return Intl.message(
      'API end point not set',
      name: 'endPoint_not_set',
      desc: '',
      args: [],
    );
  }

  /// `unknown`
  String get unknown {
    return Intl.message('unknown', name: 'unknown', desc: '', args: []);
  }

  /// `Basic configuration`
  String get basic_configure {
    return Intl.message(
      'Basic configuration',
      name: 'basic_configure',
      desc: '',
      args: [],
    );
  }

  /// `Configured`
  String get configure_all_set {
    return Intl.message(
      'Configured',
      name: 'configure_all_set',
      desc: '',
      args: [],
    );
  }

  /// `Not configured`
  String get configure_not_set {
    return Intl.message(
      'Not configured',
      name: 'configure_not_set',
      desc: '',
      args: [],
    );
  }

  /// `API Keys configuration`
  String get api_keys_configure {
    return Intl.message(
      'API Keys configuration',
      name: 'api_keys_configure',
      desc: '',
      args: [],
    );
  }

  /// `{num} API Keys added`
  String api_keys_configured(Object num) {
    return Intl.message(
      '$num API Keys added',
      name: 'api_keys_configured',
      desc: '',
      args: [num],
    );
  }

  /// `Api Keys not added`
  String get api_keys_not_set {
    return Intl.message(
      'Api Keys not added',
      name: 'api_keys_not_set',
      desc: '',
      args: [],
    );
  }

  /// `Model configuration`
  String get model_configure {
    return Intl.message(
      'Model configuration',
      name: 'model_configure',
      desc: '',
      args: [],
    );
  }

  /// `Model not set`
  String get model_configure_not_set {
    return Intl.message(
      'Model not set',
      name: 'model_configure_not_set',
      desc: '',
      args: [],
    );
  }

  /// `Added {num} models`
  String model_configured(Object num) {
    return Intl.message(
      'Added $num models',
      name: 'model_configured',
      desc: '',
      args: [num],
    );
  }

  /// `Previous Step`
  String get previous_step {
    return Intl.message(
      'Previous Step',
      name: 'previous_step',
      desc: '',
      args: [],
    );
  }

  /// `Add version flags`
  String get add_ver_flag {
    return Intl.message(
      'Add version flags',
      name: 'add_ver_flag',
      desc: '',
      args: [],
    );
  }

  /// `API Type`
  String get api_type {
    return Intl.message('API Type', name: 'api_type', desc: '', args: []);
  }

  /// `API end point preview`
  String get end_point_preview {
    return Intl.message(
      'API end point preview',
      name: 'end_point_preview',
      desc: '',
      args: [],
    );
  }

  /// `Confirm your delete.`
  String get delete_confirm {
    return Intl.message(
      'Confirm your delete.',
      name: 'delete_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Request per minute`
  String get request_per_minute {
    return Intl.message(
      'Request per minute',
      name: 'request_per_minute',
      desc: '',
      args: [],
    );
  }

  /// `Request per day`
  String get request_daily_limit {
    return Intl.message(
      'Request per day',
      name: 'request_daily_limit',
      desc: '',
      args: [],
    );
  }

  /// `Token limit per day`
  String get token_daily_limit {
    return Intl.message(
      'Token limit per day',
      name: 'token_daily_limit',
      desc: '',
      args: [],
    );
  }

  /// `Remark`
  String get remark {
    return Intl.message('Remark', name: 'remark', desc: '', args: []);
  }

  /// `Advance Settings`
  String get advance_settings {
    return Intl.message(
      'Advance Settings',
      name: 'advance_settings',
      desc: '',
      args: [],
    );
  }

  /// `Enter a digit`
  String get plz_enter_digit {
    return Intl.message(
      'Enter a digit',
      name: 'plz_enter_digit',
      desc: '',
      args: [],
    );
  }

  /// `Enter a >0 number`
  String get plz_enter_a_number_bigger_than_zero {
    return Intl.message(
      'Enter a >0 number',
      name: 'plz_enter_a_number_bigger_than_zero',
      desc: '',
      args: [],
    );
  }

  /// `Add model`
  String get add_model {
    return Intl.message('Add model', name: 'add_model', desc: '', args: []);
  }

  /// `Search model`
  String get search_for_models {
    return Intl.message(
      'Search model',
      name: 'search_for_models',
      desc: '',
      args: [],
    );
  }

  /// `Model not found , please check your spelling`
  String get model_not_found {
    return Intl.message(
      'Model not found , please check your spelling',
      name: 'model_not_found',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the 'comment@model_ability' key

  /// `Text Generation`
  String get textGenerate {
    return Intl.message(
      'Text Generation',
      name: 'textGenerate',
      desc: '',
      args: [],
    );
  }

  /// `Image Generation`
  String get imageGenerate {
    return Intl.message(
      'Image Generation',
      name: 'imageGenerate',
      desc: '',
      args: [],
    );
  }

  /// `Image to Image Generation`
  String get image2imageGenerate {
    return Intl.message(
      'Image to Image Generation',
      name: 'image2imageGenerate',
      desc: '',
      args: [],
    );
  }

  /// `Visual Understanding`
  String get visual {
    return Intl.message(
      'Visual Understanding',
      name: 'visual',
      desc: '',
      args: [],
    );
  }

  /// `File`
  String get file {
    return Intl.message('File', name: 'file', desc: '', args: []);
  }

  /// `Embedding`
  String get embedding {
    return Intl.message('Embedding', name: 'embedding', desc: '', args: []);
  }

  /// `Audio`
  String get audio {
    return Intl.message('Audio', name: 'audio', desc: '', args: []);
  }

  /// `Video`
  String get video {
    return Intl.message('Video', name: 'video', desc: '', args: []);
  }

  /// `session not found`
  String get chatEx_sessionNotFound {
    return Intl.message(
      'session not found',
      name: 'chatEx_sessionNotFound',
      desc: '',
      args: [],
    );
  }

  /// `message not found`
  String get chatEx_messageNotFound {
    return Intl.message(
      'message not found',
      name: 'chatEx_messageNotFound',
      desc: '',
      args: [],
    );
  }

  /// `fail to parse message`
  String get chatEx_failParsingMessage {
    return Intl.message(
      'fail to parse message',
      name: 'chatEx_failParsingMessage',
      desc: '',
      args: [],
    );
  }

  /// `fail to save message`
  String get chatEx_failToSaveMessage {
    return Intl.message(
      'fail to save message',
      name: 'chatEx_failToSaveMessage',
      desc: '',
      args: [],
    );
  }

  /// `fail to generate title`
  String get chatEx_failToGenerateTitle {
    return Intl.message(
      'fail to generate title',
      name: 'chatEx_failToGenerateTitle',
      desc: '',
      args: [],
    );
  }

  /// `The model does not support this type of file`
  String get chatEx_modelNotSupportFileType {
    return Intl.message(
      'The model does not support this type of file',
      name: 'chatEx_modelNotSupportFileType',
      desc: '',
      args: [],
    );
  }

  /// `unknown error`
  String get chatEx_unknownError {
    return Intl.message(
      'unknown error',
      name: 'chatEx_unknownError',
      desc: '',
      args: [],
    );
  }

  /// `Chat error`
  String get chatEx {
    return Intl.message('Chat error', name: 'chatEx', desc: '', args: []);
  }

  /// `chatting`
  String get chatEx_recursive_call {
    return Intl.message(
      'chatting',
      name: 'chatEx_recursive_call',
      desc: '',
      args: [],
    );
  }

  /// `agent not loaded`
  String get agentEx_agentNotLoaded {
    return Intl.message(
      'agent not loaded',
      name: 'agentEx_agentNotLoaded',
      desc: '',
      args: [],
    );
  }

  /// `agent not found`
  String get agentEx_agentNotFound {
    return Intl.message(
      'agent not found',
      name: 'agentEx_agentNotFound',
      desc: '',
      args: [],
    );
  }

  /// `unknown error`
  String get agentEx_unknownError {
    return Intl.message(
      'unknown error',
      name: 'agentEx_unknownError',
      desc: '',
      args: [],
    );
  }

  /// `agent data is corrupted`
  String get agentEx_failLoading_parse_error {
    return Intl.message(
      'agent data is corrupted',
      name: 'agentEx_failLoading_parse_error',
      desc: '',
      args: [],
    );
  }

  /// `Core component version mismatch, please upgrade the application`
  String get agentEx_versionMismatch {
    return Intl.message(
      'Core component version mismatch, please upgrade the application',
      name: 'agentEx_versionMismatch',
      desc: '',
      args: [],
    );
  }

  /// `Agent error`
  String get agentEx {
    return Intl.message('Agent error', name: 'agentEx', desc: '', args: []);
  }

  /// `loading agent`
  String get agentEx_recursive_call {
    return Intl.message(
      'loading agent',
      name: 'agentEx_recursive_call',
      desc: '',
      args: [],
    );
  }

  /// `persona not found`
  String get personaEX_personaNotFound {
    return Intl.message(
      'persona not found',
      name: 'personaEX_personaNotFound',
      desc: '',
      args: [],
    );
  }

  /// `unknown error`
  String get personaEX_unknownError {
    return Intl.message(
      'unknown error',
      name: 'personaEX_unknownError',
      desc: '',
      args: [],
    );
  }

  /// `persona data is corrupted`
  String get personaEx_failLoading_parse_error {
    return Intl.message(
      'persona data is corrupted',
      name: 'personaEx_failLoading_parse_error',
      desc: '',
      args: [],
    );
  }

  /// `Persona error`
  String get personaEx {
    return Intl.message('Persona error', name: 'personaEx', desc: '', args: []);
  }

  /// ` while loading persona`
  String get personaEx_recursive_call {
    return Intl.message(
      ' while loading persona',
      name: 'personaEx_recursive_call',
      desc: '',
      args: [],
    );
  }

  /// `API error`
  String get apiEx {
    return Intl.message('API error', name: 'apiEx', desc: '', args: []);
  }

  /// `calling api`
  String get apiEx_recursive_call {
    return Intl.message(
      'calling api',
      name: 'apiEx_recursive_call',
      desc: '',
      args: [],
    );
  }

  /// `provider not found`
  String get apiEx_providerNotFound {
    return Intl.message(
      'provider not found',
      name: 'apiEx_providerNotFound',
      desc: '',
      args: [],
    );
  }

  /// `unknown error`
  String get apiEx_unknownError {
    return Intl.message(
      'unknown error',
      name: 'apiEx_unknownError',
      desc: '',
      args: [],
    );
  }

  /// `model not available for provider`
  String get apiEx_modelNotAvailableForProvider {
    return Intl.message(
      'model not available for provider',
      name: 'apiEx_modelNotAvailableForProvider',
      desc: '',
      args: [],
    );
  }

  /// `model not found`
  String get apiEx_modelNotFound {
    return Intl.message(
      'model not found',
      name: 'apiEx_modelNotFound',
      desc: '',
      args: [],
    );
  }

  /// `request timeout`
  String get apiEx_request_timeout {
    return Intl.message(
      'request timeout',
      name: 'apiEx_request_timeout',
      desc: '',
      args: [],
    );
  }

  /// `bad request`
  String get apiEx_request_badRequest {
    return Intl.message(
      'bad request',
      name: 'apiEx_request_badRequest',
      desc: '',
      args: [],
    );
  }

  /// `the api returns an empty response`
  String get apiEx_request_emptyBody {
    return Intl.message(
      'the api returns an empty response',
      name: 'apiEx_request_emptyBody',
      desc: '',
      args: [],
    );
  }

  /// `api failed to respond`
  String get apiEx_request_apiFail {
    return Intl.message(
      'api failed to respond',
      name: 'apiEx_request_apiFail',
      desc: '',
      args: [],
    );
  }

  /// `api error `
  String get apiEx_request_other {
    return Intl.message(
      'api error ',
      name: 'apiEx_request_other',
      desc: '',
      args: [],
    );
  }

  /// `currently no keys are available for using`
  String get apiEx_apikey_noAvailableKeys {
    return Intl.message(
      'currently no keys are available for using',
      name: 'apiEx_apikey_noAvailableKeys',
      desc: '',
      args: [],
    );
  }

  /// `API Key Status Report`
  String get api_key_exhausted_title {
    return Intl.message(
      'API Key Status Report',
      name: 'api_key_exhausted_title',
      desc: '',
      args: [],
    );
  }

  /// `In this round of requests,all keys have failed:`
  String get api_key_exhausted_subtitle {
    return Intl.message(
      'In this round of requests,all keys have failed:',
      name: 'api_key_exhausted_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `All {count} available API Keys failed to request, click for details`
  String apiEx_apikey_noAvailableKeys_detailed(Object count) {
    return Intl.message(
      'All $count available API Keys failed to request, click for details',
      name: 'apiEx_apikey_noAvailableKeys_detailed',
      desc: '',
      args: [count],
    );
  }

  /// `Error Details`
  String get error_details {
    return Intl.message(
      'Error Details',
      name: 'error_details',
      desc: '',
      args: [],
    );
  }

  /// `Status Code`
  String get status_code {
    return Intl.message('Status Code', name: 'status_code', desc: '', args: []);
  }

  /// `Error Message`
  String get error_message {
    return Intl.message(
      'Error Message',
      name: 'error_message',
      desc: '',
      args: [],
    );
  }

  /// `while {condition}`
  String ex_while(Object condition) {
    return Intl.message(
      'while $condition',
      name: 'ex_while',
      desc: '',
      args: [condition],
    );
  }

  /// ` and `
  String get ex_and {
    return Intl.message(' and ', name: 'ex_and', desc: '', args: []);
  }

  /// `Branch from here`
  String get branch_from_here {
    return Intl.message(
      'Branch from here',
      name: 'branch_from_here',
      desc: '',
      args: [],
    );
  }

  /// `Name your new branch`
  String get name_new_branch {
    return Intl.message(
      'Name your new branch',
      name: 'name_new_branch',
      desc: '',
      args: [],
    );
  }

  /// `Branch`
  String get branch_confirm {
    return Intl.message('Branch', name: 'branch_confirm', desc: '', args: []);
  }

  /// `Don't show this announcement again`
  String get no_pop_out_announcement {
    return Intl.message(
      'Don\'t show this announcement again',
      name: 'no_pop_out_announcement',
      desc: '',
      args: [],
    );
  }

  /// `Log capture`
  String get log_settings {
    return Intl.message(
      'Log capture',
      name: 'log_settings',
      desc: '',
      args: [],
    );
  }

  /// `Loading logs...`
  String get log_loading {
    return Intl.message(
      'Loading logs...',
      name: 'log_loading',
      desc: '',
      args: [],
    );
  }

  /// `Log file not initialized`
  String get log_file_not_init {
    return Intl.message(
      'Log file not initialized',
      name: 'log_file_not_init',
      desc: '',
      args: [],
    );
  }

  /// `Failed to read logs: {error}`
  String log_read_fail(Object error) {
    return Intl.message(
      'Failed to read logs: $error',
      name: 'log_read_fail',
      desc: '',
      args: [error],
    );
  }

  /// `No logs`
  String get log_none {
    return Intl.message('No logs', name: 'log_none', desc: '', args: []);
  }

  /// `Enable global log capture (partial interception takes effect after restart)`
  String get log_enable_global_catch {
    return Intl.message(
      'Enable global log capture (partial interception takes effect after restart)',
      name: 'log_enable_global_catch',
      desc: '',
      args: [],
    );
  }

  /// `When enabled, console outputs and uncaught errors are automatically recorded locally.`
  String get log_enable_global_catch_hint {
    return Intl.message(
      'When enabled, console outputs and uncaught errors are automatically recorded locally.',
      name: 'log_enable_global_catch_hint',
      desc: '',
      args: [],
    );
  }

  /// `Refresh logs`
  String get log_refresh {
    return Intl.message(
      'Refresh logs',
      name: 'log_refresh',
      desc: '',
      args: [],
    );
  }

  /// `Clear logs`
  String get log_clear {
    return Intl.message('Clear logs', name: 'log_clear', desc: '', args: []);
  }

  /// `Copy logs`
  String get log_copy {
    return Intl.message('Copy logs', name: 'log_copy', desc: '', args: []);
  }

  /// `Logs copied to clipboard`
  String get log_copied_to_clipboard {
    return Intl.message(
      'Logs copied to clipboard',
      name: 'log_copied_to_clipboard',
      desc: '',
      args: [],
    );
  }

  /// `Database Version Incompatible`
  String get db_downgrade_title {
    return Intl.message(
      'Database Version Incompatible',
      name: 'db_downgrade_title',
      desc: '',
      args: [],
    );
  }

  /// `If you see this error, it means you have opened data created by a newer version of the software with an older version. This may cause the application to crash or completely corrupt the data.\nTo protect your data, this startup has been blocked. Please update the software to a newer version first.`
  String get db_downgrade_content {
    return Intl.message(
      'If you see this error, it means you have opened data created by a newer version of the software with an older version. This may cause the application to crash or completely corrupt the data.\nTo protect your data, this startup has been blocked. Please update the software to a newer version first.',
      name: 'db_downgrade_content',
      desc: '',
      args: [],
    );
  }

  /// `Downgrade occurred in {dbName}: Attempting to open newer database ({from}) with an older app version ({to})`
  String db_downgrade_error(Object dbName, Object from, Object to) {
    return Intl.message(
      'Downgrade occurred in $dbName: Attempting to open newer database ($from) with an older app version ($to)',
      name: 'db_downgrade_error',
      desc: '',
      args: [dbName, from, to],
    );
  }

  /// `Branched from {branch}`
  String branched_from(Object branch) {
    return Intl.message(
      'Branched from $branch',
      name: 'branched_from',
      desc: '',
      args: [branch],
    );
  }

  /// `Branches {branch}`
  String branches(Object branch) {
    return Intl.message(
      'Branches $branch',
      name: 'branches',
      desc: '',
      args: [branch],
    );
  }

  /// `Edit more`
  String get edit_more {
    return Intl.message('Edit more', name: 'edit_more', desc: '', args: []);
  }

  /// `Check for updates`
  String get check_updates {
    return Intl.message(
      'Check for updates',
      name: 'check_updates',
      desc: '',
      args: [],
    );
  }

  /// `Help & Guides`
  String get help_guides {
    return Intl.message(
      'Help & Guides',
      name: 'help_guides',
      desc: '',
      args: [],
    );
  }

  /// `GitHub Repository`
  String get github_repo {
    return Intl.message(
      'GitHub Repository',
      name: 'github_repo',
      desc: '',
      args: [],
    );
  }

  /// `Email: {email}`
  String email_with_holder(Object email) {
    return Intl.message(
      'Email: $email',
      name: 'email_with_holder',
      desc: '',
      args: [email],
    );
  }

  /// `Copyright © 2026 LinChi all rights reserved.`
  String get all_rights_reserved {
    return Intl.message(
      'Copyright © 2026 LinChi all rights reserved.',
      name: 'all_rights_reserved',
      desc: '',
      args: [],
    );
  }

  /// `Maximize`
  String get maximize {
    return Intl.message('Maximize', name: 'maximize', desc: '', args: []);
  }

  /// `Restore`
  String get restore {
    return Intl.message('Restore', name: 'restore', desc: '', args: []);
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  /// `Back`
  String get back {
    return Intl.message('Back', name: 'back', desc: '', args: []);
  }

  /// `V 1.0 Beta Preview`
  String get version_preview {
    return Intl.message(
      'V 1.0 Beta Preview',
      name: 'version_preview',
      desc: '',
      args: [],
    );
  }

  /// `Token Usage`
  String get token_usage {
    return Intl.message('Token Usage', name: 'token_usage', desc: '', args: []);
  }

  /// `Usage Trend`
  String get usage_trend {
    return Intl.message('Usage Trend', name: 'usage_trend', desc: '', args: []);
  }

  /// `Model Breakdown`
  String get model_breakdown {
    return Intl.message(
      'Model Breakdown',
      name: 'model_breakdown',
      desc: '',
      args: [],
    );
  }

  /// `Total Tokens`
  String get total_tokens {
    return Intl.message(
      'Total Tokens',
      name: 'total_tokens',
      desc: '',
      args: [],
    );
  }

  /// `Prompt`
  String get prompt {
    return Intl.message('Prompt', name: 'prompt', desc: '', args: []);
  }

  /// `Completion`
  String get completion {
    return Intl.message('Completion', name: 'completion', desc: '', args: []);
  }

  /// `No data in this period`
  String get no_data_period {
    return Intl.message(
      'No data in this period',
      name: 'no_data_period',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the 'comment: model_parameter' key

  /// `Temperature`
  String get model_param_temperature {
    return Intl.message(
      'Temperature',
      name: 'model_param_temperature',
      desc: '',
      args: [],
    );
  }

  /// `Top P`
  String get model_param_top_p {
    return Intl.message('Top P', name: 'model_param_top_p', desc: '', args: []);
  }

  /// `Top K`
  String get model_param_top_k {
    return Intl.message('Top K', name: 'model_param_top_k', desc: '', args: []);
  }

  /// `Presence Penalty`
  String get model_param_presence_penalty {
    return Intl.message(
      'Presence Penalty',
      name: 'model_param_presence_penalty',
      desc: '',
      args: [],
    );
  }

  /// `Frequency Penalty`
  String get model_param_frequency_penalty {
    return Intl.message(
      'Frequency Penalty',
      name: 'model_param_frequency_penalty',
      desc: '',
      args: [],
    );
  }

  /// `Repetition Penalty`
  String get model_param_repetition_penalty {
    return Intl.message(
      'Repetition Penalty',
      name: 'model_param_repetition_penalty',
      desc: '',
      args: [],
    );
  }

  /// `Min P`
  String get model_param_min_p {
    return Intl.message('Min P', name: 'model_param_min_p', desc: '', args: []);
  }

  /// `Top A`
  String get model_param_top_a {
    return Intl.message('Top A', name: 'model_param_top_a', desc: '', args: []);
  }

  /// `Seed`
  String get model_param_seed {
    return Intl.message('Seed', name: 'model_param_seed', desc: '', args: []);
  }

  /// `Max Completion Tokens`
  String get model_param_max_tokens {
    return Intl.message(
      'Max Completion Tokens',
      name: 'model_param_max_tokens',
      desc: '',
      args: [],
    );
  }

  /// `Stop Sequences`
  String get model_param_stop {
    return Intl.message(
      'Stop Sequences',
      name: 'model_param_stop',
      desc: '',
      args: [],
    );
  }

  /// `Include Reasoning`
  String get model_param_include_reasoning {
    return Intl.message(
      'Include Reasoning',
      name: 'model_param_include_reasoning',
      desc: '',
      args: [],
    );
  }

  /// `Logit Bias`
  String get model_param_logit_bias {
    return Intl.message(
      'Logit Bias',
      name: 'model_param_logit_bias',
      desc: '',
      args: [],
    );
  }

  /// `Reasoning`
  String get model_param_reasoning {
    return Intl.message(
      'Reasoning',
      name: 'model_param_reasoning',
      desc: '',
      args: [],
    );
  }

  /// `Response Format`
  String get model_param_response_format {
    return Intl.message(
      'Response Format',
      name: 'model_param_response_format',
      desc: '',
      args: [],
    );
  }

  /// `Structured Outputs`
  String get model_param_structured_outputs {
    return Intl.message(
      'Structured Outputs',
      name: 'model_param_structured_outputs',
      desc: '',
      args: [],
    );
  }

  /// `Tool Choice`
  String get model_param_tool_choice {
    return Intl.message(
      'Tool Choice',
      name: 'model_param_tool_choice',
      desc: '',
      args: [],
    );
  }

  /// `Tools List`
  String get model_param_tools {
    return Intl.message(
      'Tools List',
      name: 'model_param_tools',
      desc: '',
      args: [],
    );
  }

  /// `Add Parameter`
  String get add_parameter {
    return Intl.message(
      'Add Parameter',
      name: 'add_parameter',
      desc: '',
      args: [],
    );
  }

  /// `Select parameter to add`
  String get select_parameter {
    return Intl.message(
      'Select parameter to add',
      name: 'select_parameter',
      desc: '',
      args: [],
    );
  }

  /// `Model Pricing Settings`
  String get model_pricing_settings {
    return Intl.message(
      'Model Pricing Settings',
      name: 'model_pricing_settings',
      desc: '',
      args: [],
    );
  }

  /// `Prompt Price (per 1M tokens)`
  String get prompt_price_per_1k {
    return Intl.message(
      'Prompt Price (per 1M tokens)',
      name: 'prompt_price_per_1k',
      desc: '',
      args: [],
    );
  }

  /// `Completion Price (per 1M tokens)`
  String get completion_price_per_1k {
    return Intl.message(
      'Completion Price (per 1M tokens)',
      name: 'completion_price_per_1k',
      desc: '',
      args: [],
    );
  }

  /// `Please enter Prompt price`
  String get enter_prompt_price {
    return Intl.message(
      'Please enter Prompt price',
      name: 'enter_prompt_price',
      desc: '',
      args: [],
    );
  }

  /// `Please enter Completion price`
  String get enter_completion_price {
    return Intl.message(
      'Please enter Completion price',
      name: 'enter_completion_price',
      desc: '',
      args: [],
    );
  }

  /// `Price cannot be empty`
  String get price_not_empty {
    return Intl.message(
      'Price cannot be empty',
      name: 'price_not_empty',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid number`
  String get invalid_number {
    return Intl.message(
      'Please enter a valid number',
      name: 'invalid_number',
      desc: '',
      args: [],
    );
  }

  /// `Currency`
  String get currency {
    return Intl.message('Currency', name: 'currency', desc: '', args: []);
  }

  /// `Cache Read Price (per 1M tokens)`
  String get cache_price_per_1k {
    return Intl.message(
      'Cache Read Price (per 1M tokens)',
      name: 'cache_price_per_1k',
      desc: '',
      args: [],
    );
  }

  /// `Please enter Cache Read price`
  String get enter_cache_price {
    return Intl.message(
      'Please enter Cache Read price',
      name: 'enter_cache_price',
      desc: '',
      args: [],
    );
  }

  /// `Full Settings`
  String get full_settings {
    return Intl.message(
      'Full Settings',
      name: 'full_settings',
      desc: '',
      args: [],
    );
  }

  /// `Session Agent Override`
  String get agent_override_title {
    return Intl.message(
      'Session Agent Override',
      name: 'agent_override_title',
      desc: '',
      args: [],
    );
  }

  /// `You are editing the override configuration for this session. Changes will only apply to the current session and won't affect the global Agent settings.`
  String get agent_override_editing_hint {
    return Intl.message(
      'You are editing the override configuration for this session. Changes will only apply to the current session and won\'t affect the global Agent settings.',
      name: 'agent_override_editing_hint',
      desc: '',
      args: [],
    );
  }

  /// `Disable Persona`
  String get disable_persona {
    return Intl.message(
      'Disable Persona',
      name: 'disable_persona',
      desc: '',
      args: [],
    );
  }

  /// `Persona System Disabled`
  String get persona_system_disabled {
    return Intl.message(
      'Persona System Disabled',
      name: 'persona_system_disabled',
      desc: '',
      args: [],
    );
  }

  /// `Unsaved Changes`
  String get unsaved_changes_title {
    return Intl.message(
      'Unsaved Changes',
      name: 'unsaved_changes_title',
      desc: '',
      args: [],
    );
  }

  /// `Detected unsaved changes. Do you want to save before exiting?`
  String get unsaved_changes_message {
    return Intl.message(
      'Detected unsaved changes. Do you want to save before exiting?',
      name: 'unsaved_changes_message',
      desc: '',
      args: [],
    );
  }

  /// `Save and Exit`
  String get save_and_exit {
    return Intl.message(
      'Save and Exit',
      name: 'save_and_exit',
      desc: '',
      args: [],
    );
  }

  /// `Discard Changes`
  String get discard_changes {
    return Intl.message(
      'Discard Changes',
      name: 'discard_changes',
      desc: '',
      args: [],
    );
  }

  /// `Limit model maximum generate length`
  String get limit_model_generate_length {
    return Intl.message(
      'Limit model maximum generate length',
      name: 'limit_model_generate_length',
      desc: '',
      args: [],
    );
  }

  /// `No limit`
  String get no_limit {
    return Intl.message('No limit', name: 'no_limit', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
