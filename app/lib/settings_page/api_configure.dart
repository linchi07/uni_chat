import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_chat/theme_manager.dart';
import 'package:uni_chat/utils/paged_scroll/paged_scroll.dart';
import 'package:uni_chat/utils/prebuilt_widgets.dart';

class ApiConfigure extends ConsumerStatefulWidget {
  const ApiConfigure({super.key});

  @override
  ConsumerState<ApiConfigure> createState() => _ApiConfigureState();
}

class _ApiConfigureState extends ConsumerState<ApiConfigure> {
  PageController controller = PageController();

  @override
  initState() {
    super.initState();
    theme = ref.read(themeProvider);
  }

  late ThemeConfig theme;
  @override
  Widget build(BuildContext context) {
    theme = ref.watch(themeProvider);
    return PagedScroll(
      controller: controller,
      children: [_BaseInfo(theme: theme)],
    );
  }
}

class _BaseInfo extends StatelessWidget {
  const _BaseInfo({super.key, required this.theme});

  final ThemeConfig theme;
  static List type = [
    "OpenAI Response",
    "Google",
    "OpenAI Completion (Legacy)",
  ];
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Text(
          "基础信息",
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: theme.darkTextColor,
          ),
        ),
        const Divider(height: 20, thickness: 1),
        Text("名称", style: TextStyle(fontSize: 20, color: theme.darkTextColor)),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 500,
            decoration: BoxDecoration(
              color: theme.zeroGradeColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: StdTextFieldOutlined(hintText: "请输入名称"),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "API类型",
          style: TextStyle(fontSize: 20, color: theme.darkTextColor),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: StdDropDown(
            height: 50,
            width: 500,
            onChanged: (index) {},
            itemBuilder: (context, index, onTap) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: StdListTile(
                  title: Text(type[index]),
                  onTap: () {
                    onTap(index);
                  },
                ),
              );
            },
            itemCount: type.length,
          ),
        ),
      ],
    );
  }
}
