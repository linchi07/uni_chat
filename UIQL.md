UIQL (User Interface Query Language) 文档

UIQL 是一种简洁的命令式语言，旨在通过结构化的指令，实现大模型对图形用户界面的创建、修改、删除和交互绑定。它借鉴了 SQL 的简洁性，让大模型能以更直观的方式控制 UI 元素。
核心概念

UIQL 的操作基于以下核心概念：

面板 (Panel): UI 中的基本组成单元，每个面板都有一个唯一的 ID 和特定的 类型。

属性 (Property): 面板的各种可配置参数，如文本内容、数据、样式等。

动作 (Action): 用户交互（如点击按钮）触发的具名事件。

绑定 (Bind): 将一个动作与一个传递给 LLM 的提示词关联起来。

结束 (END): 和 SQL 类似，UIQL 使用 “;” 作为语句的结尾标记。并且对换行符不敏感

额外提示

关键词大小写不敏感: UIQL 中的所有关键词（如 CREATE, UPDATE, SET, WITH, AS, BIND, EXECUTE, DROP, CLEAR 等）都是大小写不敏感的。例如，CREATE 和 create 具有相同的含义，这大大提高了大模型生成指令时的容错率。

UIQL 命令块标记: 为了区分 UIQL 命令与 LLM 的普通对话，所有 UIQL 语句必须被包裹在 <UIQL> 和 </UIQL> XML 标签之间。一个 <UIQL> 块内可以包含多条以分号 ; 分隔的 UIQL 语句。
注意，由于动态解析的原因，如果你不在对ui进行操作，请勿包含UIQL的标签以免造成解析器错误的解释。

    示例:

    <UIQL>
    CREATE welcome_text AS MARKDOWN SET text="## 欢迎来到交互式应用!";
    CREATE search_btn AS BUTTON SET text="执行搜索", action="trigger_search";
    BIND trigger_search WITH "用户点击了搜索按钮。";
    </UIQL>

请注意，虽然UIQL包裹在XML标签中，但他不是XML也不应该被当作XML，标签只是为了区分命令。

！！注意！！
UIQL不支持任意形式的注释，你不应该在UIQL中使用注释，若你想要向用户说明情况，请你在<UIQL></UIQL>标记外部说明以免造成解释器致命错误。
UIQL DON'T SUPPORT COMMENTS OF ANY FORM DO NOT USE COMMENTS
禁止使用 "//"或者“*"或者”#“或者任意形式的注释，这会导致解析错误。！
DO NOT USE "//" OR "*" OR "#" OR ANY OTHER FORM OF COMMENTS
THIS IS STRICTLY FORBIDDEN
你不需要进行任何解释说明
！！请务必注意！！


标识符命名规范: UIQL 中的所有标识符（包括 panel_id、action_name、property_key、function_name 和 arg_key）必须遵循以下规则：

    必须以英文字母 (a-z, A-Z) 或下划线 (_) 开头。

    后续字符可以是英文字母 (a-z, A-Z)、数字 (0-9) 或下划线 (_)。

    不允许包含空格、连字符或任何其他特殊字符。

    并请牢记，标识符不是字符串，他们不应该被双引号包裹。

对于字符串类型，请使用以下格式：（也就是json中所使用的格式）
"这是一个示例字符串，我可以用/"来转义引号字符，或者任何需要转义的字符，利用/n来换行"

！务必注意！ 请不要用三个引号来表示字符串，这会导致解析错误。
例如 """错误的字符串内容"""
这是命令禁止的写法，会导致解析错误。

对于json类型，请务必直接使用{或者[开头，不要用引号包裹,如：
 jsonContent = {name:"这是一个json内容",list:[1,2,3]}
 jsonList = [1,2,3]

！！注意！！
UIQL不支持任意形式的注释，你不应该在UIQL中使用注释，若你想要向用户说明情况，请你在<UIQL></UIQL>标记外部说明以免造成解释器致命错误。
UIQL DON'T SUPPORT COMMENTS OF ANY FORM DO NOT USE COMMENTS
禁止使用 "//"或者“*"或者”#“或者任意形式的注释，这会导致解析错误。！
DO NOT USE "//" OR "*" OR "#" OR ANY OTHER FORM OF COMMENTS
！！！！！！！THIS IS STRICTLY FORBIDDEN！！！！！！！
LEAVE A MESSAGE ONLY IF YOU ARE OUT OF THE <UIQL></UIQL>TAG
！！请务必注意！！！

其他值得注意的编写提示：
面板与聊天的文本输出不同，面板在你主动关闭之前都会展示在ui中，因此非常适合用来向用户传达一个可能跨多轮对话的持久内容。例如一个大标题，或者你和用户一起编写的一段代码之类的。
UIQL非常适合用来进行可视化的展示，你可以借助多样的面板明确的向用户展示信息，这是一个主动的过程，你无需询问或者等待用户显式要求即可使用UIQL。
例如，如果用户要求你对比两个东西，即使他没有明确要求，你也可以使用一个雷达图面板来展示。而不是直接在聊天中输出文字。
当然UIQL的使用不仅限于此，你可以使用UIQL来展示信息，或者进行可视化展示，或者进行交互绑定，或者进行数据处理等等。
对于颜色的使用，请你尽量使用柔和的颜色。（除非用户明确要求）格式是16进制色如 FFFFFFFF
当这个文件被提供给你时，代表环境已经内建了UIQL解释器，直接输出包含<UIQL></UIQL>的UIQL代码即可被正常解析并且展示给用户。


！！注意！！
UIQL不支持任意形式的注释，你不应该在UIQL中使用注释，若你想要向用户说明情况，请你在<UIQL></UIQL>标记外部说明以免造成解释器致命错误。
UIQL DON'T SUPPORT COMMENTS OF ANY FORM DO NOT USE COMMENTS
禁止使用 "//"或者“*"或者”#“或者任意形式的注释，这会导致解析错误。！
DO NOT USE "//" OR "*" OR "#" OR ANY OTHER FORM OF COMMENTS
！！！！！！！THIS IS STRICTLY FORBIDDEN！！！！！！！
LEAVE A MESSAGE ONLY IF YOU ARE OUT OF THE <UIQL></UIQL>TAG
！！请务必注意！！！

命令语法

    CREATE (创建面板)

用于在 UI 上创建新的面板。

语法: CREATE <panel_id> AS <panel_type> SET <property_key_1>=<value_1>, <property_key_2>=<value_2>, ...;

    <panel_id>: 面板的唯一标识符。

    <panel_type>: 要创建的面板类型。例如：MARKDOWN, BUTTON, TABLE, CHART, CANVAS 等。

    SET: 关键字，后跟一系列用逗号分隔的属性键值对 注意！ set和后面的属性是可选参数，你可以留空来创建一个空白面板。

    <property_key>: 属性的名称。

    <value>: 属性的值。可以是字符串（用双引号包裹，使用转义字符例如/"来表示引号或者是换行符）、数字、布尔值（true/false）或 JSON 格式的数组/对象。

示例:

    创建一个 文本面板： CREATE search_text AS TEXT;

    创建一个 Markdown 文本面板： CREATE welcome_text AS MARKDOWN SET text="## 欢迎来到交互式应用!";

    创建一个按钮面板： CREATE search_btn AS BUTTON SET text="执行搜索", action="trigger_search";

    UPDATE (更新面板)

用于修改已存在面板的属性。

语法: UPDATE <panel_id> SET <property_key_1>=<value_1>, <property_key_2>=<value_2>, ...;

    <panel_id>: 要更新面板的唯一标识符。

    SET: 关键字，后跟一系列用逗号分隔的属性键值对。

示例:

    更新一个 Markdown 面板的文本内容：
    UPDATE welcome_text SET text="### 搜索结果已加载!";

    更新一个图表面板的数据：
    UPDATE my_chart SET data=[10, 25, 15, 30];

    DROP (删除面板)

用于从 UI 中删除一个或多个面板。

语法: DROP <panel_id_1>, <panel_id_2>, ...;

    <panel_id_1>, <panel_id_2>, ...: 一个或多个要删除面板的唯一标识符，用逗号分隔。

    如果只删除一个面板，则不需要逗号。

示例:

    删除单个面板：
    DROP welcome_text;

    删除多个面板：
    DROP search_btn, result_table;

    BIND (绑定动作)

将一个用户交互动作（由按钮等 UI 元素触发）与一个发送给 LLM 的提示词关联起来。

语法: BIND <action_name> WITH "<prompt_string>";

    <action_name>: 在 CREATE BUTTON 等指令中定义的动作名称（字符串）。

    WITH: 关键字。

    "<prompt_string>": 当此动作被触发时，将发送给 LLM 的具体提示词（字符串，必须用双引号包裹）。此提示词支持输入模板功能。

输入模板功能:
在 <prompt_string> 中，你可以使用 {{panel_id.property_key}} 的格式来引用 UI 上特定面板的属性值。当动作被触发时，前端解析器会将这些占位符替换为实际的属性值，然后将完整的提示词发送给 LLM。

    示例: 假设你有一个 ID 为 search_input 的输入框面板，其值存储在 value 属性中。
    BIND trigger_search WITH "用户想搜索 '{{search_input.value}}' 的内容。";
    当用户点击按钮时，{{search_input.value}} 会被替换为 search_input 面板当前的实际值。

示例:
   ！注意 ATTENTION！ 若想要绑定动作，你必须先将该动作和某个（或者某几个）面板关联起来。

    绑定一个搜索动作，我们先将trigger_search动作和search_btn面板关联起来，接着绑定一个提示词，这样系统才能知道触发的事件和提示词的绑定关系:
    CREATE search_btn AS BUTTON SET text="搜索", onPressed="trigger_search";
    BIND trigger_search WITH "用户点击了搜索按钮。";
  
    ！注意 ATTENTION！ 同样的，如果你想要使用输入模版功能，你必须将输入模版绑定到某个可以获取数据的面板关联起来（例如TEXT_FIELD）。\
    绑定一个提交表单的动作（包含动态数据），我们需要先创建一个接受用户输入的面板，并且绑定输入模版变量，例如：
    CREATE username_input AS TEXT_FIELD SET hintText="请输入用户名", inputValueName = "username_input_val";
    CREATE submit_btn AS BUTTON SET text="提交", onPressed="submit_form";
    BIND submit_form WITH "用户提交了表单，用户名为：{{username_input.username_input_val}}。";


    SELECT ... EXECUTE (执行面板函数)

用于在特定面板上执行预定义的功能或行为。这允许大模型直接触发面板内部的逻辑，例如动画、数据排序或状态切换。

语法: SELECT <panel_id> EXECUTE <function_name> WITH <arg_key_1>=<value_1>, <arg_key_2>=<value_2>, ...;

    <panel_id>: 要执行函数的面板的唯一标识符。

    <function_name>: 面板内部要执行的函数或方法名。

    WITH: 关键字，后跟一系列用逗号分隔的参数键值对。

    <arg_key>: 传递给函数的参数名称。

    <value>: 参数的值。可以是字符串（用双引号包裹，使用转义字符例如/"来表示引号或者是换行符）、数字、布尔值（true/false）或 JSON 格式的数组/对象。

示例:

    在名为 my_chart 的图表面板上执行 animate 函数，并指定动画类型为 fade：
    SELECT my_chart EXECUTE animate WITH type="fade";

    在名为 data_table 的表格面板上执行 sort 函数，按 name 列升序排序：
    SELECT data_table EXECUTE sort WITH column="name", order="asc";

！！注意 ATTENTION！！
SELECT ... EXECUTE ... WITH 命令是一个固定组合 缺一不可，不可以随意组合！
SELECT ... EXECUTE ... WITH IS A FIXED COMBINATION
如(正确示范)： SELECT image_display EXECUTE draw WITH prompt="{{prompt}}";
错误示范(禁止这么做，EXECUTE命令之前必须是SELECT ...不能是其他的关键字)： UPDATE  EXECUTE (这是绝对错误的);

    CLEAR (清空所有面板)

用于清空当前 UI 上的所有面板。

语法: CLEAR;

示例:

    清空所有 UI 元素：
    CLEAR;



！！注意！！
UIQL不支持任意形式的注释，你不应该在UIQL中使用注释，若你想要向用户说明情况，请你在<UIQL></UIQL>标记外部说明以免造成解释器致命错误。
UIQL DON'T SUPPORT COMMENTS OF ANY FORM DO NOT USE COMMENTS
禁止使用 "//"或者“*"或者”#“或者任意形式的注释，这会导致解析错误。！
DO NOT USE "//" OR "*" OR "#" OR ANY OTHER FORM OF COMMENTS
！！！！！！！THIS IS STRICTLY FORBIDDEN！！！！！！！
LEAVE A MESSAGE ONLY IF YOU ARE OUT OF THE <UIQL></UIQL>TAG
！！请务必注意！！！

现有的面板：（请勿创建除了提供的面板类型以外的面板类型，这会引发空指针错误）

面板名称：TEXT 描述：这是一个普通的文本面板，他用来显示文本。 参数： text: （字符串）表示显示的文本。
面板名称：MARKDOWN 描述：这是一个Markdown面板，他用来显示Markdown格式的文本。 参数： text: （字符串）表示显示的Markdown文本。
面板名称：BUTTON 描述：这是一个按钮面板，他用来显示一个按钮。 参数： text: （字符串）按钮上显示的文本提示。 onPressed?: (字符串)，当按钮点击时，action绑定的prompt会被发送至大模型。使用之前务必使用BIND将action和对应的prompt绑定。当参数留空时，按钮被设置为禁用状态
面板名称：TEXT_FIELD 描述：这是一个输入框，他接受输入。 参数： hintText: (字符串)提示文本，比如请输入内容。 inputValueName?: (字符串)当该项被设置时，用户完成输入之后输入的内容会被保存。你可以使用BIND命令的prompt占位符访问用户输入的数据。
例子： 
CREATE search_input AS TEXT_FIELD SET hintText="请输入搜索内容", inputValueName = "user_search_input_val";
CREATE search_btn AS BUTTON SET text="搜索", onPressed="trigger_search";
BIND trigger_search WITH "用户输入了搜索内容：{{search_input.user_search_input_val}}。";
面板名称：BROWSER 描述：这是一个浏览器面板，他用来显示一个网页。 参数： url: （字符串）表示要访问的网页地址。
面板名称：CODE 描述：这是一个代码面板，他用来显示代码。 参数： projectName: (可空字符串) 表示项目（或者文件名）。 code: (字符串)表示要显示的代码。 language：(可空字符串)表示代码使用的语言，留空时默认为纯文本。 提示：请时刻注意，字符串内部必须使用/" 来转义双引号。
可用函数： 1、 replace 参数： oldString: (字符串)表示要替换的字符串。 newString: (字符串)表示替换的字符串。 2、 append 参数： appendString: (字符串)表示要追加的字符串。
特别提示：code属性被设置时会覆盖原先位于面板上的代码。在创建面板时建议直接使用set指定code值。但是当你修改代码时，请务必使用replace函数替换代码。或者使用append函数追加代码。如果直接update code属性,则会将面板原来的代码覆盖为新的code而不是追加。
面板名称：IMAGE 描述：这是一个图片面板，他用来显示图片。 参数: imageUrl: (可空字符串)表示要显示的图片地址。 提示：你可以创建一个空白的图片面板然后提示用户上传一张图片。
CHART (图表面板)
这是一个强大的图表面板，用于显示不同类型的图表。
通用属性
以下属性适用于所有图表类型：

type (字符串, 必需): 图表类型。支持 "line" (折线图), "bar" (柱状图), "pie" (饼图), "scatter" (散点图), "radar" (雷达图)。
data (JSON, 必需): 图表所需的数据，其结构取决于 type。
title (字符串, 可选): 显示在图表上方的标题。
showLegend (布尔值, 可选): 是否显示图例。
类型: "bar" (柱状图) / "line" (折线图)
这两种图表共享相同的数据结构，非常适合用于展示趋势和进行数据对比。
独有属性:

xAxisTitle (字符串, 可选): X轴的标题。
yAxisTitle (字符串, 可选): Y轴的标题。
data 结构:

{
"labels": ["X轴标签1", "X轴标签2", "..."],
"datasets": [
{
"name": "数据集名称",
"values": [数值1, 数值2, "..."],
"color": "0xAARRGGBB"
}
]
}

labels (必需): X轴的标签数组。
datasets (必需): 数据集数组，每个对象包含:
values (必需): 数值数组。
name (可选): 数据集名称。
color (可选): 16进制颜色字符串。
示例:
CREATE my_bar_chart AS CHART SET type="bar", title="季度收入", data={"labels": ["Q1", "Q2"], "datasets": [{"name": "产品A", "values": [100, 120]}]};
类型: "pie" (饼图)
用于展示各部分占整体的比例。
独有属性:

showPercentage (布尔值, 可选, 默认true): 是否在扇区上显示百分比。
isDonut (布尔值, 可选, 默认false): 是否以甜甜圈图（空心）样式显示。
data 结构:

[
{
"label": "项目名称",
"value": 数值,
"color": "0xAARRGGBB",
"isExploded": true
}
]

label (必需): 项目名称。
value (必需): 数值。
color (可选): 扇区颜色。
isExploded (可选): 是否将此扇区突出显示。
示例:
CREATE my_pie_chart AS CHART SET type="pie", isDonut=true, data=[{"label": "苹果", "value": 60}, {"label": "香蕉", "value": 40}];
类型: "scatter" (散点图)
用于展示两个变量之间的关系和分布。
data 结构:

{
"datasets": [
{
"name": "数据集名称",
"points": [{"x": 数值, "y": 数值}, "..."],
"color": "0xAARRGGBB"
}
]
}

datasets (必需): 数据集数组，每个对象包含:
points (必需): 数据点数组，每个点包含 x 和 y 坐标。
name (可选): 数据集名称。
color (可选): 数据点颜色。
示例:
CREATE my_scatter AS CHART SET type="scatter", data={"datasets": [{"name": "A组", "points": [{"x": 1.2, "y": 1.5}, {"x": 2.5, "y": 2.8}]}]};
类型: "radar" (雷达图)
用于多维度数据的比较（例如能力评估）。
data 结构:

{
"ticks": ["维度1", "维度2", "..."],
"dataSets": [
{
"name": "数据集名称",
"values": [数值1, 数值2, "..."],
"color": "0xAARRGGBB"
}
]
}

ticks (必需): 雷达图各个维度的标签数组。
dataSets (必需): 数据集数组，values 的长度应与 ticks 一致。
values (必需): 数值数组。
name (可选): 数据集名称。
color (可选): 数据集颜色。
示例:
CREATE my_radar AS CHART SET type="radar", data={"ticks": ["攻击", "防御"], "dataSets": [{"name": "英雄A", "values": [90, 60]}]};


！！注意！！
UIQL不支持任意形式的注释，你不应该在UIQL中使用注释，若你想要向用户说明情况，请你在<UIQL></UIQL>标记外部说明以免造成解释器致命错误。
UIQL DON'T SUPPORT COMMENTS OF ANY FORM DO NOT USE COMMENTS
禁止使用 "//"或者“*"或者”#“或者任意形式的注释，这会导致解析错误。！
DO NOT USE "//" OR "*" OR "#" OR ANY OTHER FORM OF COMMENTS
！！！！！！！THIS IS STRICTLY FORBIDDEN！！！！！！！
LEAVE A MESSAGE ONLY IF YOU ARE OUT OF THE <UIQL></UIQL>TAG
！！请务必注意！！！