
import 'package:uni_chat/Chat/chat_page_main.dart';
import 'package:uni_chat/Chat/inline_dynamic_fc_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UIQLPreviewer extends ConsumerStatefulWidget {
  const UIQLPreviewer({super.key});

  @override
  ConsumerState<UIQLPreviewer> createState() => _UIQLPreviewerState();
}

class _UIQLPreviewerState extends ConsumerState<UIQLPreviewer> {
  final TextEditingController _controller = TextEditingController();
  late final InlineDynamicParser _parser;
  String? _errorText;
  bool _isStreaming = true; // Control for streaming mode

  @override
  void initState() {
    super.initState();
    final panelManagerInstance = ref.read(panelManager);
    _parser = InlineDynamicParser(
      create: panelManagerInstance.create,
      update: panelManagerInstance.update,
      drop: panelManagerInstance.drop,
      bind: panelManagerInstance.bind,
      clear: panelManagerInstance.clear,
      select: panelManagerInstance.select,
    );

    _controller.addListener(_onTextChanged);
  }

  void _processUiql() {
    final text = _controller.text;
    // Every time text changes, we clear all existing panels and re-parse.
    ref.read(panelManager).clear();
    
    // The parser needs to be reset for each new parse attempt.
    _parser.cleanUpWithBuffer();
    
    setState(() {
      _errorText = null;
    });

    if (text.isNotEmpty) {
      try {
        _parser.parse(text);
      } catch (e) {
        setState(() {
          _errorText = e.toString();
        });
      }
    }
  }

  void _onTextChanged() {
    if (_isStreaming) {
      _processUiql();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'UIQL Live Preview',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Text('Stream', style: Theme.of(context).textTheme.labelMedium),
                  Switch(
                    value: _isStreaming,
                    onChanged: (value) {
                      setState(() {
                        _isStreaming = value;
                      });
                    },
                  ),
                  if (!_isStreaming)
                    ElevatedButton(
                      onPressed: _processUiql,
                      child: const Text('Run'),
                    ),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter UIQL commands here (e.g., <UIQL>CREATE p1 AS TEXT SET text="Hello";</UIQL>)',
                border: const OutlineInputBorder(),
                errorText: _errorText,
              ),
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isStreaming
              ? 'Note: Panels will appear on the right. All panels are cleared on each keystroke.'
              : 'Note: Panels will appear on the right. Click "Run" to apply changes.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
