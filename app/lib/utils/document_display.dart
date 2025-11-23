import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_chat/theme_manager.dart';
import 'package:uni_chat/utils/prebuilt_widgets.dart';
import 'package:uni_chat/utils/web_view/src/webview/webview.dart';

import '../generated/l10n.dart';

class ShowDocButton extends ConsumerWidget {
  const ShowDocButton({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var v = ref.watch(documentDisplayProvider.select((s) => s.isVisible));
    return StdButton(
      onPressed: ref.read(documentDisplayProvider.notifier).toggleVisibility,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.text_snippet_outlined, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            v ? S.of(context).hide_document : S.of(context).show_document,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class DocDisplayStateNotifier extends StateNotifier<DocDisplayState> {
  DocDisplayStateNotifier() : super(DocDisplayState(isVisible: false, url: ""));

  void show() {
    state = state.copyWith(isVisible: true);
  }

  void hide() {
    state = state.copyWith(isVisible: false);
  }

  void toggleVisibility() {
    state = state.copyWith(isVisible: !state.isVisible);
  }

  void setUrl(String url) {
    state = state.copyWith(url: url);
  }

  void setShowWithUrl(bool show, String url) {
    state = state.copyWith(isVisible: show, url: url);
  }
}

final documentDisplayProvider =
    StateNotifierProvider<DocDisplayStateNotifier, DocDisplayState>(
      (ref) => DocDisplayStateNotifier(),
    );

class DocDisplayState {
  final bool isVisible;
  final String url;
  DocDisplayState({required this.isVisible, required this.url});

  DocDisplayState copyWith({bool? isVisible, String? url}) {
    return DocDisplayState(
      isVisible: isVisible ?? this.isVisible,
      url: url ?? this.url,
    );
  }
}

class DocumentDisplay extends ConsumerWidget {
  const DocumentDisplay({super.key, this.width = 400});
  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = ref.watch(themeProvider);
    var state = ref.watch(documentDisplayProvider);
    return StatefulBuilder(
      builder: (context, setState) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: state.isVisible ? width : 0,
          height: double.maxFinite,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.zeroGradeColor,
            borderRadius: BorderRadius.circular(8),
          ),
          onEnd: () {},
          clipBehavior: Clip.hardEdge,
          padding: const EdgeInsets.all(4),
          child: Visibility(
            visible: state.isVisible,
            maintainState: true,
            child: _WebViewWidget(key: ValueKey(1423143214), state: state),
          ),
        );
      },
    );
  }
}

///真正显示网页的部件
///需要注意的是由于经常涉及到在多个网页之间切换，所以需要使用IndexedStack来缓存网页
///这里最多缓存5个网页
class _WebViewWidget extends StatefulWidget {
  const _WebViewWidget({super.key, required this.state});

  final DocDisplayState state;

  @override
  State<_WebViewWidget> createState() => _WebViewWidgetState();
}

class _WebViewWidgetState extends State<_WebViewWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _WebViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.url != currentUrl && widget.state.isVisible) {
      if (cached.containsKey(widget.state.url)) {
        index = cached[widget.state.url]!;
      } else {
        if (cachedLength < 5) {
          cached[widget.state.url] = cachedLength;
          urls[cachedLength] = widget.state.url;
          cachedLength++;
        } else {
          index = cachedLength % 5;
          cached[widget.state.url] = index;
          cached.remove(urls[index]);
          urls[index] = widget.state.url;
          cachedLength++;
        }
      }
      currentUrl = widget.state.url;
      setState(() {});
    }
  }

  int cachedLength = 0;

  int index = 0;
  String currentUrl = "";
  Map<String, int> cached = {};
  Map<int, String> urls = {0: "", 1: "", 2: "", 3: "", 4: ""};
  @override
  Widget build(BuildContext context) {
    try {
      return IndexedStack(
        index: index,
        children: [
          Webview(key: ValueKey(urls[0]), url: urls[0]!),
          Webview(key: ValueKey(urls[1]), url: urls[1]!),
          Webview(key: ValueKey(urls[2]), url: urls[2]!),
          Webview(key: ValueKey(urls[3]), url: urls[3]!),
          Webview(key: ValueKey(urls[4]), url: urls[4]!),
        ],
      );
    } catch (e) {
      return const SizedBox();
    }
  }
}
