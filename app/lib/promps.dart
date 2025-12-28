class Prompts {
  // 从open web ui那里直接逆向请求扒拉过来的
  static const String AUTO_TITLE_GENERATE_PROMPT = '''
  <no_think>
### Task:
Generate a concise, 6-8 word title summarizing the chat history.
### Guidelines:
- The title should clearly represent the main theme or subject of the conversation.
- Emojis can be  used to enhance understanding of the topic, but avoid quotation marks or special formatting.
- Write the title in the chat's primary language;
- Prioritize accuracy over excessive creativity; keep it clear and simple.
- Your entire response must consist solely of the JSON object, without any introductory or concluding text.
- The output must be a single, raw JSON object, without any markdown code fences or other encapsulating text.
- Ensure no conversational text, affirmations, or explanations precede or follow the raw JSON output, as this will cause direct parsing failure.
### Output:
JSON format: { "title": "your concise title here" }
### Chat History:
''';
  static String generateTitle(String chatLog) {
    return "$AUTO_TITLE_GENERATE_PROMPT${"<chatHistory>$chatLog</chatHistory>"}";
  }
}
