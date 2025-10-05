import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_chat/RAG/rag_databases.dart';
import 'package:uni_chat/RAG/rag_entity.dart';
import 'package:uni_chat/utils/file_utils.dart';

class RAGInstance {
  String id;
  late KnowledgeBase knowledgeBase;
  late List<VectorSearchManager>? vectorSearchManager;
  RAGInstance(this.id, this.knowledgeBase, this.vectorSearchManager);

  Future<List<ContentChunk>> query(
    String stringQuery,
    List<double> queryVec,
    int maxResultCount,
  ) async {
    var chunks = <ContentChunk>[];
    if (knowledgeBase.defaultIndexMethod.contains(RAGIndexMethod.vector)) {
      for (var vacm in vectorSearchManager!) {
        var vecs = await vacm.vecQuery(queryVec, maxResultCount);
        for (var vec in vecs) {
          var chunk = await RAGDatabaseManager().getContentChunkById(
            vec.getChunkId(),
            knowledgeBase.id,
          );
          if (chunk != null) {
            chunks.add(chunk);
          }
        }
      }
    }
    if (knowledgeBase.defaultIndexMethod.contains(RAGIndexMethod.keyword)) {
      // TODO: use ft5
      var chunksFromKeyword = await RAGDatabaseManager().keywordsMatchContent(
        stringQuery,
        knowledgeBase.id,
      );
      chunks.addAll(chunksFromKeyword);
    }
    return chunks;
  }
}

class RagProvider {
  List<RAGInstance> ragInstances = [];
  bool requireEmbedding = false;
  Future<void> init(List<String> knowledgeBaseIds) async {
    for (var knowledgeBaseId in knowledgeBaseIds) {
      var knowledgeBase = await RAGDatabaseManager().getKnowledgeBasesById(
        knowledgeBaseId,
      );
      if (knowledgeBase == null) {
        // TODO: handle this
        continue;
      }
      var vacms = <VectorSearchManager>[];
      if (knowledgeBase.defaultIndexMethod.contains(RAGIndexMethod.vector)) {
        requireEmbedding = true;
        for (var e in knowledgeBase.embeddings) {
          var kbPath = await PathProvider.getPath("RAG/VectorSearch/${e.id}");
          vacms.add(VectorSearchManager(kbPath, e.vectorDimension));
        }
      }
      var ragInstance = RAGInstance(
        knowledgeBase.id,
        knowledgeBase,
        vacms.isEmpty ? null : vacms,
      );
      ragInstances.add(ragInstance);
    }
  }

  void pendKnowledgeBase(KnowledgeBase kb) {}
}

final ragProvider = Provider<RagProvider>((ref) {
  return RagProvider();
});
