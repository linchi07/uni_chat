import 'package:uni_chat/llm_provider/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageGenProvider extends StateNotifier<LLMApiService?>{
  ImageGenProvider(): super(null);
}

final imageGenProvider = StateNotifierProvider<ImageGenProvider, LLMApiService?>((ref) {
  return ImageGenProvider();
});