import 'package:flutter/material.dart';
import 'package:uni_chat/Chat/chat_message_bubble.dart'; // Contains BlockParser
import 'package:uni_chat/utils/chunked_string_buffer.dart';

class MessageBubblePreviewer extends StatefulWidget {
  const MessageBubblePreviewer({super.key});

  @override
  State<MessageBubblePreviewer> createState() => _MessageBubblePreviewerState();
}

class _MessageBubblePreviewerState extends State<MessageBubblePreviewer> {
  final TextEditingController _controller = TextEditingController();
  final ChunkedStringBuffer _buffer = ChunkedStringBuffer();
  late BlockParser _parser;
  List<Widget> _parsedBlocks = [];

  @override
  void initState() {
    super.initState();
    _parser = BlockParser(_buffer);
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    // On every change, we clear the buffer, write the new content,
    // and re-parse to update the preview.
    setState(() {
      _buffer.clear();
      _buffer.write(_controller.text);
      // For a live preview, we must reset the parser's internal state as well
      // to handle dynamic parsing correctly from a clean slate.
      _parser = BlockParser(_buffer);
      _parsedBlocks = _parser.parseDynamicBlock();
    });
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
          const Text(
            'Message Bubble Live Preview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Test the BlockParser by typing text with XML tags (e.g., <UIQL>...</UIQL>).',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            flex: 2,
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Enter text to parse here...',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const Text(
            'Parsed Output:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView(
                padding: const EdgeInsets.all(12.0),
                children: _parsedBlocks.isNotEmpty
                    ? _parsedBlocks
                    : [
                        const Center(
                          child: Text(
                            'No content yet.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
