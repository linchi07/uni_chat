import 'package:uni_chat/Chat/panels/basic_pannel.dart';
import 'package:uni_chat/Chat/panels/panel_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BrowserPanel extends BasicPanel {
  BrowserPanel({super.key, required super.name});

  @override
  Widget buildInternal(BuildContext context, WidgetRef ref, PanelData data) {
    final url = data.props['url'];

    if (url == null || url.isEmpty || Uri.tryParse(url) == null) {
      return const Center();
    }
    try {
      return Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
        clipBehavior: Clip.hardEdge,
        child: BrowserPanelContent(
          props: data.props,
          key: ValueKey("${data.name}+1145141919810"),
        ),
      );
    } catch (e) {
      return const Center(child: Text('Invalid URL'));
    }
  }
}

class BrowserPanelContent extends StatefulWidget {
  final Map<String, String> props;

  const BrowserPanelContent({required this.props, required Key key})
    : super(key: key);

  @override
  State<BrowserPanelContent> createState() => _BrowserPanelContentState();
}

class _BrowserPanelContentState extends State<BrowserPanelContent> {
  late final WebViewController _controller;
  String _currentUrl = '';

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.props['url']!;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _currentUrl = url;
              widget.props['url']??= _currentUrl;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(_currentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          color: Colors.grey[200],
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () async {
                  if (await _controller.canGoBack()) {
                    await _controller.goBack();
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  _controller.reload();
                },
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: _currentUrl),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 16),
                  onSubmitted: (String value) {
                    if (value != _currentUrl) {
                      try {
                        final uri = Uri.parse(value);
                        _controller.loadRequest(uri);
                        setState(() {
                          _currentUrl = value;
                        });
                      } catch (e) {
                        // Handle invalid URL if needed
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(child: WebViewWidget(controller: _controller)),
      ],
    );
  }
}
