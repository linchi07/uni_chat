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

  /// `暂无Agent,请添加一个`
  String get no_agent {
    return Intl.message('暂无Agent,请添加一个', name: 'no_agent', desc: '', args: []);
  }

  /// `暂无对话历史`
  String get no_history {
    return Intl.message('暂无对话历史', name: 'no_history', desc: '', args: []);
  }

  /// `鼠标悬停来预览会话`
  String get hover_to_see_session {
    return Intl.message(
      '鼠标悬停来预览会话',
      name: 'hover_to_see_session',
      desc: '',
      args: [],
    );
  }

  /// `没有消息`
  String get no_message {
    return Intl.message('没有消息', name: 'no_message', desc: '', args: []);
  }

  /// `重命名`
  String get rename {
    return Intl.message('重命名', name: 'rename', desc: '', args: []);
  }

  /// `删除`
  String get delete {
    return Intl.message('删除', name: 'delete', desc: '', args: []);
  }

  /// `确定要删除此对话记录吗？`
  String get confirm_delete_session {
    return Intl.message(
      '确定要删除此对话记录吗？',
      name: 'confirm_delete_session',
      desc: '',
      args: [],
    );
  }

  /// `取消`
  String get cancel {
    return Intl.message('取消', name: 'cancel', desc: '', args: []);
  }

  /// `确定`
  String get confirm {
    return Intl.message('确定', name: 'confirm', desc: '', args: []);
  }

  /// `确定（长按）`
  String get confirm_long_press {
    return Intl.message(
      '确定（长按）',
      name: 'confirm_long_press',
      desc: '',
      args: [],
    );
  }

  /// `修改对话记录名称`
  String get modify_session_name {
    return Intl.message(
      '修改对话记录名称',
      name: 'modify_session_name',
      desc: '',
      args: [],
    );
  }

  /// `请输入对话记录名称`
  String get enter_session_name {
    return Intl.message(
      '请输入对话记录名称',
      name: 'enter_session_name',
      desc: '',
      args: [],
    );
  }

  /// `窗口过小，无法显示所有面板`
  String get window_too_small_to_display_allPanels {
    return Intl.message(
      '窗口过小，无法显示所有面板',
      name: 'window_too_small_to_display_allPanels',
      desc: '',
      args: [],
    );
  }

  /// `自动缩小大面板`
  String get auto_shrink_large_panel {
    return Intl.message(
      '自动缩小大面板',
      name: 'auto_shrink_large_panel',
      desc: '',
      args: [],
    );
  }

  /// `或请拉大窗口`
  String get or_expand_window {
    return Intl.message('或请拉大窗口', name: 'or_expand_window', desc: '', args: []);
  }

  /// `完成编辑`
  String get finish_edit {
    return Intl.message('完成编辑', name: 'finish_edit', desc: '', args: []);
  }

  /// `确定要删除此提供者吗？`
  String get confirm_delete_provider {
    return Intl.message(
      '确定要删除此提供者吗？',
      name: 'confirm_delete_provider',
      desc: '',
      args: [],
    );
  }

  /// `加载错误{errorContent}`
  String loading_error(Object errorContent) {
    return Intl.message(
      '加载错误$errorContent',
      name: 'loading_error',
      desc: '',
      args: [errorContent],
    );
  }

  /// `API设置`
  String get api_settings {
    return Intl.message('API设置', name: 'api_settings', desc: '', args: []);
  }

  /// `添加提供商`
  String get add_provider {
    return Intl.message('添加提供商', name: 'add_provider', desc: '', args: []);
  }

  /// `暂无提供商`
  String get no_provider {
    return Intl.message('暂无提供商', name: 'no_provider', desc: '', args: []);
  }

  /// `类型:{type}`
  String type_with_holder(Object type) {
    return Intl.message(
      '类型:$type',
      name: 'type_with_holder',
      desc: '',
      args: [type],
    );
  }

  /// `端点：{endPoint}`
  String end_point_with_holder(Object endPoint) {
    return Intl.message(
      '端点：$endPoint',
      name: 'end_point_with_holder',
      desc: '',
      args: [endPoint],
    );
  }

  /// `编辑提供商：{provider}`
  String edit_provider(Object provider) {
    return Intl.message(
      '编辑提供商：$provider',
      name: 'edit_provider',
      desc: '',
      args: [provider],
    );
  }

  /// `选择提供商`
  String get select_provider {
    return Intl.message('选择提供商', name: 'select_provider', desc: '', args: []);
  }

  /// `请输入提供商详细信息`
  String get enter_provider_details {
    return Intl.message(
      '请输入提供商详细信息',
      name: 'enter_provider_details',
      desc: '',
      args: [],
    );
  }

  /// `名称`
  String get name {
    return Intl.message('名称', name: 'name', desc: '', args: []);
  }

  /// `端点`
  String end_point(Object endPoint) {
    return Intl.message('端点', name: 'end_point', desc: '', args: [endPoint]);
  }

  /// `端点已设置`
  String get end_point_set {
    return Intl.message('端点已设置', name: 'end_point_set', desc: '', args: []);
  }

  /// `输入API端点`
  String get enter_end_point {
    return Intl.message('输入API端点', name: 'enter_end_point', desc: '', args: []);
  }

  /// `端点类型`
  String get end_point_type {
    return Intl.message('端点类型', name: 'end_point_type', desc: '', args: []);
  }

  /// `端点类型已设置`
  String get end_point_type_set {
    return Intl.message(
      '端点类型已设置',
      name: 'end_point_type_set',
      desc: '',
      args: [],
    );
  }

  /// `API密钥`
  String get api_key {
    return Intl.message('API密钥', name: 'api_key', desc: '', args: []);
  }

  /// `添加API密钥`
  String get add_api_key {
    return Intl.message('添加API密钥', name: 'add_api_key', desc: '', args: []);
  }

  /// `API密钥已设置`
  String get api_key_set {
    return Intl.message('API密钥已设置', name: 'api_key_set', desc: '', args: []);
  }

  /// `共{apiKey}个Key`
  String api_key_total(Object apiKey) {
    return Intl.message(
      '共$apiKey个Key',
      name: 'api_key_total',
      desc: '',
      args: [apiKey],
    );
  }

  /// `暂无 API 密钥 \n 请点击右下角+按钮添加`
  String get add_api_key_hint {
    return Intl.message(
      '暂无 API 密钥 \n 请点击右下角+按钮添加',
      name: 'add_api_key_hint',
      desc: '',
      args: [],
    );
  }

  /// `填写API密钥`
  String get fill_in_api_key {
    return Intl.message('填写API密钥', name: 'fill_in_api_key', desc: '', args: []);
  }

  /// `填写备注(留空默认无)`
  String get fill_reminder_null_if_blank {
    return Intl.message(
      '填写备注(留空默认无)',
      name: 'fill_reminder_null_if_blank',
      desc: '',
      args: [],
    );
  }

  /// `模型`
  String get model {
    return Intl.message('模型', name: 'model', desc: '', args: []);
  }

  /// `暂无模型\n请点击右下角+按钮添加`
  String get add_model_hint {
    return Intl.message(
      '暂无模型\n请点击右下角+按钮添加',
      name: 'add_model_hint',
      desc: '',
      args: [],
    );
  }

  /// `填写模型调用名`
  String get fill_model_call_name {
    return Intl.message(
      '填写模型调用名',
      name: 'fill_model_call_name',
      desc: '',
      args: [],
    );
  }

  /// `请输入模型调用名称（例如：qwen/qwen-7b-chat）`
  String get model_call_name_hint {
    return Intl.message(
      '请输入模型调用名称（例如：qwen/qwen-7b-chat）',
      name: 'model_call_name_hint',
      desc: '',
      args: [],
    );
  }

  /// `模型友好名称`
  String get model_friendly_name {
    return Intl.message(
      '模型友好名称',
      name: 'model_friendly_name',
      desc: '',
      args: [],
    );
  }

  /// `请输入模型友好名称（例如：Qwen 7B）`
  String get model_friendly_name_hint {
    return Intl.message(
      '请输入模型友好名称（例如：Qwen 7B）',
      name: 'model_friendly_name_hint',
      desc: '',
      args: [],
    );
  }

  /// `模型家族`
  String get model_family {
    return Intl.message('模型家族', name: 'model_family', desc: '', args: []);
  }

  /// `请输入模型家族（例如：qwen）`
  String get model_family_hint {
    return Intl.message(
      '请输入模型家族（例如：qwen）',
      name: 'model_family_hint',
      desc: '',
      args: [],
    );
  }

  /// `请填写模型调用名`
  String get plz_fill_model_call_name {
    return Intl.message(
      '请填写模型调用名',
      name: 'plz_fill_model_call_name',
      desc: '',
      args: [],
    );
  }

  /// `确认需要添加的模型`
  String get confirm_adding_model {
    return Intl.message(
      '确认需要添加的模型',
      name: 'confirm_adding_model',
      desc: '',
      args: [],
    );
  }

  /// `请注意，该模型是嵌入模型，不能用作文本生成模型。`
  String get embedding_model_note {
    return Intl.message(
      '请注意，该模型是嵌入模型，不能用作文本生成模型。',
      name: 'embedding_model_note',
      desc: '',
      args: [],
    );
  }

  /// `模型能力`
  String get model_ability {
    return Intl.message('模型能力', name: 'model_ability', desc: '', args: []);
  }

  /// `选择一个模型`
  String get select_model_hint {
    return Intl.message(
      '选择一个模型',
      name: 'select_model_hint',
      desc: '',
      args: [],
    );
  }

  /// `无结果`
  String get no_results {
    return Intl.message('无结果', name: 'no_results', desc: '', args: []);
  }

  /// `创建新模型`
  String get create_new_model {
    return Intl.message('创建新模型', name: 'create_new_model', desc: '', args: []);
  }

  /// `保存`
  String get save {
    return Intl.message('保存', name: 'save', desc: '', args: []);
  }

  /// `添加`
  String get add {
    return Intl.message('添加', name: 'add', desc: '', args: []);
  }

  /// `返回`
  String get go_back {
    return Intl.message('返回', name: 'go_back', desc: '', args: []);
  }

  /// `下一步`
  String get next_step {
    return Intl.message('下一步', name: 'next_step', desc: '', args: []);
  }

  /// `选择API类型`
  String get select_api_type {
    return Intl.message('选择API类型', name: 'select_api_type', desc: '', args: []);
  }

  /// `OpenAI兼容`
  String get openai_compatible_api {
    return Intl.message(
      'OpenAI兼容',
      name: 'openai_compatible_api',
      desc: '',
      args: [],
    );
  }

  /// `谷歌兼容`
  String get google_compatible_api {
    return Intl.message(
      '谷歌兼容',
      name: 'google_compatible_api',
      desc: '',
      args: [],
    );
  }

  /// `OpenAi Completion (Legacy) 兼容`
  String get openai_completion_compatible_api {
    return Intl.message(
      'OpenAi Completion (Legacy) 兼容',
      name: 'openai_completion_compatible_api',
      desc: '',
      args: [],
    );
  }

  /// `是否支持文件API`
  String get supports_files_api {
    return Intl.message(
      '是否支持文件API',
      name: 'supports_files_api',
      desc: '',
      args: [],
    );
  }

  /// `发生错误`
  String get error_occurred {
    return Intl.message('发生错误', name: 'error_occurred', desc: '', args: []);
  }

  /// `发生错误:{error}`
  String error_occurred_with_error(Object error) {
    return Intl.message(
      '发生错误:$error',
      name: 'error_occurred_with_error',
      desc: '',
      args: [error],
    );
  }

  /// `请选择Agent`
  String get plz_select_agent {
    return Intl.message(
      '请选择Agent',
      name: 'plz_select_agent',
      desc: '',
      args: [],
    );
  }

  /// `没有人格`
  String get no_persona {
    return Intl.message('没有人格', name: 'no_persona', desc: '', args: []);
  }

  /// `请选择人格`
  String get plz_select_persona {
    return Intl.message(
      '请选择人格',
      name: 'plz_select_persona',
      desc: '',
      args: [],
    );
  }

  /// `选择一个Agent并开始聊天吧!`
  String get choose_agent_and_chat_hint {
    return Intl.message(
      '选择一个Agent并开始聊天吧!',
      name: 'choose_agent_and_chat_hint',
      desc: '',
      args: [],
    );
  }

  /// `以 `
  String get front_page_hintLine_char1 {
    return Intl.message(
      '以 ',
      name: 'front_page_hintLine_char1',
      desc: '',
      args: [],
    );
  }

  /// ` 和 `
  String get front_page_hintLine_char2 {
    return Intl.message(
      ' 和 ',
      name: 'front_page_hintLine_char2',
      desc: '',
      args: [],
    );
  }

  /// ` 开始聊天`
  String get front_page_hintLine_char3 {
    return Intl.message(
      ' 开始聊天',
      name: 'front_page_hintLine_char3',
      desc: '',
      args: [],
    );
  }

  /// `在这里拖放文件`
  String get drop_files_hint {
    return Intl.message('在这里拖放文件', name: 'drop_files_hint', desc: '', args: []);
  }

  /// `发送一条消息`
  String get send_a_message_hint {
    return Intl.message(
      '发送一条消息',
      name: 'send_a_message_hint',
      desc: '',
      args: [],
    );
  }

  /// `正在编辑UI...`
  String get ui_editing {
    return Intl.message('正在编辑UI...', name: 'ui_editing', desc: '', args: []);
  }

  /// `编辑了UI`
  String get ui_edited {
    return Intl.message('编辑了UI', name: 'ui_edited', desc: '', args: []);
  }

  /// `显示源码`
  String get show_source_code {
    return Intl.message('显示源码', name: 'show_source_code', desc: '', args: []);
  }

  /// `隐藏源码`
  String get hide_source_code {
    return Intl.message('隐藏源码', name: 'hide_source_code', desc: '', args: []);
  }

  /// `正在思考... {sec}秒`
  String reasoning(Object sec) {
    return Intl.message(
      '正在思考... $sec秒',
      name: 'reasoning',
      desc: '',
      args: [sec],
    );
  }

  /// `思考了{sec}秒`
  String reasoned(Object sec) {
    return Intl.message('思考了$sec秒', name: 'reasoned', desc: '', args: [sec]);
  }

  /// `显示思维链`
  String get show_cot {
    return Intl.message('显示思维链', name: 'show_cot', desc: '', args: []);
  }

  /// `隐藏思维链`
  String get hide_cot {
    return Intl.message('隐藏思维链', name: 'hide_cot', desc: '', args: []);
  }

  /// `正在检索知识库...`
  String get searching_knowledge_base {
    return Intl.message(
      '正在检索知识库...',
      name: 'searching_knowledge_base',
      desc: '',
      args: [],
    );
  }

  /// `检索了知识库`
  String get searched_knowledge_base {
    return Intl.message(
      '检索了知识库',
      name: 'searched_knowledge_base',
      desc: '',
      args: [],
    );
  }

  /// `查看检索结果`
  String get show_knowledge_base_results {
    return Intl.message(
      '查看检索结果',
      name: 'show_knowledge_base_results',
      desc: '',
      args: [],
    );
  }

  /// `隐藏检索结果`
  String get hide_knowledge_base_results {
    return Intl.message(
      '隐藏检索结果',
      name: 'hide_knowledge_base_results',
      desc: '',
      args: [],
    );
  }

  /// `Agent设置`
  String get agent_sets {
    return Intl.message('Agent设置', name: 'agent_sets', desc: '', args: []);
  }

  /// `拖拽或单击选择图片`
  String get select_image_hint {
    return Intl.message(
      '拖拽或单击选择图片',
      name: 'select_image_hint',
      desc: '',
      args: [],
    );
  }

  /// `模型设置`
  String get model_sets {
    return Intl.message('模型设置', name: 'model_sets', desc: '', args: []);
  }

  /// `系统提示词`
  String get sys_prompt {
    return Intl.message('系统提示词', name: 'sys_prompt', desc: '', args: []);
  }

  /// `知识库&上下文检索`
  String get knowledge_base_and_contexts {
    return Intl.message(
      '知识库&上下文检索',
      name: 'knowledge_base_and_contexts',
      desc: '',
      args: [],
    );
  }

  /// `UI交互(BETA)设置`
  String get ui_interaction_set {
    return Intl.message(
      'UI交互(BETA)设置',
      name: 'ui_interaction_set',
      desc: '',
      args: [],
    );
  }

  /// `用户身份设置`
  String get usr_persona_set {
    return Intl.message('用户身份设置', name: 'usr_persona_set', desc: '', args: []);
  }

  /// `开场白设置`
  String get opening_set {
    return Intl.message('开场白设置', name: 'opening_set', desc: '', args: []);
  }

  /// `启用`
  String get enable {
    return Intl.message('启用', name: 'enable', desc: '', args: []);
  }

  /// `禁用`
  String get disable {
    return Intl.message('禁用', name: 'disable', desc: '', args: []);
  }

  /// `取消（长按）`
  String get cancel_long_press {
    return Intl.message(
      '取消（长按）',
      name: 'cancel_long_press',
      desc: '',
      args: [],
    );
  }

  /// `模型上下文不足`
  String get model_context_not_enough {
    return Intl.message(
      '模型上下文不足',
      name: 'model_context_not_enough',
      desc: '',
      args: [],
    );
  }

  /// `内建提示词（{token}Tokens）`
  String system_internal_prompt(Object token) {
    return Intl.message(
      '内建提示词（${token}Tokens）',
      name: 'system_internal_prompt',
      desc: '',
      args: [token],
    );
  }

  /// `系统提示词（{token}Tokens）`
  String system_prompt_tokens(Object token) {
    return Intl.message(
      '系统提示词（${token}Tokens）',
      name: 'system_prompt_tokens',
      desc: '',
      args: [token],
    );
  }

  /// `知识库（{token}Tokens）`
  String knowledge_base_tokens(Object token) {
    return Intl.message(
      '知识库（${token}Tokens）',
      name: 'knowledge_base_tokens',
      desc: '',
      args: [token],
    );
  }

  /// `最长的开场白（{token}Tokens）`
  String longest_opening(Object token) {
    return Intl.message(
      '最长的开场白（${token}Tokens）',
      name: 'longest_opening',
      desc: '',
      args: [token],
    );
  }

  /// `UI交互提示词（{token}Tokens）`
  String ui_interactions_tokens(Object token) {
    return Intl.message(
      'UI交互提示词（${token}Tokens）',
      name: 'ui_interactions_tokens',
      desc: '',
      args: [token],
    );
  }

  /// `知识库`
  String get knowledge_base {
    return Intl.message('知识库', name: 'knowledge_base', desc: '', args: []);
  }

  /// `开场白`
  String get opening {
    return Intl.message('开场白', name: 'opening', desc: '', args: []);
  }

  /// `UI操作`
  String get ui_interactions {
    return Intl.message('UI操作', name: 'ui_interactions', desc: '', args: []);
  }

  /// `扩大模型上下文或简化提示词`
  String get enlarge_context_or_simplify_prompt {
    return Intl.message(
      '扩大模型上下文或简化提示词',
      name: 'enlarge_context_or_simplify_prompt',
      desc: '',
      args: [],
    );
  }

  /// `可用于对话的Token：{token}`
  String token_available_for_chat(Object token) {
    return Intl.message(
      '可用于对话的Token：$token',
      name: 'token_available_for_chat',
      desc: '',
      args: [token],
    );
  }

  /// `总上下文上限：{lim}`
  String total_context_lim(Object lim) {
    return Intl.message(
      '总上下文上限：$lim',
      name: 'total_context_lim',
      desc: '',
      args: [lim],
    );
  }

  /// `请给Agent起名`
  String get agent_name_hint {
    return Intl.message(
      '请给Agent起名',
      name: 'agent_name_hint',
      desc: '',
      args: [],
    );
  }

  /// `请输入Agent描述`
  String get agent_desc_hint {
    return Intl.message(
      '请输入Agent描述',
      name: 'agent_desc_hint',
      desc: '',
      args: [],
    );
  }

  /// `模型选择`
  String get model_select {
    return Intl.message('模型选择', name: 'model_select', desc: '', args: []);
  }

  /// `提供商选择`
  String get provider_select {
    return Intl.message('提供商选择', name: 'provider_select', desc: '', args: []);
  }

  /// `模型属性设置`
  String get model_property {
    return Intl.message('模型属性设置', name: 'model_property', desc: '', args: []);
  }

  /// `模型最大上下文长度`
  String get model_maximum_context_length {
    return Intl.message(
      '模型最大上下文长度',
      name: 'model_maximum_context_length',
      desc: '',
      args: [],
    );
  }

  /// `模型最大生成长度`
  String get model_maximum_generate_length {
    return Intl.message(
      '模型最大生成长度',
      name: 'model_maximum_generate_length',
      desc: '',
      args: [],
    );
  }

  /// `模型基础信息传递设置`
  String get model_basic_info_pass_through_setting {
    return Intl.message(
      '模型基础信息传递设置',
      name: 'model_basic_info_pass_through_setting',
      desc: '',
      args: [],
    );
  }

  /// `告知模型当前系统时间`
  String get model_time_telling {
    return Intl.message(
      '告知模型当前系统时间',
      name: 'model_time_telling',
      desc: '',
      args: [],
    );
  }

  /// `告知模型当前操作系统（如：macos Sonoma）`
  String get model_system_telling {
    return Intl.message(
      '告知模型当前操作系统（如：macos Sonoma）',
      name: 'model_system_telling',
      desc: '',
      args: [],
    );
  }

  /// `告知模型当前用户地区和语言`
  String get model_local_telling {
    return Intl.message(
      '告知模型当前用户地区和语言',
      name: 'model_local_telling',
      desc: '',
      args: [],
    );
  }

  /// `模型高级设置`
  String get model_advance_properties {
    return Intl.message(
      '模型高级设置',
      name: 'model_advance_properties',
      desc: '',
      args: [],
    );
  }

  /// `温度`
  String get temperature {
    return Intl.message('温度', name: 'temperature', desc: '', args: []);
  }

  /// `Top P`
  String get top_p {
    return Intl.message('Top P', name: 'top_p', desc: '', args: []);
  }

  /// `频度惩罚`
  String get freq_penalty {
    return Intl.message('频度惩罚', name: 'freq_penalty', desc: '', args: []);
  }

  /// `存在惩罚`
  String get pres_penalty {
    return Intl.message('存在惩罚', name: 'pres_penalty', desc: '', args: []);
  }

  /// `无模型`
  String get no_model {
    return Intl.message('无模型', name: 'no_model', desc: '', args: []);
  }

  /// `请选择提供商`
  String get plz_select_provider {
    return Intl.message(
      '请选择提供商',
      name: 'plz_select_provider',
      desc: '',
      args: [],
    );
  }

  /// `在这里输入系统提示词`
  String get enter_sys_prompt_here {
    return Intl.message(
      '在这里输入系统提示词',
      name: 'enter_sys_prompt_here',
      desc: '',
      args: [],
    );
  }

  /// `在这里输入开场白`
  String get enter_opening_here {
    return Intl.message(
      '在这里输入开场白',
      name: 'enter_opening_here',
      desc: '',
      args: [],
    );
  }

  /// `你已超出最大系统提示词上限，多余部分将会被截断，请增大模型上下文或者精简提示词{charCount}/{maxCount}`
  String over_maximum_context_length_hint(Object charCount, Object maxCount) {
    return Intl.message(
      '你已超出最大系统提示词上限，多余部分将会被截断，请增大模型上下文或者精简提示词$charCount/$maxCount',
      name: 'over_maximum_context_length_hint',
      desc: '',
      args: [charCount, maxCount],
    );
  }

  /// `搜索任何聊天内容`
  String get search_any_chat_message {
    return Intl.message(
      '搜索任何聊天内容',
      name: 'search_any_chat_message',
      desc: '',
      args: [],
    );
  }

  /// `与所选Agent开始新对话`
  String get start_conversation_with_selected_agent {
    return Intl.message(
      '与所选Agent开始新对话',
      name: 'start_conversation_with_selected_agent',
      desc: '',
      args: [],
    );
  }

  /// `启用UI交互功能`
  String get enable_ui_interactions {
    return Intl.message(
      '启用UI交互功能',
      name: 'enable_ui_interactions',
      desc: '',
      args: [],
    );
  }

  /// `Agent管理`
  String get agent_manage {
    return Intl.message('Agent管理', name: 'agent_manage', desc: '', args: []);
  }

  /// `创建一个新Agent`
  String get create_new_agent {
    return Intl.message(
      '创建一个新Agent',
      name: 'create_new_agent',
      desc: '',
      args: [],
    );
  }

  /// `确定要删除此Agent吗？\n 删除后所有和此Agent关联的聊天记录将会一并删除`
  String get agent_delete_confirm {
    return Intl.message(
      '确定要删除此Agent吗？\n 删除后所有和此Agent关联的聊天记录将会一并删除',
      name: 'agent_delete_confirm',
      desc: '',
      args: [],
    );
  }

  /// `没有模型，请前往API设置中添加`
  String get no_model_plz_add {
    return Intl.message(
      '没有模型，请前往API设置中添加',
      name: 'no_model_plz_add',
      desc: '',
      args: [],
    );
  }

  /// `查看所有提供此模型的提供者`
  String get view_all_provider_provide_model {
    return Intl.message(
      '查看所有提供此模型的提供者',
      name: 'view_all_provider_provide_model',
      desc: '',
      args: [],
    );
  }

  /// `确定要删除此模型吗？\n 删除后所有提供此模型的提供者将无法使用此模型。`
  String get model_delete_confirm {
    return Intl.message(
      '确定要删除此模型吗？\n 删除后所有提供此模型的提供者将无法使用此模型。',
      name: 'model_delete_confirm',
      desc: '',
      args: [],
    );
  }

  /// `图片加载失败`
  String get image_load_fail {
    return Intl.message('图片加载失败', name: 'image_load_fail', desc: '', args: []);
  }

  /// `重试`
  String get retry {
    return Intl.message('重试', name: 'retry', desc: '', args: []);
  }

  /// `点击上传图片`
  String get click_upload_image {
    return Intl.message(
      '点击上传图片',
      name: 'click_upload_image',
      desc: '',
      args: [],
    );
  }

  /// `设为默认`
  String get set_as_default {
    return Intl.message('设为默认', name: 'set_as_default', desc: '', args: []);
  }

  /// `编辑`
  String get edit {
    return Intl.message('编辑', name: 'edit', desc: '', args: []);
  }

  /// `删除（长按）`
  String get delete_long_press {
    return Intl.message(
      '删除（长按）',
      name: 'delete_long_press',
      desc: '',
      args: [],
    );
  }

  /// `默认`
  String get DEFAULT {
    return Intl.message('默认', name: 'DEFAULT', desc: '', args: []);
  }

  /// `切换人格`
  String get switch_persona {
    return Intl.message('切换人格', name: 'switch_persona', desc: '', args: []);
  }

  /// `添加人格`
  String get add_persona {
    return Intl.message('添加人格', name: 'add_persona', desc: '', args: []);
  }

  /// `编辑人格`
  String get edit_persona {
    return Intl.message('编辑人格', name: 'edit_persona', desc: '', args: []);
  }

  /// `确定放弃编辑吗？`
  String get give_up_edit_confirm {
    return Intl.message(
      '确定放弃编辑吗？',
      name: 'give_up_edit_confirm',
      desc: '',
      args: [],
    );
  }

  /// `编辑条目`
  String get edit_entries {
    return Intl.message('编辑条目', name: 'edit_entries', desc: '', args: []);
  }

  /// `添加条目`
  String get add_entries {
    return Intl.message('添加条目', name: 'add_entries', desc: '', args: []);
  }

  /// `请输入名称`
  String get plz_enter_name {
    return Intl.message('请输入名称', name: 'plz_enter_name', desc: '', args: []);
  }

  /// `请输入内容`
  String get plz_enter_content {
    return Intl.message('请输入内容', name: 'plz_enter_content', desc: '', args: []);
  }

  /// `内容`
  String get content {
    return Intl.message('内容', name: 'content', desc: '', args: []);
  }

  /// `点击或拖拽新图片来更换头像`
  String get avatar_change_hint {
    return Intl.message(
      '点击或拖拽新图片来更换头像',
      name: 'avatar_change_hint',
      desc: '',
      args: [],
    );
  }

  /// `请介绍一下自己`
  String get persona_description_hint {
    return Intl.message(
      '请介绍一下自己',
      name: 'persona_description_hint',
      desc: '',
      args: [],
    );
  }

  /// `请输入描述`
  String get plz_enter_description {
    return Intl.message(
      '请输入描述',
      name: 'plz_enter_description',
      desc: '',
      args: [],
    );
  }

  /// `拖拽图片到此处`
  String get drag_image_hint {
    return Intl.message('拖拽图片到此处', name: 'drag_image_hint', desc: '', args: []);
  }

  /// `设置`
  String get preferences {
    return Intl.message('设置', name: 'preferences', desc: '', args: []);
  }

  /// `API设置`
  String get API_settings {
    return Intl.message('API设置', name: 'API_settings', desc: '', args: []);
  }

  /// `模型管理`
  String get model_management {
    return Intl.message('模型管理', name: 'model_management', desc: '', args: []);
  }

  /// `通用设置`
  String get general_settings {
    return Intl.message('通用设置', name: 'general_settings', desc: '', args: []);
  }

  /// `语言设置`
  String get language_settings {
    return Intl.message('语言设置', name: 'language_settings', desc: '', args: []);
  }

  /// `关于`
  String get about {
    return Intl.message('关于', name: 'about', desc: '', args: []);
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
