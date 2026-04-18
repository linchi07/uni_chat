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

  static String m0(count) => "添加${count}个模型";

  static String m1(count) => "所有可用的 ${count} 个 API Key 均请求失败，点击查看详情";

  static String m2(apiKey) => "共${apiKey}个Key";

  static String m3(num) => "共${num}个密钥已配置";

  static String m4(branch) => "分支自：${branch}";

  static String m5(branch) => "派生分支:${branch}";

  static String m6(dbName, from, to) =>
      "${dbName}发生降级：试图使用旧版本(${to})的应用打开高版本(${from})的数据库";

  static String m7(provider) => "编辑提供商：${provider}";

  static String m8(email) => "电子邮箱：${email}";

  static String m9(endPoint) => "端点";

  static String m10(endPoint) => "端点：${endPoint}";

  static String m11(error) => "发生错误:${error}";

  static String m12(condition) => "在${condition}时";

  static String m13(token) => "知识库（${token}Tokens）";

  static String m14(errorContent) => "加载错误${errorContent}";

  static String m15(error) => "读取日志失败: ${error}";

  static String m16(token) => "最长的开场白（${token}Tokens）";

  static String m17(percent) => "${percent}% 相关";

  static String m18(num) => "已配置${num}个模型";

  static String m19(charCount, maxCount) =>
      "你已超出最大系统提示词上限，多余部分将会被截断，请增大模型上下文或者精简提示词${charCount}/${maxCount}";

  static String m20(provider) => " 确定删除提供商${provider}吗？\\n 一切记录和Key都会被一同删除";

  static String m21(agent) => "将所选模型设置为\"${agent}\"的默认模型？";

  static String m22(num) => "选择了${num}个Agent";

  static String m23(token) => "内建提示词（${token}Tokens）";

  static String m24(token) => "系统提示词（${token}Tokens）";

  static String m25(token) => "可用于对话的Token：${token}";

  static String m26(lim) => "总上下文上限：${lim}";

  static String m27(type) => "类型:${type}";

  static String m28(token) => "UI交互提示词（${token}Tokens）";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "API_settings": MessageLookupByLibrary.simpleMessage("API设置"),
    "DEFAULT": MessageLookupByLibrary.simpleMessage("默认"),
    "abandon_and_exit": MessageLookupByLibrary.simpleMessage("放弃并退出"),
    "abandon_match_subtitle": MessageLookupByLibrary.simpleMessage(
      "尚未保存的匹配结果将会丢失。",
    ),
    "abandon_match_title": MessageLookupByLibrary.simpleMessage(
      "确定要放弃本次模型匹配吗？",
    ),
    "about": MessageLookupByLibrary.simpleMessage("关于"),
    "add": MessageLookupByLibrary.simpleMessage("添加"),
    "add_api_key": MessageLookupByLibrary.simpleMessage("添加API密钥"),
    "add_api_key_hint": MessageLookupByLibrary.simpleMessage(
      "暂无 API 密钥 \n 请点击右下角+按钮添加",
    ),
    "add_confirmed_models": m0,
    "add_entries": MessageLookupByLibrary.simpleMessage("添加条目"),
    "add_model": MessageLookupByLibrary.simpleMessage("添加模型"),
    "add_model_hint": MessageLookupByLibrary.simpleMessage("暂无模型\n请点击右下角+按钮添加"),
    "add_other_provider": MessageLookupByLibrary.simpleMessage("添加其他提供商"),
    "add_parameter": MessageLookupByLibrary.simpleMessage("添加参数"),
    "add_persona": MessageLookupByLibrary.simpleMessage("添加人格"),
    "add_provider": MessageLookupByLibrary.simpleMessage("添加提供商"),
    "add_ver_flag": MessageLookupByLibrary.simpleMessage("添加版本号"),
    "advance_settings": MessageLookupByLibrary.simpleMessage("高级设置"),
    "agent": MessageLookupByLibrary.simpleMessage("助手"),
    "agentEx": MessageLookupByLibrary.simpleMessage("Agent 错误"),
    "agentEx_agentNotFound": MessageLookupByLibrary.simpleMessage("Agent 未找到"),
    "agentEx_agentNotLoaded": MessageLookupByLibrary.simpleMessage(
      "Agent 未被加载",
    ),
    "agentEx_failLoading_parse_error": MessageLookupByLibrary.simpleMessage(
      "Agent数据损坏或解析失败",
    ),
    "agentEx_recursive_call": MessageLookupByLibrary.simpleMessage("加载Agent"),
    "agentEx_unknownError": MessageLookupByLibrary.simpleMessage("未知错误"),
    "agentEx_versionMismatch": MessageLookupByLibrary.simpleMessage(
      "核心组件版本不匹配，请升级应用",
    ),
    "agent_delete_confirm": MessageLookupByLibrary.simpleMessage(
      "确定要删除此Agent吗？\n 删除后所有和此Agent关联的聊天记录将会一并删除",
    ),
    "agent_desc_hint": MessageLookupByLibrary.simpleMessage("请输入Agent描述"),
    "agent_manage": MessageLookupByLibrary.simpleMessage("Agent管理"),
    "agent_name_hint": MessageLookupByLibrary.simpleMessage("请给Agent起名"),
    "agent_override_editing_hint": MessageLookupByLibrary.simpleMessage(
      "正在编辑该会话的覆盖配置。保存后仅对当前会话生效，不影响 Agent 的全局设置。",
    ),
    "agent_override_title": MessageLookupByLibrary.simpleMessage("会话 Agent 覆盖"),
    "agent_sets": MessageLookupByLibrary.simpleMessage("Agent设置"),
    "ai": MessageLookupByLibrary.simpleMessage("AI"),
    "all_rights_reserved": MessageLookupByLibrary.simpleMessage(
      "版权所有 © 2026 LinChi 保留所有权利。",
    ),
    "any": MessageLookupByLibrary.simpleMessage("任何人"),
    "apiEx": MessageLookupByLibrary.simpleMessage("API 错误"),
    "apiEx_apikey_noAvailableKeys": MessageLookupByLibrary.simpleMessage(
      "没有可用的API密钥",
    ),
    "apiEx_apikey_noAvailableKeys_detailed": m1,
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
    "api_key_exhausted_subtitle": MessageLookupByLibrary.simpleMessage(
      "在这一轮请求中，所有可用的 Key 均请求失败：",
    ),
    "api_key_exhausted_title": MessageLookupByLibrary.simpleMessage(
      "API Key 状态报告",
    ),
    "api_key_set": MessageLookupByLibrary.simpleMessage("API密钥已设置"),
    "api_key_total": m2,
    "api_keys_configure": MessageLookupByLibrary.simpleMessage("API密钥配置"),
    "api_keys_configured": m3,
    "api_keys_not_set": MessageLookupByLibrary.simpleMessage("未配置密钥"),
    "api_settings": MessageLookupByLibrary.simpleMessage("API设置"),
    "api_type": MessageLookupByLibrary.simpleMessage("API类型"),
    "audio": MessageLookupByLibrary.simpleMessage("音频"),
    "auto_fetch_models": MessageLookupByLibrary.simpleMessage("自动获取模型"),
    "auto_index_rules_1": MessageLookupByLibrary.simpleMessage("当和"),
    "auto_index_rules_2": MessageLookupByLibrary.simpleMessage("的聊天中满足"),
    "auto_index_rules_3": MessageLookupByLibrary.simpleMessage("则会被索引"),
    "auto_index_rules_set": MessageLookupByLibrary.simpleMessage("自动索引规则设定"),
    "auto_shrink_large_panel": MessageLookupByLibrary.simpleMessage("自动缩小大面板"),
    "avatar_change_hint": MessageLookupByLibrary.simpleMessage("点击或拖拽新图片来更换头像"),
    "back": MessageLookupByLibrary.simpleMessage("返回"),
    "base_stat_OK": MessageLookupByLibrary.simpleMessage("可用"),
    "base_stat_PENDING": MessageLookupByLibrary.simpleMessage("检查中"),
    "base_stat_processing": MessageLookupByLibrary.simpleMessage("处理中"),
    "basic_configure": MessageLookupByLibrary.simpleMessage("基础配置"),
    "branch_confirm": MessageLookupByLibrary.simpleMessage("创建分支"),
    "branch_from_here": MessageLookupByLibrary.simpleMessage("从此处创建分支"),
    "branched_from": m4,
    "branches": m5,
    "cache_price_per_1k": MessageLookupByLibrary.simpleMessage(
      "缓存读取价格 (每 1M tokens)",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "cancel_long_press": MessageLookupByLibrary.simpleMessage("取消（长按）"),
    "chat": MessageLookupByLibrary.simpleMessage("聊天"),
    "chatEx": MessageLookupByLibrary.simpleMessage("聊天系统错误"),
    "chatEx_failParsingMessage": MessageLookupByLibrary.simpleMessage(
      "解析聊天消息失败",
    ),
    "chatEx_failToGenerateTitle": MessageLookupByLibrary.simpleMessage(
      "自动生成标题失败",
    ),
    "chatEx_failToSaveMessage": MessageLookupByLibrary.simpleMessage(
      "储存聊天消息失败",
    ),
    "chatEx_messageNotFound": MessageLookupByLibrary.simpleMessage("该会话无消息"),
    "chatEx_modelNotSupportFileType": MessageLookupByLibrary.simpleMessage(
      "模型不支持这类文件",
    ),
    "chatEx_recursive_call": MessageLookupByLibrary.simpleMessage("聊天"),
    "chatEx_sessionNotFound": MessageLookupByLibrary.simpleMessage("未找到聊天会话"),
    "chatEx_unknownError": MessageLookupByLibrary.simpleMessage("未知错误"),
    "check_manual": MessageLookupByLibrary.simpleMessage("查看帮助文档"),
    "check_updates": MessageLookupByLibrary.simpleMessage("检查更新"),
    "choose_agent_and_chat_hint": MessageLookupByLibrary.simpleMessage(
      "选择一个Agent并开始聊天吧!",
    ),
    "click_or_drop_files_here": MessageLookupByLibrary.simpleMessage(
      "点击选择或拖拽文件到此处",
    ),
    "click_upload_image": MessageLookupByLibrary.simpleMessage("点击上传图片"),
    "close": MessageLookupByLibrary.simpleMessage("关闭"),
    "completion": MessageLookupByLibrary.simpleMessage("补全"),
    "completion_price_per_1k": MessageLookupByLibrary.simpleMessage(
      "Completion 价格 (每 1M tokens)",
    ),
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
    "continue_editing": MessageLookupByLibrary.simpleMessage("继续编辑"),
    "create_new_agent": MessageLookupByLibrary.simpleMessage("创建一个新Agent"),
    "create_new_model": MessageLookupByLibrary.simpleMessage("创建新模型"),
    "create_new_rule": MessageLookupByLibrary.simpleMessage("创建新规则"),
    "create_variant": MessageLookupByLibrary.simpleMessage("创建变体"),
    "currency": MessageLookupByLibrary.simpleMessage("币种"),
    "db_downgrade_content": MessageLookupByLibrary.simpleMessage(
      "如果出现该错误，说明您使用旧版本软件打开了由新版本软件创建的数据存档，这可能会导致应用闪退或数据彻底损坏。\n为了保护您的数据安全，已阻止本次启动。请先更新软件到更高版本。",
    ),
    "db_downgrade_error": m6,
    "db_downgrade_title": MessageLookupByLibrary.simpleMessage("数据库版本不兼容"),
    "default_index_method": MessageLookupByLibrary.simpleMessage("默认索引方式"),
    "delete": MessageLookupByLibrary.simpleMessage("删除"),
    "delete_confirm": MessageLookupByLibrary.simpleMessage("确定删除吗？"),
    "delete_keys_warning": MessageLookupByLibrary.simpleMessage(
      "勾选此项将删除所有现有的 API 密钥。是否继续？",
    ),
    "delete_long_press": MessageLookupByLibrary.simpleMessage("删除（长按）"),
    "disable": MessageLookupByLibrary.simpleMessage("禁用"),
    "disable_persona": MessageLookupByLibrary.simpleMessage("关闭人格系统"),
    "discard_changes": MessageLookupByLibrary.simpleMessage("丢弃更改"),
    "download": MessageLookupByLibrary.simpleMessage("前往下载"),
    "drag_image_hint": MessageLookupByLibrary.simpleMessage("拖拽图片到此处"),
    "drop_files_hint": MessageLookupByLibrary.simpleMessage("在这里拖放文件"),
    "edit": MessageLookupByLibrary.simpleMessage("编辑"),
    "edit_entries": MessageLookupByLibrary.simpleMessage("编辑条目"),
    "edit_knowledge_base": MessageLookupByLibrary.simpleMessage("编辑知识库"),
    "edit_more": MessageLookupByLibrary.simpleMessage("编辑更多"),
    "edit_persona": MessageLookupByLibrary.simpleMessage("编辑人格"),
    "edit_provider": m7,
    "email_with_holder": m8,
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
    "end_point": m9,
    "end_point_preview": MessageLookupByLibrary.simpleMessage("API地址预览"),
    "end_point_set": MessageLookupByLibrary.simpleMessage("端点已设置"),
    "end_point_type": MessageLookupByLibrary.simpleMessage("端点类型"),
    "end_point_type_set": MessageLookupByLibrary.simpleMessage("端点类型已设置"),
    "end_point_with_holder": m10,
    "enlarge_context_or_simplify_prompt": MessageLookupByLibrary.simpleMessage(
      "扩大模型上下文或简化提示词",
    ),
    "enter_cache_price": MessageLookupByLibrary.simpleMessage("请输入缓存读取价格"),
    "enter_completion_price": MessageLookupByLibrary.simpleMessage(
      "请输入 Completion 价格",
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
    "enter_prompt_price": MessageLookupByLibrary.simpleMessage("请输入 Prompt 价格"),
    "enter_provider_details": MessageLookupByLibrary.simpleMessage(
      "请输入提供商详细信息",
    ),
    "enter_regex_hint": MessageLookupByLibrary.simpleMessage("键入正则表达式"),
    "enter_session_name": MessageLookupByLibrary.simpleMessage("请输入对话记录名称"),
    "enter_sys_prompt_here": MessageLookupByLibrary.simpleMessage(
      "在这里输入系统提示词, \n 支持Markdown，键入\"/\"以打开菜单",
    ),
    "error_details": MessageLookupByLibrary.simpleMessage("错误详情"),
    "error_message": MessageLookupByLibrary.simpleMessage("错误信息"),
    "error_occurred": MessageLookupByLibrary.simpleMessage("发生错误"),
    "error_occurred_with_error": m11,
    "ex_and": MessageLookupByLibrary.simpleMessage("并且"),
    "ex_while": m12,
    "fetch_failed": MessageLookupByLibrary.simpleMessage("获取失败"),
    "fetching_models": MessageLookupByLibrary.simpleMessage("正在获取模型..."),
    "file": MessageLookupByLibrary.simpleMessage("文件处理"),
    "file_manage": MessageLookupByLibrary.simpleMessage("文件管理"),
    "fill_in_api_key": MessageLookupByLibrary.simpleMessage("填写API密钥"),
    "fill_model_call_name": MessageLookupByLibrary.simpleMessage("模型调用名"),
    "fill_reminder_null_if_blank": MessageLookupByLibrary.simpleMessage(
      "填写备注(留空默认无)",
    ),
    "finish_edit": MessageLookupByLibrary.simpleMessage("完成编辑"),
    "front_page_hintLine_char1": MessageLookupByLibrary.simpleMessage("以 "),
    "front_page_hintLine_char2": MessageLookupByLibrary.simpleMessage(" 和 "),
    "front_page_hintLine_char3": MessageLookupByLibrary.simpleMessage(" 开始聊天"),
    "front_page_titleSlogan": MessageLookupByLibrary.simpleMessage("一起集思广益！"),
    "full_settings": MessageLookupByLibrary.simpleMessage("完整设置"),
    "general_settings": MessageLookupByLibrary.simpleMessage("通用设置"),
    "generate_message": MessageLookupByLibrary.simpleMessage("生成消息"),
    "generate_title": MessageLookupByLibrary.simpleMessage("生成标题"),
    "generate_title_hint": MessageLookupByLibrary.simpleMessage("重新生成会覆盖旧标题"),
    "generating_title": MessageLookupByLibrary.simpleMessage("正在生成对话标题……"),
    "get_api_key": MessageLookupByLibrary.simpleMessage("获取 API Key"),
    "get_help": MessageLookupByLibrary.simpleMessage("获取帮助"),
    "github_repo": MessageLookupByLibrary.simpleMessage("GitHub 仓库"),
    "give_up_edit_confirm": MessageLookupByLibrary.simpleMessage("确定放弃编辑吗？"),
    "go_back": MessageLookupByLibrary.simpleMessage("返回"),
    "google_compatible_api": MessageLookupByLibrary.simpleMessage("谷歌兼容"),
    "got_it": MessageLookupByLibrary.simpleMessage("了解"),
    "help": MessageLookupByLibrary.simpleMessage("帮助"),
    "help_guides": MessageLookupByLibrary.simpleMessage("帮助与指南"),
    "help_links": MessageLookupByLibrary.simpleMessage("帮助链接"),
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
    "invalid_number": MessageLookupByLibrary.simpleMessage("请输入有效数字"),
    "keyword_index": MessageLookupByLibrary.simpleMessage("关键词命中索引"),
    "keyword_index_hint": MessageLookupByLibrary.simpleMessage(
      "当对话中包含关键词的时候，整个内容被发送给模型",
    ),
    "keyword_match": MessageLookupByLibrary.simpleMessage("关键词命中"),
    "knowledge_base": MessageLookupByLibrary.simpleMessage("知识库"),
    "knowledge_base_and_contexts": MessageLookupByLibrary.simpleMessage(
      "知识库&上下文检索",
    ),
    "knowledge_base_tokens": m13,
    "language_select": MessageLookupByLibrary.simpleMessage("选择语言"),
    "language_settings": MessageLookupByLibrary.simpleMessage("语言设置"),
    "language_switch_restart_note": MessageLookupByLibrary.simpleMessage(
      "部分更改需要重启App来生效",
    ),
    "limit_model_generate_length": MessageLookupByLibrary.simpleMessage(
      "限制模型最大生成长度",
    ),
    "loading_error": m14,
    "log_clear": MessageLookupByLibrary.simpleMessage("清空日志"),
    "log_copied_to_clipboard": MessageLookupByLibrary.simpleMessage(
      "已复制日志到剪贴板",
    ),
    "log_copy": MessageLookupByLibrary.simpleMessage("复制日志"),
    "log_enable_global_catch": MessageLookupByLibrary.simpleMessage(
      "启用全局日志捕获（重启生效部分拦截）",
    ),
    "log_enable_global_catch_hint": MessageLookupByLibrary.simpleMessage(
      "开启后，自动将控制台的输出及未捕获错误记录到本地",
    ),
    "log_file_not_init": MessageLookupByLibrary.simpleMessage("日志文件未初始化"),
    "log_loading": MessageLookupByLibrary.simpleMessage("正在加载日志..."),
    "log_none": MessageLookupByLibrary.simpleMessage("暂无日志"),
    "log_read_fail": m15,
    "log_refresh": MessageLookupByLibrary.simpleMessage("刷新日志"),
    "log_settings": MessageLookupByLibrary.simpleMessage("日志捕获"),
    "long_press": MessageLookupByLibrary.simpleMessage("长按"),
    "longest_opening": m16,
    "match_confirmed": MessageLookupByLibrary.simpleMessage("已确认"),
    "match_conflict": MessageLookupByLibrary.simpleMessage("匹配冲突"),
    "match_review_title": MessageLookupByLibrary.simpleMessage("审核模型匹配"),
    "match_similarity": m17,
    "match_suggested": MessageLookupByLibrary.simpleMessage("建议匹配"),
    "match_unsupported": MessageLookupByLibrary.simpleMessage("未匹配"),
    "matching_models": MessageLookupByLibrary.simpleMessage("正在匹配模型..."),
    "maximize": MessageLookupByLibrary.simpleMessage("最大化"),
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
    "model_breakdown": MessageLookupByLibrary.simpleMessage("模型分布"),
    "model_call_name_hint": MessageLookupByLibrary.simpleMessage(
      "请输入模型调用名称（例如：qwen/qwen-7b-chat）",
    ),
    "model_configure": MessageLookupByLibrary.simpleMessage("模型配置"),
    "model_configure_not_set": MessageLookupByLibrary.simpleMessage("未配置模型"),
    "model_configured": m18,
    "model_context_not_enough": MessageLookupByLibrary.simpleMessage("模型上下文不足"),
    "model_delete_confirm": MessageLookupByLibrary.simpleMessage(
      "确定要删除此模型吗？\n 删除后所有提供此模型的提供者将无法使用此模型。",
    ),
    "model_family": MessageLookupByLibrary.simpleMessage("模型家族"),
    "model_family_hint": MessageLookupByLibrary.simpleMessage(
      "请输入模型家族（例如：qwen3）",
    ),
    "model_friendly_name": MessageLookupByLibrary.simpleMessage("模型友好名称"),
    "model_friendly_name_exists": MessageLookupByLibrary.simpleMessage(
      "友好名称已存在",
    ),
    "model_friendly_name_hint": MessageLookupByLibrary.simpleMessage(
      "请输入模型友好名称（例如：Qwen 7B）",
    ),
    "model_list": MessageLookupByLibrary.simpleMessage("支持模型列表"),
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
    "model_param_frequency_penalty": MessageLookupByLibrary.simpleMessage(
      "频率惩罚",
    ),
    "model_param_include_reasoning": MessageLookupByLibrary.simpleMessage(
      "包含推理过程",
    ),
    "model_param_logit_bias": MessageLookupByLibrary.simpleMessage("Logit 偏置"),
    "model_param_max_tokens": MessageLookupByLibrary.simpleMessage(
      "最大补全 Token 数",
    ),
    "model_param_min_p": MessageLookupByLibrary.simpleMessage("Min P"),
    "model_param_presence_penalty": MessageLookupByLibrary.simpleMessage(
      "存在惩罚",
    ),
    "model_param_reasoning": MessageLookupByLibrary.simpleMessage("推理"),
    "model_param_repetition_penalty": MessageLookupByLibrary.simpleMessage(
      "重复惩罚",
    ),
    "model_param_response_format": MessageLookupByLibrary.simpleMessage("响应格式"),
    "model_param_seed": MessageLookupByLibrary.simpleMessage("随机种子"),
    "model_param_stop": MessageLookupByLibrary.simpleMessage("停止序列"),
    "model_param_structured_outputs": MessageLookupByLibrary.simpleMessage(
      "结构化输出",
    ),
    "model_param_temperature": MessageLookupByLibrary.simpleMessage("温度"),
    "model_param_tool_choice": MessageLookupByLibrary.simpleMessage("工具选择"),
    "model_param_tools": MessageLookupByLibrary.simpleMessage("工具列表"),
    "model_param_top_a": MessageLookupByLibrary.simpleMessage("Top A"),
    "model_param_top_k": MessageLookupByLibrary.simpleMessage("Top K"),
    "model_param_top_p": MessageLookupByLibrary.simpleMessage("Top P"),
    "model_pricing_settings": MessageLookupByLibrary.simpleMessage("模型计价设置"),
    "model_property": MessageLookupByLibrary.simpleMessage("模型属性设置"),
    "model_select": MessageLookupByLibrary.simpleMessage("模型选择"),
    "model_sets": MessageLookupByLibrary.simpleMessage("模型设置"),
    "model_system_telling": MessageLookupByLibrary.simpleMessage(
      "告知模型当前操作系统（如：macos Sonoma）",
    ),
    "model_time_telling": MessageLookupByLibrary.simpleMessage("告知模型当前系统时间"),
    "model_unavailable": MessageLookupByLibrary.simpleMessage(
      "当前模型不可用，请重新选择模型",
    ),
    "modify_session_name": MessageLookupByLibrary.simpleMessage("修改对话记录名称"),
    "my_api_no_key": MessageLookupByLibrary.simpleMessage("我的 API 不需要 API Key"),
    "name": MessageLookupByLibrary.simpleMessage("名称"),
    "name_new_branch": MessageLookupByLibrary.simpleMessage("为新分支命名"),
    "name_not_set": MessageLookupByLibrary.simpleMessage("未命名"),
    "new_chat_session": MessageLookupByLibrary.simpleMessage("新聊天会话"),
    "new_version_available": MessageLookupByLibrary.simpleMessage("发现新版本"),
    "next_step": MessageLookupByLibrary.simpleMessage("下一步"),
    "no_agent": MessageLookupByLibrary.simpleMessage("暂无Agent,请添加一个"),
    "no_api_key_added_warning": MessageLookupByLibrary.simpleMessage(
      "请先添加 API Key 或勾选“无需密钥”。",
    ),
    "no_data_period": MessageLookupByLibrary.simpleMessage("该时间段内无数据"),
    "no_embedding_model": MessageLookupByLibrary.simpleMessage(
      "无模型 \n 嵌入模型和聊天模型不同，请检查你是否添加了一个嵌入模型？",
    ),
    "no_file": MessageLookupByLibrary.simpleMessage("没有文件"),
    "no_file_selected": MessageLookupByLibrary.simpleMessage("没有选择文件"),
    "no_history": MessageLookupByLibrary.simpleMessage("暂无对话历史"),
    "no_index_method_warning": MessageLookupByLibrary.simpleMessage(
      "索引方法未设置，该内容永远不会被插入到对话中",
    ),
    "no_key_needed": MessageLookupByLibrary.simpleMessage("无需 API Key"),
    "no_limit": MessageLookupByLibrary.simpleMessage("不限制"),
    "no_memory": MessageLookupByLibrary.simpleMessage("没有记忆"),
    "no_message": MessageLookupByLibrary.simpleMessage("没有消息"),
    "no_model": MessageLookupByLibrary.simpleMessage("无模型"),
    "no_model_plz_add": MessageLookupByLibrary.simpleMessage(
      "没有模型，请前往API设置中添加",
    ),
    "no_models_found": MessageLookupByLibrary.simpleMessage(
      "未发现任何模型，请检查 API 配置或端点是否正确。",
    ),
    "no_persona": MessageLookupByLibrary.simpleMessage("没有人格"),
    "no_pop_out_announcement": MessageLookupByLibrary.simpleMessage("不再弹出此公告"),
    "no_preview": MessageLookupByLibrary.simpleMessage("无预览"),
    "no_provider": MessageLookupByLibrary.simpleMessage("暂无提供商"),
    "no_results": MessageLookupByLibrary.simpleMessage("无结果"),
    "no_rules": MessageLookupByLibrary.simpleMessage("没有规则"),
    "official_website": MessageLookupByLibrary.simpleMessage("官方网站"),
    "openai_compatible_api": MessageLookupByLibrary.simpleMessage("OpenAI兼容"),
    "openai_completion_compatible_api": MessageLookupByLibrary.simpleMessage(
      "OpenAi Completion (Legacy) 兼容",
    ),
    "opening": MessageLookupByLibrary.simpleMessage("开场白"),
    "opening_configure_title": MessageLookupByLibrary.simpleMessage("开场白配置"),
    "opening_message_hint": MessageLookupByLibrary.simpleMessage(
      "开启新对话时 Agent 自动发送的消息 (支持 markdown)",
    ),
    "opening_message_label": MessageLookupByLibrary.simpleMessage("自动欢迎语"),
    "opening_set": MessageLookupByLibrary.simpleMessage("开场白设置"),
    "opening_slogan_hint": MessageLookupByLibrary.simpleMessage(
      "在无会话时显示的自定义标语",
    ),
    "opening_slogan_label": MessageLookupByLibrary.simpleMessage("自定义标语"),
    "or_expand_window": MessageLookupByLibrary.simpleMessage("或请拉大窗口"),
    "over_maximum_context_length_hint": m19,
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
    "persona_system_disabled": MessageLookupByLibrary.simpleMessage("人格系统已关闭"),
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
    "preview_session": MessageLookupByLibrary.simpleMessage("预览会话"),
    "previous_step": MessageLookupByLibrary.simpleMessage("上一步"),
    "price_not_empty": MessageLookupByLibrary.simpleMessage("价格不能为空"),
    "prompt": MessageLookupByLibrary.simpleMessage("提示词"),
    "prompt_price_per_1k": MessageLookupByLibrary.simpleMessage(
      "Prompt 价格 (每 1M tokens)",
    ),
    "provider_delete_warning": m20,
    "provider_select": MessageLookupByLibrary.simpleMessage("提供商选择"),
    "quick_chat": MessageLookupByLibrary.simpleMessage("快速聊天"),
    "quick_chat_enabled": MessageLookupByLibrary.simpleMessage("已启用快速聊天"),
    "quit": MessageLookupByLibrary.simpleMessage("退出"),
    "reasoned": MessageLookupByLibrary.simpleMessage("思考了一会儿"),
    "reasoning": MessageLookupByLibrary.simpleMessage("正在思考..."),
    "regex_index": MessageLookupByLibrary.simpleMessage("正则索引"),
    "regex_index_hint": MessageLookupByLibrary.simpleMessage(
      "当对话中的内容匹配正则表达式时，整个内容被发送给模型",
    ),
    "regex_match": MessageLookupByLibrary.simpleMessage("正则匹配"),
    "related_docs": MessageLookupByLibrary.simpleMessage("相关文档"),
    "remark": MessageLookupByLibrary.simpleMessage("备注"),
    "rename": MessageLookupByLibrary.simpleMessage("重命名"),
    "request_daily_limit": MessageLookupByLibrary.simpleMessage("每日请求上限"),
    "request_per_minute": MessageLookupByLibrary.simpleMessage("每分钟请求数"),
    "restore": MessageLookupByLibrary.simpleMessage("还原"),
    "retry": MessageLookupByLibrary.simpleMessage("重试"),
    "save": MessageLookupByLibrary.simpleMessage("保存"),
    "save_and_exit": MessageLookupByLibrary.simpleMessage("保存并退出"),
    "save_to_agent_settings": m21,
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
    "select_model": MessageLookupByLibrary.simpleMessage("选择模型"),
    "select_model_hint": MessageLookupByLibrary.simpleMessage("选择一个模型"),
    "select_or_add_memory": MessageLookupByLibrary.simpleMessage("选择或添加记忆"),
    "select_parameter": MessageLookupByLibrary.simpleMessage("选择要添加的参数"),
    "select_provider": MessageLookupByLibrary.simpleMessage("选择提供商"),
    "selected_agent": m22,
    "send_a_message_hint": MessageLookupByLibrary.simpleMessage(
      "发送一条消息（支持MD）,键入\"/\"以查看更多选项",
    ),
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
      "# UNIChat 软件开发告示\n\n**致 UNIChat 的所有用户：**\n\n感谢您对 UNIChat 的关注和试用！\n\n目前 UNIChat 正在进入 **Stable (稳定版)** 迭代阶段。这标志着软件的核心功能已趋于完善，但在正式版全面发布前，我们仍需提醒您注意以下几点：\n\n---\n\n### 1. ⚠ 风险提示与稳定性\n\n虽然我们已进入稳定版阶段，但在软件迭代过程中，仍可能存在极少数极端情况下的兼容性问题。\n\n### 2. 🐞 缺陷反馈与技术支持\n\n如果您在使用中遇到任何 Bug 或异常，请务必通过以下途径告诉我们：\n\n*   在我们的 **GitHub 仓库**上提交 **Issue**。\n*   说明您的具体操作系统版本、应用版本（见设置页）以及复现步骤。\n\n### 3. 📖 提问的艺术与文档\n\n为了我们能更高效地协作，我们强烈建议您在反馈问题前：\n\n*   **查阅文档：** 优先查看项目官方文档 [https://unichat.wejoinnwk.com](https://unichat.wejoinnwk.com)，获取常见问题的解决方案。\n*   **遵循《提问的艺术》：** 高质量的反馈是解决问题的捷径。请确保您的描述清晰、无歧义。有关如何高质量提问，建议查阅[《提问的艺术》](https://github.com/ryanhanwu/How-To-Ask-Questions-The-Smart-Way/blob/main/README-zh_CN.md)。\n\n### 4. 🌐 开源共建\n\nUNIChat是一个开源项目。我们欢迎任何形式的贡献，包括代码修补、文档完善以及功能建议。\n\n---\n\n**致谢：** 您的每一份反馈都在帮助 UNIChat 变得更好。感谢您的支持！",
    ),
    "setup_pre_warning": MessageLookupByLibrary.simpleMessage("在开始之前，请先注意："),
    "setup_provider_add": MessageLookupByLibrary.simpleMessage("让我们先添加提供商"),
    "setup_provider_add_hint": MessageLookupByLibrary.simpleMessage(
      "你可以查看右边的教程来了解为什么需要以及如何添加",
    ),
    "setup_start": MessageLookupByLibrary.simpleMessage("开始设置"),
    "show_all_models": MessageLookupByLibrary.simpleMessage("显示所有模型"),
    "show_available_models": MessageLookupByLibrary.simpleMessage("显示可用模型"),
    "show_cot": MessageLookupByLibrary.simpleMessage("显示思维链"),
    "show_knowledge_base_results": MessageLookupByLibrary.simpleMessage(
      "查看检索结果",
    ),
    "show_source_code": MessageLookupByLibrary.simpleMessage("显示源码"),
    "skip": MessageLookupByLibrary.simpleMessage("跳过"),
    "slogan": MessageLookupByLibrary.simpleMessage("开源的AI Agent聊天软件"),
    "star_github": MessageLookupByLibrary.simpleMessage(
      "能给我们的GitHub项目点个Star吗？ 求你了(≧∇≦)",
    ),
    "start_conversation_with_selected_agent":
        MessageLookupByLibrary.simpleMessage("与所选Agent开始新对话"),
    "status_code": MessageLookupByLibrary.simpleMessage("状态码"),
    "support_formats": MessageLookupByLibrary.simpleMessage(
      "支持md,docx,csv,txt,json,html",
    ),
    "supports_files_api": MessageLookupByLibrary.simpleMessage("是否支持文件API"),
    "swipe_right_to_see_session": MessageLookupByLibrary.simpleMessage(
      "向右滑动条目预览会话",
    ),
    "switch_persona": MessageLookupByLibrary.simpleMessage("切换人格"),
    "sys_prompt": MessageLookupByLibrary.simpleMessage("系统提示词"),
    "system_internal_prompt": m23,
    "system_prompt_tokens": m24,
    "textGenerate": MessageLookupByLibrary.simpleMessage("文本"),
    "title": MessageLookupByLibrary.simpleMessage("UNIChat 通聊"),
    "toggle_session_selector": MessageLookupByLibrary.simpleMessage(
      "打开会话选择器菜单",
    ),
    "token_available_for_chat": m25,
    "token_daily_limit": MessageLookupByLibrary.simpleMessage("每日Token上限"),
    "token_usage": MessageLookupByLibrary.simpleMessage("Token 统计"),
    "total_context_lim": m26,
    "total_tokens": MessageLookupByLibrary.simpleMessage("总 Token"),
    "type_with_holder": m27,
    "ui_edited": MessageLookupByLibrary.simpleMessage("编辑了UI"),
    "ui_editing": MessageLookupByLibrary.simpleMessage("正在编辑UI..."),
    "ui_interaction_set": MessageLookupByLibrary.simpleMessage("UI交互(BETA)设置"),
    "ui_interactions": MessageLookupByLibrary.simpleMessage("UI操作"),
    "ui_interactions_tokens": m28,
    "unknown": MessageLookupByLibrary.simpleMessage("未知"),
    "unsaved_changes_message": MessageLookupByLibrary.simpleMessage(
      "检测到未保存的更改，是否在退出前保存？",
    ),
    "unsaved_changes_title": MessageLookupByLibrary.simpleMessage("未保存的更改"),
    "unsupported_format": MessageLookupByLibrary.simpleMessage("不支持的文件格式"),
    "usage_trend": MessageLookupByLibrary.simpleMessage("使用趋势"),
    "user": MessageLookupByLibrary.simpleMessage("用户"),
    "usr_persona_set": MessageLookupByLibrary.simpleMessage("用户身份设置"),
    "valid": MessageLookupByLibrary.simpleMessage("有效"),
    "vec_index_hint": MessageLookupByLibrary.simpleMessage(
      "搜索和输入最相似的内容的片段并发送给模型",
    ),
    "vector_index": MessageLookupByLibrary.simpleMessage("向量索引"),
    "version_preview": MessageLookupByLibrary.simpleMessage("V 1.0 Beta 预览版"),
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
