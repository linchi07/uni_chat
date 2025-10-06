import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_chat/Chat/chat_models.dart';
import 'package:uni_chat/RAG/rag_databases.dart';
import 'package:uni_chat/RAG/rag_entity.dart';
import 'package:uni_chat/RAG/rag_process.dart';
import 'package:uni_chat/llm_provider/api_service.dart';
import 'package:uni_chat/llm_provider/api_service_provider.dart';
import 'package:uni_chat/utils/file_utils.dart';
import 'package:uuid/uuid.dart';

import '../top_banner.dart';

class RagProvider {
  RagProvider(this.ref);
  Ref ref;
  Map<String, VectorSearchManager> vectorDbInstances = {};
  bool requireEmbedding = false;

  SendPort? autoIndexRequestSend;
  ReceivePort? autoIndexRequestReceive;
  Map<RegExp, String> ocRegex = {};
  List<KnowledgeBase> loadedKBs = [];
  List<Embedding> kbRequireVecSearch = [];
  List<KnowledgeBase> kbsRequireKeyWordSearch = [];
  String? loadedAgentId;
  String? sessionId;
  SendPort? embeddingRequestSend;
  Future<void> loadKnowledgeBases(
    List<String> kbIds,
    ChatSession session,
  ) async {
    sessionId = session.id;
    if (autoIndexRequestSend != null) {
      autoIndexRequestReceive?.close();
      autoIndexRequestSend?.send(null);
      autoIndexRequestSend = null;
      autoIndexRequestReceive = null;
    }
    if (embeddingRequestSend != null) {
      embeddingRequestSend?.send(null);
      embeddingRequestSend = null;
    }
    loadedKBs.clear();
    messagesCached.clear();
    Map<String, LLMApiService> embeddingInstances = {};
    for (var k in kbIds) {
      var kb = await RAGDatabaseManager().getKnowledgeBaseById(k);
      if (kb == null) {
        print("Knowledge base $kb not found");
        continue;
      }
      var requireIndexM = await RAGDatabaseManager()
          .getIndexMethodOfKnowledgeBase(kb.id);
      if (requireIndexM.contains(RAGIndexMethod.vector)) {
        kbRequireVecSearch.add(kb.embeddings.first);
        vectorDbInstances[kb.embeddings.first.id] ??= VectorSearchManager(
          await PathProvider.getPath(
            "RAG/VectorSearch/${kb.embeddings.first.id}",
          ),
          kb.embeddings.first.vectorDimension,
        );
        loadedKBs.add(kb);
        if (!embeddingInstances.containsKey(
          kb.embeddings.first.modelConfigId,
        )) {
          var ei = (await ApiServiceProvider.instance.createApiService(
            kb.embeddings.first.modelConfigId,
          ));
          if (ei == null) {
            throw "Embedding model not found";
          }
          embeddingInstances[kb.embeddings.first.modelConfigId] = ei;
        }
        var rp = ReceivePort();
        embeddingRequestSend = rp.sendPort;
        Isolate.spawn((m) {
          embeddingService(m.$1, m.$2, m.$3);
        }, (embeddingInstances, kbRequireVecSearch, rp));
      }
      if (requireIndexM.contains(RAGIndexMethod.keyword)) {
        kbsRequireKeyWordSearch.add(kb);
      }
      if (requireIndexM.contains(RAGIndexMethod.regex)) {
        var r = await RAGDatabaseManager().getOriginalContentRequireRegex(
          kb.id,
        );
        var rmap = {for (var e in r) e.$2: e.$1};
        ocRegex.addAll(rmap);
      }
    }
    var airs = await RAGDatabaseManager().getAutoIndexRulesByAgentId(
      session.agentId,
    );
    if (airs.isNotEmpty) {
      var rp = ReceivePort();
      autoIndexRequestSend = rp.sendPort;
      autoIndexRequestReceive = ReceivePort();
      Isolate.spawn((m) {
        autoIndex(m.$1, m.$2, m.$3, m.$4);
      }, (rp, autoIndexRequestReceive!.sendPort, airs, session));
      loadedAgentId = session.agentId;
      autoIndexRequestReceive?.listen((data) {});
    }
  }

  List<FormattedChatMessage> messagesCached = [];
  //将关键词命中的消息直接缓存起来不需再次
  Future<List<FormattedChatMessage>> onUserNewMessageCall(
    ChatMessage newContent,
  ) async {
    var rp = ReceivePort();
    //获取嵌入
    if (kbRequireVecSearch.isNotEmpty) {
      embeddingRequestSend!.send((newContent.content, rp.sendPort));
    }
    //正则匹配
    var rg = regexIndex(newContent.content);
    var c = IndexMessages(sessionId);
    //关键词匹配
    for (var k in kbsRequireKeyWordSearch) {
      c.addOriginalContentNoRepeat(
        await RAGDatabaseManager().getKeywordsMatchSimpleContent(
          k.id,
          newContent.content,
        ),
      );
    }
    //这个时候才await 正则的结果返回
    c.addOriginalContentNoRepeat(await rg);
    messagesCached.addAll(
      c.originalContent.values.map((m) => buildMessages(m)),
    );
    if (kbRequireVecSearch.isNotEmpty) {
      var embR = await rp.first as Map<String, List<double>>;
      rp.close();
      for (var v in kbRequireVecSearch) {
        var q = embR["${v.id}+${v.vectorDimension}"];
        if (q == null) continue;
        //TODO:this should be manually set
        var cids = await vectorDbInstances[v.id]?.vecQuery(q, 5);
        if (cids == null) continue;
        c.addContentChunkNoRepeat(
          await RAGDatabaseManager().getManySimpleContentOfContentChunk(
            cids.map((m) => m.getChunkId()).toList(),
          ),
        );
      }
    }
    var m = [
      ...messagesCached,
      ...c.contentChunk.values.map((m) => buildMessages(m)),
    ];
    if (autoIndexRequestSend != null) {
      autoIndexRequestSend?.send(newContent);
    }
    return m;
  }

  FormattedChatMessage buildMessages(SimpleContent c) {
    var metadata =
        "来源【文件：${c.metadata.originalName}${c.metadata.extension}，${(c.metadata.createdAt == null) ? null : "创建时间：${c.metadata.createdAt}"}";
    return FormattedChatMessage(
      content: "$metadata\n内容：${c.content}",
      sender: MessageSender.system,
      type: ChatMessageType.text,
      id: Uuid().v4(),
    );
  }

  Future<List<SimpleContent>> regexIndex(String content) {
    if (loadedAgentId == null) {
      throw "Not loaded";
    }
    var match = <String>{};
    for (var rx in ocRegex.keys) {
      if (rx.hasMatch(content)) {
        match.add(ocRegex[rx]!);
      }
    }
    return RAGDatabaseManager().getManySimpleContents(match.toList());
  }

  void embeddingService(
    Map<String, LLMApiService> embeddingInstances,
    List<Embedding> embeddings,
    ReceivePort rp,
  ) {
    rp.listen((m) async {
      if (m == null) {
        rp.close();
        Isolate.current.kill(priority: Isolate.immediate);
      }
      var message = (m.$1) as String;
      var embResult = <String, List<double>>{};
      for (var e in embeddings) {
        if (!embResult.containsKey("${e.modelConfigId}+${e.vectorDimension}")) {
          var ei = embeddingInstances[e.modelConfigId];
          if (ei == null) {
            throw "Embedding ${e.modelConfigId} not found";
            //这应该不可能发生
          }
          try {
            var er = await ei.embedding([message], e.vectorDimension);
            if (er.isEmpty) {
              throw "Embedding ${e.modelConfigId} failed";
            }
            embResult["${e.modelConfigId}+${e.vectorDimension}"] =
                er.first; //在消息的时候我们只会获取第一个向量（因为也只输入了一个）
          } catch (e) {
            throw "Embedding failed";
          }
        }
      }
      var p = m.$2 as SendPort;
      p.send(embResult);
    });
  }

  void onAgentNewMessage(ChatMessage msg) {
    if (loadedAgentId == null) {
      throw "Not loaded";
    }
    autoIndexRequestSend?.send(msg);
  }

  void autoIndex(
    ReceivePort receive,
    SendPort send,
    List<AutoIndexRule> rules,
    ChatSession session,
    //TODO: 在现在这没问题，因为我们只允许一个Regex，但是后面如果要改回允许多个regex的话，这里就要改了
  ) {
    receive.listen((m) {
      if (m == null) {
        //发送null的时候杀掉这个isolate
        receive.close();
        Isolate.current.kill(priority: Isolate.immediate);
      }
      var message = m as ChatMessage;
      List<Map<String, dynamic>> result = [];
      Uuid uuid = Uuid();
      // ignore system messages
      if (message.sender == MessageSender.system) return;
      for (var rule in rules) {
        if (rule.issuer == Issuer.any ||
            (rule.issuer == Issuer.assistant &&
                message.sender == MessageSender.ai) ||
            (rule.issuer == Issuer.user &&
                message.sender == MessageSender.user)) {
          if (rule.match(message.content)) {
            var oc = OriginalContent(
              id: uuid.v7(),
              knowledgeBaseId: rule.knowledgeBaseId,
              content: message.content,
              insertedAt: message.timestamp,
              indexMethod: rule.ragIndexMethod,
              metadata: MetaData(
                originalName: session.name,
                contentType: RagContentType.chatHistory,
                author: message.sender == MessageSender.user
                    ? 'user'
                    : session.agentId,
                createdAt: message.timestamp,
              ),
            );
            print(oc.toMap());
          }
        }
      }
    });
  }

  Future<void> processKnowledgeBase(KnowledgeBase kb) async {
    if (kb.status == KnowledgeBaseStat.OK) {
      return;
    }
    var kbs = await RAGDatabaseManager().getRawOriginalContentOfBase(kb.id);
    ref.read(activityProvider.notifier).state = ActivityState(
      name: kb.name,
      hint: "正在处理记忆库...",
    );
    final processResult = ReceivePort();
    var api = await ApiServiceProvider.instance.createApiService(
      kb.embeddings.first.modelConfigId,
    );
    await Isolate.spawn((param) async {
      await RagProcessor.processContent(param.$1, param.$2, param.$3, param.$4);
    }, (kb, kbs, api, processResult.sendPort));
    processResult.listen((data) async {
      var result = data as ContentProcessResult;
      //整个都用事务包裹，保证统一
      await RAGDatabaseManager().updateDBsWithTransaction(result, () async {
        if (result.writeToVectorDB.isNotEmpty) {
          var vdb = vectorDbInstances[kb.embeddings.first.id] ??=
              VectorSearchManager(
                await PathProvider.getPath(
                  "RAG/VectorSearch/${kb.embeddings.first.id}",
                ),
                kb.embeddings.first.vectorDimension,
              );
          await vdb.putMany(result.writeToVectorDB);
        }
      });
      if (result.onError != null) {
        ref.read(activityProvider.notifier).state = ActivityState(
          name: kb.name,
          hint: "发生错误",
          error: result.onError!.toString(),
        );
      }
      if (result.isFullyFinished && result.onError != null) {
        ref.read(activityProvider.notifier).state = null;
        kb.status = KnowledgeBaseStat.OK;
        await RAGDatabaseManager().insertOrUpdateKnowledgeBase(kb);
      }
    });
    vectorDbInstances.clear();
  }
}

class IndexMessages {
  Map<int, SimpleContent> originalContent = {};
  Map<int, SimpleContent> contentChunk = {};
  String? sessionIdExcept;

  IndexMessages(this.sessionIdExcept);

  ///加入非重复内容，注意，如果内容重复，则优先保留完整的original content，如果都是同一类型，那么保留后插入的
  void addOriginalContentNoRepeat(Iterable<SimpleContent> contents) {
    for (var c in contents) {
      if (c.isContentChunk) {
        throw ArgumentError('content chunk cannot be added');
      } else {
        //当处于同一个聊天的时候，忽略该聊天的chunk
        if (sessionIdExcept != null &&
            c.metadata.contentType == RagContentType.chatHistory &&
            c.metadata.sessionId == sessionIdExcept) {
          continue;
        }
        originalContent[c.hash] = c;
      }
    }
  }

  ///加入非重复内容，注意，如果内容重复，则优先保留完整的original content，如果都是同一类型，那么保留后插入的
  void addContentChunkNoRepeat(List<SimpleContent> contents) {
    for (var c in contents) {
      if (c.isContentChunk) {
        if (sessionIdExcept != null &&
            c.metadata.contentType == RagContentType.chatHistory &&
            c.metadata.sessionId == sessionIdExcept) {
          continue;
        }
        if (!originalContent.containsKey(c.originalContentHash)) {
          contentChunk[c.hash] = c;
        }
      } else {
        throw "Not a content chunk";
      }
    }
  }
}

final ragProvider = StateProvider<RagProvider>((ref) {
  return RagProvider(ref);
});
