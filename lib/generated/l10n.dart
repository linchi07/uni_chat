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
    final name =
        (locale.countryCode?.isEmpty ?? false)
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

  /// `no message`
  String get no_message {
    return Intl.message('no message', name: 'no_message', desc: '', args: []);
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

  /// `{apiKey} total`
  String api_key_total(Object apiKey) {
    return Intl.message(
      '$apiKey total',
      name: 'api_key_total',
      desc: '',
      args: [apiKey],
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

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
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

  /// `Select an agent and start chatting`
  String get choose_agent_and_chat_hint {
    return Intl.message(
      'Select an agent and start chatting',
      name: 'choose_agent_and_chat_hint',
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

  /// `Drop files here`
  String get drop_files_hint {
    return Intl.message(
      'Drop files here',
      name: 'drop_files_hint',
      desc: '',
      args: [],
    );
  }

  /// `Send a message`
  String get send_a_message_hint {
    return Intl.message(
      'Send a message',
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

  /// `Thinking...{sec}s`
  String reasoning(Object sec) {
    return Intl.message(
      'Thinking...${sec}s',
      name: 'reasoning',
      desc: '',
      args: [sec],
    );
  }

  /// `Thought {sec}s`
  String reasoned(Object sec) {
    return Intl.message(
      'Thought ${sec}s',
      name: 'reasoned',
      desc: '',
      args: [sec],
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

  /// `Temperature`
  String get temperature {
    return Intl.message('Temperature', name: 'temperature', desc: '', args: []);
  }

  /// `Top P`
  String get top_p {
    return Intl.message('Top P', name: 'top_p', desc: '', args: []);
  }

  /// `Frequency Penalty`
  String get freq_penalty {
    return Intl.message(
      'Frequency Penalty',
      name: 'freq_penalty',
      desc: '',
      args: [],
    );
  }

  /// `Presence Penalty`
  String get pres_penalty {
    return Intl.message(
      'Presence Penalty',
      name: 'pres_penalty',
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

  /// `Enter system prompt here...`
  String get enter_sys_prompt_here {
    return Intl.message(
      'Enter system prompt here...',
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

  /// `Retry`
  String get retry {
    return Intl.message('Retry', name: 'retry', desc: '', args: []);
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
