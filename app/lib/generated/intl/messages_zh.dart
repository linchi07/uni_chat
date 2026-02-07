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

  static String m1(num) => "共${num}个密钥已配置";

  static String m2(provider) => "编辑提供商：${provider}";

  static String m3(endPoint) => "端点";

  static String m4(endPoint) => "端点：${endPoint}";

  static String m5(error) => "发生错误:${error}";

  static String m6(condition) => "在${condition}时";

  static String m7(token) => "知识库（${token}Tokens）";

  static String m8(errorContent) => "加载错误${errorContent}";

  static String m9(token) => "最长的开场白（${token}Tokens）";

  static String m10(num) => "已配置${num}个模型";

  static String m11(charCount, maxCount) =>
      "你已超出最大系统提示词上限，多余部分将会被截断，请增大模型上下文或者精简提示词${charCount}/${maxCount}";

  static String m12(provider) => " 确定删除提供商${provider}吗？\\n 一切记录和Key都会被一同删除";

  static String m13(num) => "选择了${num}个Agent";

  static String m14(token) => "内建提示词（${token}Tokens）";

  static String m15(token) => "系统提示词（${token}Tokens）";

  static String m16(token) => "可用于对话的Token：${token}";

  static String m17(lim) => "总上下文上限：${lim}";

  static String m18(type) => "类型:${type}";

  static String m19(token) => "UI交互提示词（${token}Tokens）";

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
    "add_model": MessageLookupByLibrary.simpleMessage("添加模型"),
    "add_model_hint": MessageLookupByLibrary.simpleMessage("暂无模型\n请点击右下角+按钮添加"),
    "add_other_provider": MessageLookupByLibrary.simpleMessage("添加其他提供商"),
    "add_persona": MessageLookupByLibrary.simpleMessage("添加人格"),
    "add_provider": MessageLookupByLibrary.simpleMessage("添加提供商"),
    "add_ver_flag": MessageLookupByLibrary.simpleMessage("添加版本号"),
    "advance_settings": MessageLookupByLibrary.simpleMessage("高级设置"),
    "agentEx": MessageLookupByLibrary.simpleMessage("Agent系统错误"),
    "agentEx_agentNotFound": MessageLookupByLibrary.simpleMessage("Agent 未找到"),
    "agentEx_agentNotLoaded": MessageLookupByLibrary.simpleMessage(
      "Agent 未被加载",
    ),
    "agentEx_failLoading_parse_error": MessageLookupByLibrary.simpleMessage(
      "Agent的数据无法被解析",
    ),
    "agentEx_recursive_call": MessageLookupByLibrary.simpleMessage("加载Agent"),
    "agentEx_unknownError": MessageLookupByLibrary.simpleMessage("未知错误"),
    "agent_delete_confirm": MessageLookupByLibrary.simpleMessage(
      "确定要删除此Agent吗？\n 删除后所有和此Agent关联的聊天记录将会一并删除",
    ),
    "agent_desc_hint": MessageLookupByLibrary.simpleMessage("请输入Agent描述"),
    "agent_manage": MessageLookupByLibrary.simpleMessage("Agent管理"),
    "agent_name_hint": MessageLookupByLibrary.simpleMessage("请给Agent起名"),
    "agent_sets": MessageLookupByLibrary.simpleMessage("Agent设置"),
    "ai": MessageLookupByLibrary.simpleMessage("AI"),
    "any": MessageLookupByLibrary.simpleMessage("任何人"),
    "apiEx": MessageLookupByLibrary.simpleMessage("API 错误"),
    "apiEx_apikey_noAvailableKeys": MessageLookupByLibrary.simpleMessage(
      "没有可用的API密钥",
    ),
    "apiEx_modelNotAvailableForProvider": MessageLookupByLibrary.simpleMessage(
      "提供商不提供该模型",
    ),
    "apiEx_modelNotFound": MessageLookupByLibrary.simpleMessage("模型未找到"),
    "apiEx_providerNotFound": MessageLookupByLibrary.simpleMessage("提供商未找到"),
    "apiEx_recursive_call": MessageLookupByLibrary.simpleMessage("调用Api"),
    "apiEx_request_apiFail": MessageLookupByLibrary.simpleMessage(
      "Api返回了一个错误响应",
    ),
    "apiEx_request_badRequest": MessageLookupByLibrary.simpleMessage("请求错误"),
    "apiEx_request_emptyBody": MessageLookupByLibrary.simpleMessage(
      "Api返回了一个空响应",
    ),
    "apiEx_request_other": MessageLookupByLibrary.simpleMessage("API发生错误"),
    "apiEx_request_timeout": MessageLookupByLibrary.simpleMessage("请求超时"),
    "apiEx_unknownError": MessageLookupByLibrary.simpleMessage("未知错误"),
    "api_key": MessageLookupByLibrary.simpleMessage("API密钥"),
    "api_key_set": MessageLookupByLibrary.simpleMessage("API密钥已设置"),
    "api_key_total": m0,
    "api_keys_configure": MessageLookupByLibrary.simpleMessage("API密钥配置"),
    "api_keys_configured": m1,
    "api_keys_not_set": MessageLookupByLibrary.simpleMessage("未配置密钥"),
    "api_settings": MessageLookupByLibrary.simpleMessage("API设置"),
    "api_type": MessageLookupByLibrary.simpleMessage("API类型"),
    "audio": MessageLookupByLibrary.simpleMessage("音频"),
    "auto_index_rules_1": MessageLookupByLibrary.simpleMessage("当和"),
    "auto_index_rules_2": MessageLookupByLibrary.simpleMessage("的聊天中满足"),
    "auto_index_rules_3": MessageLookupByLibrary.simpleMessage("则会被索引"),
    "auto_index_rules_set": MessageLookupByLibrary.simpleMessage("自动索引规则设定"),
    "auto_shrink_large_panel": MessageLookupByLibrary.simpleMessage("自动缩小大面板"),
    "avatar_change_hint": MessageLookupByLibrary.simpleMessage("点击或拖拽新图片来更换头像"),
    "base_stat_OK": MessageLookupByLibrary.simpleMessage("可用"),
    "base_stat_PENDING": MessageLookupByLibrary.simpleMessage("检查中"),
    "base_stat_processing": MessageLookupByLibrary.simpleMessage("处理中"),
    "basic_configure": MessageLookupByLibrary.simpleMessage("基础配置"),
    "cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "cancel_long_press": MessageLookupByLibrary.simpleMessage("取消（长按）"),
    "chat": MessageLookupByLibrary.simpleMessage("聊天"),
    "chatEx": MessageLookupByLibrary.simpleMessage("聊天系统错误"),
    "chatEx_failToGenerateTitle": MessageLookupByLibrary.simpleMessage(
      "自动生成标题失败",
    ),
    "chatEx_failToSaveMessage": MessageLookupByLibrary.simpleMessage(
      "储存聊天消息失败",
    ),
    "chatEx_messageNotFound": MessageLookupByLibrary.simpleMessage("该会话无消息"),
    "chatEx_recursive_call": MessageLookupByLibrary.simpleMessage("聊天"),
    "chatEx_sessionNotFound": MessageLookupByLibrary.simpleMessage("未找到聊天会话"),
    "chatEx_unknownError": MessageLookupByLibrary.simpleMessage("未知错误"),
    "check_manual": MessageLookupByLibrary.simpleMessage("查看帮助文档"),
    "choose_agent_and_chat_hint": MessageLookupByLibrary.simpleMessage(
      "选择一个Agent并开始聊天吧!",
    ),
    "click_or_drop_files_here": MessageLookupByLibrary.simpleMessage(
      "点击选择或拖拽文件到此处",
    ),
    "click_upload_image": MessageLookupByLibrary.simpleMessage("点击上传图片"),
    "configure_all_set": MessageLookupByLibrary.simpleMessage("已配置完毕"),
    "configure_not_set": MessageLookupByLibrary.simpleMessage("未完成配置"),
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
    "create_new_rule": MessageLookupByLibrary.simpleMessage("创建新规则"),
    "default_index_method": MessageLookupByLibrary.simpleMessage("默认索引方式"),
    "delete": MessageLookupByLibrary.simpleMessage("删除"),
    "delete_confirm": MessageLookupByLibrary.simpleMessage("确定删除吗？"),
    "delete_long_press": MessageLookupByLibrary.simpleMessage("删除（长按）"),
    "disable": MessageLookupByLibrary.simpleMessage("禁用"),
    "drag_image_hint": MessageLookupByLibrary.simpleMessage("拖拽图片到此处"),
    "drop_files_hint": MessageLookupByLibrary.simpleMessage("在这里拖放文件"),
    "edit": MessageLookupByLibrary.simpleMessage("编辑"),
    "edit_entries": MessageLookupByLibrary.simpleMessage("编辑条目"),
    "edit_knowledge_base": MessageLookupByLibrary.simpleMessage("编辑知识库"),
    "edit_persona": MessageLookupByLibrary.simpleMessage("编辑人格"),
    "edit_provider": m2,
    "embedding": MessageLookupByLibrary.simpleMessage("嵌入模型"),
    "embedding_dimension": MessageLookupByLibrary.simpleMessage("嵌入维度"),
    "embedding_model": MessageLookupByLibrary.simpleMessage("嵌入模型"),
    "embedding_model_note": MessageLookupByLibrary.simpleMessage(
      "请注意，该模型是嵌入模型，不能用作文本生成模型。",
    ),
    "enable": MessageLookupByLibrary.simpleMessage("启用"),
    "enable_ui_interactions": MessageLookupByLibrary.simpleMessage("启用UI交互功能"),
    "endPoint_might_not_valid": MessageLookupByLibrary.simpleMessage("可能无效地址："),
    "endPoint_not_set": MessageLookupByLibrary.simpleMessage("未设置API地址"),
    "end_point": m3,
    "end_point_preview": MessageLookupByLibrary.simpleMessage("API地址预览"),
    "end_point_set": MessageLookupByLibrary.simpleMessage("端点已设置"),
    "end_point_type": MessageLookupByLibrary.simpleMessage("端点类型"),
    "end_point_type_set": MessageLookupByLibrary.simpleMessage("端点类型已设置"),
    "end_point_with_holder": m4,
    "enlarge_context_or_simplify_prompt": MessageLookupByLibrary.simpleMessage(
      "扩大模型上下文或简化提示词",
    ),
    "enter_end_point": MessageLookupByLibrary.simpleMessage("输入API端点"),
    "enter_key_word_hint": MessageLookupByLibrary.simpleMessage(
      "键入关键词用（英文逗号）分割",
    ),
    "enter_knowledge_base_description": MessageLookupByLibrary.simpleMessage(
      "输入知识库描述",
    ),
    "enter_knowledge_base_name": MessageLookupByLibrary.simpleMessage(
      "输入知识库名称",
    ),
    "enter_opening_here": MessageLookupByLibrary.simpleMessage("在这里输入开场白"),
    "enter_provider_details": MessageLookupByLibrary.simpleMessage(
      "请输入提供商详细信息",
    ),
    "enter_regex_hint": MessageLookupByLibrary.simpleMessage("键入正则表达式"),
    "enter_session_name": MessageLookupByLibrary.simpleMessage("请输入对话记录名称"),
    "enter_sys_prompt_here": MessageLookupByLibrary.simpleMessage("在这里输入系统提示词"),
    "error_occurred": MessageLookupByLibrary.simpleMessage("发生错误"),
    "error_occurred_with_error": m5,
    "ex_and": MessageLookupByLibrary.simpleMessage("并且"),
    "ex_while": m6,
    "file": MessageLookupByLibrary.simpleMessage("文件处理"),
    "file_manage": MessageLookupByLibrary.simpleMessage("文件管理"),
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
    "front_page_titleSlogan": MessageLookupByLibrary.simpleMessage("一起集思广益！"),
    "general_settings": MessageLookupByLibrary.simpleMessage("通用设置"),
    "generate_message": MessageLookupByLibrary.simpleMessage("生成消息"),
    "generate_title": MessageLookupByLibrary.simpleMessage("生成标题"),
    "generate_title_hint": MessageLookupByLibrary.simpleMessage("重新生成会覆盖旧标题"),
    "give_up_edit_confirm": MessageLookupByLibrary.simpleMessage("确定放弃编辑吗？"),
    "go_back": MessageLookupByLibrary.simpleMessage("返回"),
    "google_compatible_api": MessageLookupByLibrary.simpleMessage("谷歌兼容"),
    "got_it": MessageLookupByLibrary.simpleMessage("了解"),
    "help": MessageLookupByLibrary.simpleMessage("帮助"),
    "hide_cot": MessageLookupByLibrary.simpleMessage("隐藏思维链"),
    "hide_knowledge_base_results": MessageLookupByLibrary.simpleMessage(
      "隐藏检索结果",
    ),
    "hide_source_code": MessageLookupByLibrary.simpleMessage("隐藏源码"),
    "hover_to_see_session": MessageLookupByLibrary.simpleMessage("鼠标悬停来预览会话"),
    "image2imageGenerate": MessageLookupByLibrary.simpleMessage("图像到图像生成"),
    "imageGenerate": MessageLookupByLibrary.simpleMessage("图像生成"),
    "image_load_fail": MessageLookupByLibrary.simpleMessage("图片加载失败"),
    "index_all": MessageLookupByLibrary.simpleMessage("索引全部"),
    "index_settings": MessageLookupByLibrary.simpleMessage("索引设置"),
    "keyword_index": MessageLookupByLibrary.simpleMessage("关键词命中索引"),
    "keyword_index_hint": MessageLookupByLibrary.simpleMessage(
      "当对话中包含关键词的时候，整个内容被发送给模型",
    ),
    "keyword_match": MessageLookupByLibrary.simpleMessage("关键词命中"),
    "knowledge_base": MessageLookupByLibrary.simpleMessage("知识库"),
    "knowledge_base_and_contexts": MessageLookupByLibrary.simpleMessage(
      "知识库&上下文检索",
    ),
    "knowledge_base_tokens": m7,
    "language_select": MessageLookupByLibrary.simpleMessage("选择语言"),
    "language_settings": MessageLookupByLibrary.simpleMessage("语言设置"),
    "language_switch_restart_note": MessageLookupByLibrary.simpleMessage(
      "部分更改需要重启App来生效",
    ),
    "loading_error": m8,
    "long_press": MessageLookupByLibrary.simpleMessage("长按"),
    "longest_opening": m9,
    "memory_content": MessageLookupByLibrary.simpleMessage("记忆内容"),
    "memory_content_waring": MessageLookupByLibrary.simpleMessage(
      "没有内容的记忆不会被添加",
    ),
    "memory_manage": MessageLookupByLibrary.simpleMessage("记忆管理"),
    "memory_name": MessageLookupByLibrary.simpleMessage("记忆名称"),
    "memory_name_waring": MessageLookupByLibrary.simpleMessage(
      "没有设置名称的记忆不会被添加",
    ),
    "message_no_content": MessageLookupByLibrary.simpleMessage(
      "发生错误，模型返回了一条空消息",
    ),
    "model": MessageLookupByLibrary.simpleMessage("模型"),
    "model_ability": MessageLookupByLibrary.simpleMessage("模型能力"),
    "model_advance_properties": MessageLookupByLibrary.simpleMessage("模型高级设置"),
    "model_basic_info_pass_through_setting":
        MessageLookupByLibrary.simpleMessage("模型基础信息传递设置"),
    "model_call_name_hint": MessageLookupByLibrary.simpleMessage(
      "请输入模型调用名称（例如：qwen/qwen-7b-chat）",
    ),
    "model_configure": MessageLookupByLibrary.simpleMessage("模型配置"),
    "model_configure_not_set": MessageLookupByLibrary.simpleMessage("未配置模型"),
    "model_configured": m10,
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
    "model_not_found": MessageLookupByLibrary.simpleMessage("未找到模型,请检查输入"),
    "model_or_dimension_not_set": MessageLookupByLibrary.simpleMessage(
      "模型或嵌入维度未设置",
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
    "name_not_set": MessageLookupByLibrary.simpleMessage("未命名"),
    "new_chat_session": MessageLookupByLibrary.simpleMessage("新聊天会话"),
    "next_step": MessageLookupByLibrary.simpleMessage("下一步"),
    "no_agent": MessageLookupByLibrary.simpleMessage("暂无Agent,请添加一个"),
    "no_embedding_model": MessageLookupByLibrary.simpleMessage(
      "无模型 \n 嵌入模型和聊天模型不同，请检查你是否添加了一个嵌入模型？",
    ),
    "no_file": MessageLookupByLibrary.simpleMessage("没有文件"),
    "no_file_selected": MessageLookupByLibrary.simpleMessage("没有选择文件"),
    "no_history": MessageLookupByLibrary.simpleMessage("暂无对话历史"),
    "no_index_method_warning": MessageLookupByLibrary.simpleMessage(
      "索引方法未设置，该内容永远不会被插入到对话中",
    ),
    "no_memory": MessageLookupByLibrary.simpleMessage("没有记忆"),
    "no_message": MessageLookupByLibrary.simpleMessage("没有消息"),
    "no_model": MessageLookupByLibrary.simpleMessage("无模型"),
    "no_model_plz_add": MessageLookupByLibrary.simpleMessage(
      "没有模型，请前往API设置中添加",
    ),
    "no_persona": MessageLookupByLibrary.simpleMessage("没有人格"),
    "no_preview": MessageLookupByLibrary.simpleMessage("无预览"),
    "no_provider": MessageLookupByLibrary.simpleMessage("暂无提供商"),
    "no_results": MessageLookupByLibrary.simpleMessage("无结果"),
    "no_rules": MessageLookupByLibrary.simpleMessage("没有规则"),
    "openai_compatible_api": MessageLookupByLibrary.simpleMessage("OpenAI兼容"),
    "openai_completion_compatible_api": MessageLookupByLibrary.simpleMessage(
      "OpenAi Completion (Legacy) 兼容",
    ),
    "opening": MessageLookupByLibrary.simpleMessage("开场白"),
    "opening_set": MessageLookupByLibrary.simpleMessage("开场白设置"),
    "or_expand_window": MessageLookupByLibrary.simpleMessage("或请拉大窗口"),
    "over_maximum_context_length_hint": m11,
    "personaEX_personaNotFound": MessageLookupByLibrary.simpleMessage("人格未找到"),
    "personaEX_unknownError": MessageLookupByLibrary.simpleMessage("未知错误"),
    "personaEx": MessageLookupByLibrary.simpleMessage("人格系统错误"),
    "personaEx_failLoading_parse_error": MessageLookupByLibrary.simpleMessage(
      "人格数据无法被解析",
    ),
    "personaEx_recursive_call": MessageLookupByLibrary.simpleMessage("加载新人格"),
    "persona_additonal_information": MessageLookupByLibrary.simpleMessage(
      "额外人格信息",
    ),
    "persona_description_hint": MessageLookupByLibrary.simpleMessage("请介绍一下自己"),
    "plz_enter": MessageLookupByLibrary.simpleMessage("请输入"),
    "plz_enter_a_number_bigger_than_zero": MessageLookupByLibrary.simpleMessage(
      "请输入正数",
    ),
    "plz_enter_content": MessageLookupByLibrary.simpleMessage("请输入内容"),
    "plz_enter_description": MessageLookupByLibrary.simpleMessage("请输入描述"),
    "plz_enter_digit": MessageLookupByLibrary.simpleMessage("请输入数字"),
    "plz_enter_name": MessageLookupByLibrary.simpleMessage("请输入名称"),
    "plz_fill_model_call_name": MessageLookupByLibrary.simpleMessage(
      "请填写模型调用名",
    ),
    "plz_select_agent": MessageLookupByLibrary.simpleMessage("请选择Agent"),
    "plz_select_embedding_dimension": MessageLookupByLibrary.simpleMessage(
      "请选择嵌入维度",
    ),
    "plz_select_persona": MessageLookupByLibrary.simpleMessage("请选择人格"),
    "plz_select_provider": MessageLookupByLibrary.simpleMessage("请选择提供商"),
    "preferences": MessageLookupByLibrary.simpleMessage("设置"),
    "pres_penalty": MessageLookupByLibrary.simpleMessage("存在惩罚"),
    "preview_session": MessageLookupByLibrary.simpleMessage("预览会话"),
    "previous_step": MessageLookupByLibrary.simpleMessage("上一步"),
    "provider_delete_warning": m12,
    "provider_select": MessageLookupByLibrary.simpleMessage("提供商选择"),
    "quit": MessageLookupByLibrary.simpleMessage("退出"),
    "reasoned": MessageLookupByLibrary.simpleMessage("思考了一会儿"),
    "reasoning": MessageLookupByLibrary.simpleMessage("正在思考..."),
    "regex_index": MessageLookupByLibrary.simpleMessage("正则索引"),
    "regex_index_hint": MessageLookupByLibrary.simpleMessage(
      "当对话中的内容匹配正则表达式时，整个内容被发送给模型",
    ),
    "regex_match": MessageLookupByLibrary.simpleMessage("正则匹配"),
    "remark": MessageLookupByLibrary.simpleMessage("备注"),
    "rename": MessageLookupByLibrary.simpleMessage("重命名"),
    "request_daily_limit": MessageLookupByLibrary.simpleMessage("每日请求上限"),
    "request_per_minute": MessageLookupByLibrary.simpleMessage("每分钟请求数"),
    "retry": MessageLookupByLibrary.simpleMessage("重试"),
    "save": MessageLookupByLibrary.simpleMessage("保存"),
    "search_any_chat_message": MessageLookupByLibrary.simpleMessage("搜索任何聊天内容"),
    "search_for_models": MessageLookupByLibrary.simpleMessage("搜索模型"),
    "search_provider": MessageLookupByLibrary.simpleMessage("搜索提供商"),
    "searched_knowledge_base": MessageLookupByLibrary.simpleMessage("检索了知识库"),
    "searching_knowledge_base": MessageLookupByLibrary.simpleMessage(
      "正在检索知识库...",
    ),
    "select_agent": MessageLookupByLibrary.simpleMessage("选择Agent"),
    "select_agent_default_persona": MessageLookupByLibrary.simpleMessage(
      "使用Agent时的默认人格",
    ),
    "select_api_type": MessageLookupByLibrary.simpleMessage("选择API类型"),
    "select_image_hint": MessageLookupByLibrary.simpleMessage("拖拽或单击选择图片"),
    "select_model_hint": MessageLookupByLibrary.simpleMessage("选择一个模型"),
    "select_or_add_memory": MessageLookupByLibrary.simpleMessage("选择或添加记忆"),
    "select_provider": MessageLookupByLibrary.simpleMessage("选择提供商"),
    "selected_agent": m13,
    "send_a_message_hint": MessageLookupByLibrary.simpleMessage("发送一条消息"),
    "set_as_default": MessageLookupByLibrary.simpleMessage("设为默认"),
    "setup_add_agent": MessageLookupByLibrary.simpleMessage("接着，我们来添加一个Agent"),
    "setup_add_agent_hint": MessageLookupByLibrary.simpleMessage(
      "Agent是一个高度自定义的聊天机器人，\\n 通过UNIChat强大的Agent系统，不论是代码大师还是可爱猫娘，随你定义",
    ),
    "setup_add_persona": MessageLookupByLibrary.simpleMessage(
      "在添加API之后，让我们添加一个人格",
    ),
    "setup_add_persona_hint": MessageLookupByLibrary.simpleMessage(
      "人格向AI描述了你，你可以填写最真实的自己 \\n 当然也可以让AI把你当成 “主人”:-D",
    ),
    "setup_agent_hint": MessageLookupByLibrary.simpleMessage("添加一个Agent"),
    "setup_api_prepared": MessageLookupByLibrary.simpleMessage(
      "我已经准备好API和APIKey了",
    ),
    "setup_finished": MessageLookupByLibrary.simpleMessage("一切皆已就绪！"),
    "setup_finished_btn": MessageLookupByLibrary.simpleMessage(
      "解锁全新的AI使用体验 ->",
    ),
    "setup_persona": MessageLookupByLibrary.simpleMessage("创建一个人格"),
    "setup_pre_warn_content": MessageLookupByLibrary.simpleMessage(
      "# UNIChat 软件开发告示\n\n**致 UNIChat 的所有用户：**\n\n感谢您对 UNIChat 的关注和试用！\n\nUNIChat 目前正处于**早期 Alpha 版本**阶段，这意味着软件尚未完全开发完成，仍有大量功能在规划和实现中。请您在使用过程中注意以下几点：\n\n---\n\n### 1. ⚠️ 版本状态与数据风险\n\n1.  **功能未完善：** 许多核心功能可能尚未实现，或者存在不完整、不稳定、体验不佳的情况。\n2.  **数据结构变动风险：** 由于软件处于快速迭代期，我们**不保证**未来数据结构不会发生重大变化。因此，**当前版本中的用户数据（例如聊天记录、设置等）可能在后续更新中无法继承或兼容。** 请您知悉并谨慎对待重要数据的存储。\n\n### 2. 🐛 问题反馈与支持\n\n如果您在使用中遇到任何 Bug 或问题，我们非常欢迎您通过以下方式向我们反馈：\n\n* 在我们的 **GitHub 仓库**上提交 **Issue**。\n* 发送电子邮件至 **[请在此处插入您的 Email 地址]**。\n\n### 3. 📖 查阅文档与提问的艺术\n\n我们致力于提供清晰的文档，并鼓励高质量的交流：\n\n* **先查文档：** 在提问或反馈之前，请优先查阅项目的**官方文档**： [请在此处插入文档链接]，许多基础问题可能已有解答。\n* **提问的艺术：** 如果您决定提问或提交 Issue，为了能让我们更高效地解决问题，请遵循以下原则：\n    1.  **描述清晰：** 明确说明您遇到的问题、期望的行为、以及实际发生的情况。\n    2.  **提供步骤：** 给出重现问题的**详细步骤**（“如何操作会导致这个错误”）。\n    3.  **附带环境信息：** 提供您的操作系统、软件版本号等相关环境信息。\n\n### 4. 🌐 开源与贡献\n\nUNIChat 是一个**遵守 Apache License 2.0 开源协议**的项目。\n\n我们热烈欢迎所有开发者查看、学习和使用我们的代码。如果您有兴趣为 UNIChat 做出贡献，无论是代码改进、文档翻译还是功能实现，我们都欢迎您提交 **Pull Request**！\n\n---\n\n**致谢：** 您的早期使用和反馈对我们至关重要。感谢您的耐心和支持，期待 UNIChat 正式发布！",
    ),
    "setup_pre_warning": MessageLookupByLibrary.simpleMessage("在开始之前，请先注意："),
    "setup_provider_add": MessageLookupByLibrary.simpleMessage("让我们先添加提供商"),
    "setup_provider_add_hint": MessageLookupByLibrary.simpleMessage(
      "你可以查看右边的教程来了解为什么需要以及如何添加",
    ),
    "setup_start": MessageLookupByLibrary.simpleMessage("开始设置"),
    "show_cot": MessageLookupByLibrary.simpleMessage("显示思维链"),
    "show_knowledge_base_results": MessageLookupByLibrary.simpleMessage(
      "查看检索结果",
    ),
    "show_source_code": MessageLookupByLibrary.simpleMessage("显示源码"),
    "skip": MessageLookupByLibrary.simpleMessage("跳过"),
    "slogan": MessageLookupByLibrary.simpleMessage("开源的AI Agent和知识库集成聊天软件"),
    "star_github": MessageLookupByLibrary.simpleMessage(
      "能给我们的GitHub项目点个Star吗？ 求你了(≧∇≦)",
    ),
    "start_conversation_with_selected_agent":
        MessageLookupByLibrary.simpleMessage("与所选Agent开始新对话"),
    "support_formats": MessageLookupByLibrary.simpleMessage(
      "支持md,docx,csv,txt,json,html",
    ),
    "supports_files_api": MessageLookupByLibrary.simpleMessage("是否支持文件API"),
    "swipe_right_to_see_session": MessageLookupByLibrary.simpleMessage(
      "向右滑动条目预览会话",
    ),
    "switch_persona": MessageLookupByLibrary.simpleMessage("切换人格"),
    "sys_prompt": MessageLookupByLibrary.simpleMessage("系统提示词"),
    "system_internal_prompt": m14,
    "system_prompt_tokens": m15,
    "temperature": MessageLookupByLibrary.simpleMessage("温度"),
    "textGenerate": MessageLookupByLibrary.simpleMessage("文本生成"),
    "title": MessageLookupByLibrary.simpleMessage("UNIChat 通聊"),
    "toggle_session_selector": MessageLookupByLibrary.simpleMessage(
      "打开会话选择器菜单",
    ),
    "token_available_for_chat": m16,
    "token_daily_limit": MessageLookupByLibrary.simpleMessage("每日Token上限"),
    "top_p": MessageLookupByLibrary.simpleMessage("Top P"),
    "total_context_lim": m17,
    "type_with_holder": m18,
    "ui_edited": MessageLookupByLibrary.simpleMessage("编辑了UI"),
    "ui_editing": MessageLookupByLibrary.simpleMessage("正在编辑UI..."),
    "ui_interaction_set": MessageLookupByLibrary.simpleMessage("UI交互(BETA)设置"),
    "ui_interactions": MessageLookupByLibrary.simpleMessage("UI操作"),
    "ui_interactions_tokens": m19,
    "unknown": MessageLookupByLibrary.simpleMessage("未知"),
    "unsupported_format": MessageLookupByLibrary.simpleMessage("不支持的文件格式"),
    "user": MessageLookupByLibrary.simpleMessage("用户"),
    "usr_persona_set": MessageLookupByLibrary.simpleMessage("用户身份设置"),
    "valid": MessageLookupByLibrary.simpleMessage("有效"),
    "vec_index_hint": MessageLookupByLibrary.simpleMessage(
      "搜索和输入最相似的内容的片段并发送给模型",
    ),
    "vector_index": MessageLookupByLibrary.simpleMessage("向量索引"),
    "video": MessageLookupByLibrary.simpleMessage("视频"),
    "view_all_provider_provide_model": MessageLookupByLibrary.simpleMessage(
      "查看所有提供此模型的提供者",
    ),
    "visual": MessageLookupByLibrary.simpleMessage("视觉理解"),
    "website_manage": MessageLookupByLibrary.simpleMessage("网站管理"),
    "window_too_small_to_display_allPanels":
        MessageLookupByLibrary.simpleMessage("窗口过小，无法显示所有面板"),
  };
}
