

import 'package:uni_chat/Chat/panels/panel_widgets/browser_panel.dart';
import 'package:uni_chat/Chat/panels/panel_widgets/chart_panel.dart';
import 'package:uni_chat/Chat/panels/panel_data.dart';
import 'package:uni_chat/Chat/panels/panel_layout_engine.dart';
import 'package:uni_chat/Chat/panels/panel_widgets/image_panel.dart';
import 'package:uni_chat/Chat/panels/panel_widgets/panels.dart';
import 'package:flutter/cupertino.dart';

import '../chat_page_main.dart';

typedef WidgetSetUpFunc =
Widget Function(
    String name,
    );

class PanelsFactory {
  static Map<String, ((int,int), WidgetSetUpFunc)> panelBasics = {
    "text": (
    (2, 1),
        (n) {
      return TextPanel(name: n);
    },
    ),
    "button": (
    (2, 1),
        (n) {
      return ButtonPanel(name: n);
    },
    ),
    "markdown": (
    (2, 3),
        (n) {
      return MarkDownPanel(name: n);
    },
    ),
    "text_field": (
    (2, 1),
        (n) {
      return TextFieldPanel(name: n);
    },
    ),
    "chart": (
    (2, 3),
        (n) {
      return ChartPanel(name: n);
    },
    ),
    "browser": (
    (4, -1),
        (n) {
      return BrowserPanel(name: n);
    },
    ),
    "code":(
    (3, -1),
        (n) {
      return CodePanel(name: n);
    },
    ),
    "image":(
    (3, 3),
        (n) {
      return ImagePanel(name: n);
    },
    ),
  };
  static (PanelData, WidgetSetUpFunc) createPanel(
      String name,
      String panelType,
      PanelLayoutEngine ple,
      ) {
    var p = panelBasics[panelType.trim().toLowerCase()]!;
    //注意！这里的copyWith是必须的，否则会出现两个面板引用了一个layout对象，然后改变一个，另一个也会改变
    //然后就会出现两个panel叠在一起，劳资调了好久才发现这个问题
    //当高度为负时，则高度为布局引擎的横向轴数
    return (PanelData(name: name, type: panelType,layout: Layout(id: ple.currentPanelIndex++, name: name, width: p.$1.$1, height: p.$1.$2 < 0?ple.config.horizontalAxisCount:p.$1.$2 , layoutEngine: ple)), p.$2);
  }
}