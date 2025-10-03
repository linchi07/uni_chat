// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
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
  String get localeName => 'zh';

  static String m0(apiKey) => "共${apiKey}个Key";

  static String m1(provider) => "编辑提供商：${provider}";

  static String m2(endPoint) => "端点";

  static String m3(endPoint) => "端点：${endPoint}";

  static String m4(error) => "发生错误:${error}";

  static String m5(token) => "知识库（${token}Tokens）";

  static String m6(errorContent) => "加载错误${errorContent}";

  static String m7(token) => "最长的开场白（${token}Tokens）";

  static String m8(charCount, maxCount) =>
      "你已超出最大系统提示词上限，多余部分将会被截断，请增大模型上下文或者精简提示词${charCount}/${maxCount}";

  static String m9(sec) => "思考了${sec}秒";

  static String m10(sec) => "正在思考... ${sec}秒";

  static String m11(token) => "内建提示词（${token}Tokens）";

  static String m12(token) => "系统提示词（${token}Tokens）";

  static String m13(token) => "可用于对话的Token：${token}";

  static String m14(lim) => "总上下文上限：${lim}";

  static String m15(type) => "类型:${type}";

  static String m16(token) => "UI交互提示词（${token}Tokens）";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "API_settings": MessageLookupByLibrary.simpleMessage("API设置"),
    "DEFAULT": MessageLookupByLibrary.simpleMessage("默认"),
    "about": MessageLookupByLibrary.simpleMessage("关于"),
    "add": MessageLookupByLibrary.simpleMessage("添加"),
    "add_api_key": MessageLookupByLibrary.simpleMessage("添加API密钥"),
    "add_api_key_hint": MessageLookupByLibrary.simpleMessage(
      "暂无 API 密钥 \n 请点击右下角+按钮添加",
    ),
    "add_entries": MessageLookupByLibrary.simpleMessage("添加条目"),
    "add_model_hint": MessageLookupByLibrary.simpleMessage("暂无模型\n请点击右下角+按钮添加"),
    "add_persona": MessageLookupByLibrary.simpleMessage("添加人格"),
    "add_provider": MessageLookupByLibrary.simpleMessage("添加提供商"),
    "agent_delete_confirm": MessageLookupByLibrary.simpleMessage(
      "确定要删除此Agent吗？\n 删除后所有和此Agent关联的聊天记录将会一并删除",
    ),
    "agent_desc_hint": MessageLookupByLibrary.simpleMessage("请输入Agent描述"),
    "agent_manage": MessageLookupByLibrary.simpleMessage("Agent管理"),
    "agent_name_hint": MessageLookupByLibrary.simpleMessage("请给Agent起名"),
    "agent_sets": MessageLookupByLibrary.simpleMessage("Agent设置"),
    "api_key": MessageLookupByLibrary.simpleMessage("API密钥"),
    "api_key_set": MessageLookupByLibrary.simpleMessage("API密钥已设置"),
    "api_key_total": m0,
    "api_settings": MessageLookupByLibrary.simpleMessage("API设置"),
    "auto_shrink_large_panel": MessageLookupByLibrary.simpleMessage("自动缩小大面板"),
    "avatar_change_hint": MessageLookupByLibrary.simpleMessage("点击或拖拽新图片来更换头像"),
    "cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "cancel_long_press": MessageLookupByLibrary.simpleMessage("取消（长按）"),
    "chat": MessageLookupByLibrary.simpleMessage("聊天"),
    "check_manual": MessageLookupByLibrary.simpleMessage("查看帮助文档"),
    "choose_agent_and_chat_hint": MessageLookupByLibrary.simpleMessage(
      "选择一个Agent并开始聊天吧!",
    ),
    "click_upload_image": MessageLookupByLibrary.simpleMessage("点击上传图片"),
    "confirm": MessageLookupByLibrary.simpleMessage("确定"),
    "confirm_adding_model": MessageLookupByLibrary.simpleMessage("确认需要添加的模型"),
    "confirm_delete_provider": MessageLookupByLibrary.simpleMessage(
      "确定要删除此提供者吗？",
    ),
    "confirm_delete_session": MessageLookupByLibrary.simpleMessage(
      "确定要删除此对话记录吗？",
    ),
    "confirm_long_press": MessageLookupByLibrary.simpleMessage("确定（长按）"),
    "content": MessageLookupByLibrary.simpleMessage("内容"),
    "create_new_agent": MessageLookupByLibrary.simpleMessage("创建一个新Agent"),
    "create_new_model": MessageLookupByLibrary.simpleMessage("创建新模型"),
    "delete": MessageLookupByLibrary.simpleMessage("删除"),
    "delete_long_press": MessageLookupByLibrary.simpleMessage("删除（长按）"),
    "disable": MessageLookupByLibrary.simpleMessage("禁用"),
    "drag_image_hint": MessageLookupByLibrary.simpleMessage("拖拽图片到此处"),
    "drop_files_hint": MessageLookupByLibrary.simpleMessage("在这里拖放文件"),
    "edit": MessageLookupByLibrary.simpleMessage("编辑"),
    "edit_entries": MessageLookupByLibrary.simpleMessage("编辑条目"),
    "edit_persona": MessageLookupByLibrary.simpleMessage("编辑人格"),
    "edit_provider": m1,
    "embedding_model_note": MessageLookupByLibrary.simpleMessage(
      "请注意，该模型是嵌入模型，不能用作文本生成模型。",
    ),
    "enable": MessageLookupByLibrary.simpleMessage("启用"),
    "enable_ui_interactions": MessageLookupByLibrary.simpleMessage("启用UI交互功能"),
    "end_point": m2,
    "end_point_set": MessageLookupByLibrary.simpleMessage("端点已设置"),
    "end_point_type": MessageLookupByLibrary.simpleMessage("端点类型"),
    "end_point_type_set": MessageLookupByLibrary.simpleMessage("端点类型已设置"),
    "end_point_with_holder": m3,
    "enlarge_context_or_simplify_prompt": MessageLookupByLibrary.simpleMessage(
      "扩大模型上下文或简化提示词",
    ),
    "enter_end_point": MessageLookupByLibrary.simpleMessage("输入API端点"),
    "enter_opening_here": MessageLookupByLibrary.simpleMessage("在这里输入开场白"),
    "enter_provider_details": MessageLookupByLibrary.simpleMessage(
      "请输入提供商详细信息",
    ),
    "enter_session_name": MessageLookupByLibrary.simpleMessage("请输入对话记录名称"),
    "enter_sys_prompt_here": MessageLookupByLibrary.simpleMessage("在这里输入系统提示词"),
    "error_occurred": MessageLookupByLibrary.simpleMessage("发生错误"),
    "error_occurred_with_error": m4,
    "fill_in_api_key": MessageLookupByLibrary.simpleMessage("填写API密钥"),
    "fill_model_call_name": MessageLookupByLibrary.simpleMessage("模型调用名"),
    "fill_reminder_null_if_blank": MessageLookupByLibrary.simpleMessage(
      "填写备注(留空默认无)",
    ),
    "finish_edit": MessageLookupByLibrary.simpleMessage("完成编辑"),
    "freq_penalty": MessageLookupByLibrary.simpleMessage("频度惩罚"),
    "front_page_hintLine_char1": MessageLookupByLibrary.simpleMessage("以 "),
    "front_page_hintLine_char2": MessageLookupByLibrary.simpleMessage(" 和 "),
    "front_page_hintLine_char3": MessageLookupByLibrary.simpleMessage(" 开始聊天"),
    "general_settings": MessageLookupByLibrary.simpleMessage("通用设置"),
    "give_up_edit_confirm": MessageLookupByLibrary.simpleMessage("确定放弃编辑吗？"),
    "go_back": MessageLookupByLibrary.simpleMessage("返回"),
    "google_compatible_api": MessageLookupByLibrary.simpleMessage("谷歌兼容"),
    "help": MessageLookupByLibrary.simpleMessage("帮助"),
    "hide_cot": MessageLookupByLibrary.simpleMessage("隐藏思维链"),
    "hide_knowledge_base_results": MessageLookupByLibrary.simpleMessage(
      "隐藏检索结果",
    ),
    "hide_source_code": MessageLookupByLibrary.simpleMessage("隐藏源码"),
    "hover_to_see_session": MessageLookupByLibrary.simpleMessage("鼠标悬停来预览会话"),
    "image_load_fail": MessageLookupByLibrary.simpleMessage("图片加载失败"),
    "knowledge_base": MessageLookupByLibrary.simpleMessage("知识库"),
    "knowledge_base_and_contexts": MessageLookupByLibrary.simpleMessage(
      "知识库&上下文检索",
    ),
    "knowledge_base_tokens": m5,
    "language_select": MessageLookupByLibrary.simpleMessage("选择语言"),
    "language_settings": MessageLookupByLibrary.simpleMessage("语言设置"),
    "language_switch_restart_note": MessageLookupByLibrary.simpleMessage(
      "部分更改需要重启App来生效",
    ),
    "loading_error": m6,
    "longest_opening": m7,
    "model": MessageLookupByLibrary.simpleMessage("模型"),
    "model_ability": MessageLookupByLibrary.simpleMessage("模型能力"),
    "model_advance_properties": MessageLookupByLibrary.simpleMessage("模型高级设置"),
    "model_basic_info_pass_through_setting":
        MessageLookupByLibrary.simpleMessage("模型基础信息传递设置"),
    "model_call_name_hint": MessageLookupByLibrary.simpleMessage(
      "请输入模型调用名称（例如：qwen/qwen-7b-chat）",
    ),
    "model_context_not_enough": MessageLookupByLibrary.simpleMessage("模型上下文不足"),
    "model_delete_confirm": MessageLookupByLibrary.simpleMessage(
      "确定要删除此模型吗？\n 删除后所有提供此模型的提供者将无法使用此模型。",
    ),
    "model_family": MessageLookupByLibrary.simpleMessage("模型家族"),
    "model_family_hint": MessageLookupByLibrary.simpleMessage(
      "请输入模型家族（例如：qwen3）",
    ),
    "model_friendly_name": MessageLookupByLibrary.simpleMessage("模型友好名称"),
    "model_friendly_name_hint": MessageLookupByLibrary.simpleMessage(
      "请输入模型友好名称（例如：Qwen 7B）",
    ),
    "model_local_telling": MessageLookupByLibrary.simpleMessage(
      "告知模型当前用户地区和语言",
    ),
    "model_management": MessageLookupByLibrary.simpleMessage("模型管理"),
    "model_maximum_context_length": MessageLookupByLibrary.simpleMessage(
      "模型最大上下文长度",
    ),
    "model_maximum_generate_length": MessageLookupByLibrary.simpleMessage(
      "模型最大生成长度",
    ),
    "model_property": MessageLookupByLibrary.simpleMessage("模型属性设置"),
    "model_select": MessageLookupByLibrary.simpleMessage("模型选择"),
    "model_sets": MessageLookupByLibrary.simpleMessage("模型设置"),
    "model_system_telling": MessageLookupByLibrary.simpleMessage(
      "告知模型当前操作系统（如：macos Sonoma）",
    ),
    "model_time_telling": MessageLookupByLibrary.simpleMessage("告知模型当前系统时间"),
    "modify_session_name": MessageLookupByLibrary.simpleMessage("修改对话记录名称"),
    "name": MessageLookupByLibrary.simpleMessage("名称"),
    "new_chat_session": MessageLookupByLibrary.simpleMessage("新聊天会话"),
    "next_step": MessageLookupByLibrary.simpleMessage("下一步"),
    "no_agent": MessageLookupByLibrary.simpleMessage("暂无Agent,请添加一个"),
    "no_history": MessageLookupByLibrary.simpleMessage("暂无对话历史"),
    "no_message": MessageLookupByLibrary.simpleMessage("没有消息"),
    "no_model": MessageLookupByLibrary.simpleMessage("无模型"),
    "no_model_plz_add": MessageLookupByLibrary.simpleMessage(
      "没有模型，请前往API设置中添加",
    ),
    "no_persona": MessageLookupByLibrary.simpleMessage("没有人格"),
    "no_provider": MessageLookupByLibrary.simpleMessage("暂无提供商"),
    "no_results": MessageLookupByLibrary.simpleMessage("无结果"),
    "openai_compatible_api": MessageLookupByLibrary.simpleMessage("OpenAI兼容"),
    "openai_completion_compatible_api": MessageLookupByLibrary.simpleMessage(
      "OpenAi Completion (Legacy) 兼容",
    ),
    "opening": MessageLookupByLibrary.simpleMessage("开场白"),
    "opening_set": MessageLookupByLibrary.simpleMessage("开场白设置"),
    "or_expand_window": MessageLookupByLibrary.simpleMessage("或请拉大窗口"),
    "over_maximum_context_length_hint": m8,
    "persona_description_hint": MessageLookupByLibrary.simpleMessage("请介绍一下自己"),
    "plz_enter_content": MessageLookupByLibrary.simpleMessage("请输入内容"),
    "plz_enter_description": MessageLookupByLibrary.simpleMessage("请输入描述"),
    "plz_enter_name": MessageLookupByLibrary.simpleMessage("请输入名称"),
    "plz_fill_model_call_name": MessageLookupByLibrary.simpleMessage(
      "请填写模型调用名",
    ),
    "plz_select_agent": MessageLookupByLibrary.simpleMessage("请选择Agent"),
    "plz_select_persona": MessageLookupByLibrary.simpleMessage("请选择人格"),
    "plz_select_provider": MessageLookupByLibrary.simpleMessage("请选择提供商"),
    "preferences": MessageLookupByLibrary.simpleMessage("设置"),
    "pres_penalty": MessageLookupByLibrary.simpleMessage("存在惩罚"),
    "provider_select": MessageLookupByLibrary.simpleMessage("提供商选择"),
    "quit": MessageLookupByLibrary.simpleMessage("退出"),
    "reasoned": m9,
    "reasoning": m10,
    "rename": MessageLookupByLibrary.simpleMessage("重命名"),
    "retry": MessageLookupByLibrary.simpleMessage("重试"),
    "save": MessageLookupByLibrary.simpleMessage("保存"),
    "search_any_chat_message": MessageLookupByLibrary.simpleMessage("搜索任何聊天内容"),
    "searched_knowledge_base": MessageLookupByLibrary.simpleMessage("检索了知识库"),
    "searching_knowledge_base": MessageLookupByLibrary.simpleMessage(
      "正在检索知识库...",
    ),
    "select_api_type": MessageLookupByLibrary.simpleMessage("选择API类型"),
    "select_image_hint": MessageLookupByLibrary.simpleMessage("拖拽或单击选择图片"),
    "select_model_hint": MessageLookupByLibrary.simpleMessage("选择一个模型"),
    "select_provider": MessageLookupByLibrary.simpleMessage("选择提供商"),
    "send_a_message_hint": MessageLookupByLibrary.simpleMessage("发送一条消息"),
    "set_as_default": MessageLookupByLibrary.simpleMessage("设为默认"),
    "show_cot": MessageLookupByLibrary.simpleMessage("显示思维链"),
    "show_knowledge_base_results": MessageLookupByLibrary.simpleMessage(
      "查看检索结果",
    ),
    "show_source_code": MessageLookupByLibrary.simpleMessage("显示源码"),
    "start_conversation_with_selected_agent":
        MessageLookupByLibrary.simpleMessage("与所选Agent开始新对话"),
    "supports_files_api": MessageLookupByLibrary.simpleMessage("是否支持文件API"),
    "switch_persona": MessageLookupByLibrary.simpleMessage("切换人格"),
    "sys_prompt": MessageLookupByLibrary.simpleMessage("系统提示词"),
    "system_internal_prompt": m11,
    "system_prompt_tokens": m12,
    "temperature": MessageLookupByLibrary.simpleMessage("温度"),
    "title": MessageLookupByLibrary.simpleMessage("UNIChat 通聊"),
    "token_available_for_chat": m13,
    "top_p": MessageLookupByLibrary.simpleMessage("Top P"),
    "total_context_lim": m14,
    "type_with_holder": m15,
    "ui_edited": MessageLookupByLibrary.simpleMessage("编辑了UI"),
    "ui_editing": MessageLookupByLibrary.simpleMessage("正在编辑UI..."),
    "ui_interaction_set": MessageLookupByLibrary.simpleMessage("UI交互(BETA)设置"),
    "ui_interactions": MessageLookupByLibrary.simpleMessage("UI操作"),
    "ui_interactions_tokens": m16,
    "usr_persona_set": MessageLookupByLibrary.simpleMessage("用户身份设置"),
    "view_all_provider_provide_model": MessageLookupByLibrary.simpleMessage(
      "查看所有提供此模型的提供者",
    ),
    "window_too_small_to_display_allPanels":
        MessageLookupByLibrary.simpleMessage("窗口过小，无法显示所有面板"),
  };
}
