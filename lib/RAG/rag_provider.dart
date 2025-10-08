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

import '../utils/back_ground_task_manager.dart';

class PortBindingRequest {
  final String fromIsolate;
  final SendPort sendPort;

  PortBindingRequest({required this.fromIsolate, required this.sendPort});
}

class RagProvider {
  RagProvider(this.ref) {
    //需要这么做主要是dart不允许创建一个receive port然后传过去
    //必须要这样才能建立双向通讯，语法糖都这么多了，再加点怎么就不行了，非要我写这么丑的代码
    bindingPort.listen((m) {
      var r = m as PortBindingRequest;
      ports[r.fromIsolate] = r.sendPort;
    });
  }
  Ref ref;

  ///至少在现在，不要随随便便的就clear这个map，因为里面的object box实例如果直接销毁了就完蛋了
  ///他不允许重复开链接。而这里销毁了貌似不会自动调用那边的close。dart 也没有西沟函数。然后这个弱智玩意一个box一个表，所以不好给他写成单例模式。（这才是重点）
  Map<String, VectorSearchManager> vectorDbInstances = {};
  bool requireEmbedding = false;
  //这个port只用于建立双向通讯
  ReceivePort bindingPort = ReceivePort();
  ReceivePort? autoIndexRequestReceive;
  Map<String, SendPort> ports = {};
  Map<RegExp, String> ocRegex = {};
  List<KnowledgeBase> loadedKBs = [];
  List<Embedding> kbRequireVecSearch = [];
  List<KnowledgeBase> kbsRequireKeyWordSearch = [];
  String? loadedAgentId;
  String? sessionId;

  ///dart的闭包机制会导致如果实例化的时候spawn isolate他会导致引用this然后就会导致不可被传递的对象 vectorDbInstances 传过去然后就报错了，必须单独封装static 函数
  static void _embeddingWrapper(dynamic m) {
    embeddingService(m.$1, m.$2, m.$3);
  }

  Future<void> loadKnowledgeBases(List<String> kbs, ChatSession session) async {
    sessionId = session.id;
    if (ports['autoIndex'] != null) {
      ports['autoIndex']?.send(null);
      autoIndexRequestReceive = null;
    }
    if (ports['embedding'] != null) {
      ports['embedding']?.send(null);
    }
    loadedKBs.clear();
    messagesCached.clear();
    Map<String, LLMApiService> embeddingInstances = {};
    for (var k in kbs) {
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
        //注意一下，这里是两个括号，因为传入的实际上是一个record对象
        Isolate.spawn(_embeddingWrapper, ((
          embeddingInstances,
          kbRequireVecSearch,
          bindingPort.sendPort,
        )));
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
      autoIndexRequestReceive = ReceivePort();
      //注意一下，这里是两个括号，因为传入的实际上是一个record对象
      Isolate.spawn(_autoIndexWrapper, (
        bindingPort.sendPort,
        autoIndexRequestReceive!.sendPort,
        airs,
        session,
      ));
      loadedAgentId = session.agentId;
      autoIndexRequestReceive?.listen((data) {});
    }
  }

  static void _autoIndexWrapper(dynamic m) {
    autoIndex(m.$1, m.$2, m.$3, m.$4);
  }

  List<FormattedChatMessage> messagesCached = [];
  //将关键词命中的消息直接缓存起来不需再次
  Future<List<FormattedChatMessage>> onUserNewMessageCall(
    ChatMessage newContent,
  ) async {
    var rp = ReceivePort();
    //获取嵌入
    if (kbRequireVecSearch.isNotEmpty) {
      if (!ports.containsKey('embedding')) {
        //如果没初始化，那就等一秒钟，如果还没有那就肯定出问题了
        await Future.delayed(const Duration(seconds: 1));
        if (!ports.containsKey('embedding')) {
          print("error");
          return [];
        }
      }
      ports['embedding']!.send((newContent.content, rp.sendPort));
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
      var r = await rp.first as IsolateProcessResult<Map<String, List<double>>>;
      if (r.error != null && !r.isFinished) {
        throw r.error ?? "A Embedding Error";
      }
      var embR = r.result!;
      rp.close();
      var cid = <String>[];
      for (var v in kbRequireVecSearch) {
        var q = embR["${v.modelConfigId}+${v.vectorDimension}"];
        if (q == null) continue;
        //TODO:this should be manually set
        var vecs = await vectorDbInstances[v.id]?.vecQuery(q, 5);
        if (vecs == null) continue;
        for (var vec in vecs) {
          var cs = vec.getCosineSimilarityByVector(q);
          if (cs > COSINE_THRESHOLD) {
            cid.add(vec.getChunkId());
          }
        }
        c.addContentChunkNoRepeat(
          await RAGDatabaseManager().getManySimpleContentOfContentChunk(cid),
        );
      }
    }
    var m = [
      ...messagesCached,
      ...c.contentChunk.values.map((m) => buildMessages(m)),
    ];
    print(m);
    if (ports.containsKey('autoIndex')) {
      ports['autoIndex']?.send(newContent);
    }
    return m;
  }

  /// 两个向量的语义差距小于39度
  static const double COSINE_THRESHOLD = 0.78;

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

  static void embeddingService(
    Map<String, LLMApiService> embeddingInstances,
    List<Embedding> embeddings,
    SendPort binding,
  ) {
    var rp = ReceivePort();
    binding.send(
      PortBindingRequest(fromIsolate: "embedding", sendPort: rp.sendPort),
    );
    rp.listen((m) async {
      if (m == null) {
        rp.close();
        Isolate.current.kill(priority: Isolate.immediate);
      }
      var p = m.$2 as SendPort;
      var message = (m.$1) as String;
      var embResult = <String, List<double>>{};
      for (var e in embeddings) {
        if (!embResult.containsKey("${e.modelConfigId}+${e.vectorDimension}")) {
          var ei = embeddingInstances[e.modelConfigId];
          if (ei == null) {
            throw "Embedding ${e.modelConfigId} not found";
            //这应该不可能发生
          }
          var er = await ei.embedding([message], e.vectorDimension);
          if (er.isEmpty) {
            throw "Embedding ${e.modelConfigId} failed";
          }
          if (er.first.length > e.vectorDimension) {
            er.first = er.first.sublist(0, e.vectorDimension);
          }
          embResult["${e.modelConfigId}+${e.vectorDimension}"] =
              er.first; //在消息的时候我们只会获取第一个向量（因为也只输入了一个）
        }
      }
      var r = IsolateProcessResult<Map<String, List<double>>>(
        result: embResult,
        isFinished: true,
      );
      p.send(r);
    });
  }

  void onAgentNewMessage(ChatMessage msg) {
    if (loadedAgentId == null) {
      throw "Not loaded";
    }
    ports['autoIndex']?.send(msg);
  }

  static void autoIndex(
    SendPort binding,
    SendPort send,
    List<AutoIndexRule> rules,
    ChatSession session,
    //TODO: 在现在这没问题，因为我们只允许一个Regex，但是后面如果要改回允许多个regex的话，这里就要改了
  ) {
    var receive = ReceivePort();
    binding.send(
      PortBindingRequest(fromIsolate: "autoIndex", sendPort: receive.sendPort),
    );
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
              contentType: RagContentType.chatHistory,
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

  Future<void> processKnowledgeBase(KnowledgeBase kb, String activityId) async {
    if (kb.status == KnowledgeBaseStat.OK) {
      return;
    }
    var kbs = await RAGDatabaseManager().getRawOriginalContentOfBase(kb.id);
    final processResult = ReceivePort();
    var api = await ApiServiceProvider.instance.createApiService(
      kb.embeddings.first.modelConfigId,
    );
    var iso = await Isolate.spawn((param) async {
      await RagProcessor.processContent(param.$1, param.$2, param.$3, param.$4);
    }, (kb, kbs, api, processResult.sendPort));
    processResult.listen((data) async {
      var result = data as ContentProcessResult;
      //整个都用事务包裹，保证统一
      await PathProvider.getPath("RAG/VectorSearch/${kb.embeddings.first.id}");

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
        ref
            .read(activityProvider.notifier)
            .onActivityError(activityId, result.onError ?? "Error");
      }
      if (result.isFullyFinished && result.onError == null) {
        await RAGDatabaseManager().setBaseOk(kb.id);
        ref.read(activityProvider.notifier).onActivityComplete(activityId);
        processResult.close();
        iso.kill();
      }
    });
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
