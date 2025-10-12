import 'dart:convert';
import 'dart:io';

import 'package:docx_to_text/docx_to_text.dart';
import 'package:flutter/foundation.dart';
import 'package:highlight/languages/d.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_community/langchain_community.dart';
import 'package:path/path.dart' as p;
import 'package:uni_chat/RAG/rag_databases.dart';
import 'package:uni_chat/RAG/rag_entity.dart';
import 'package:uni_chat/llm_provider/api_service.dart';
import 'package:uni_chat/utils/tokenizer.dart';
import 'package:uuid/uuid.dart';
import 'package:xxh3/xxh3.dart';

/// 定义一个结构体/数据类来传递所有必要的参数
class LoadParams {
  final String path;
  final String knowledgeBaseId;
  final Set<RAGIndexMethod> indexMethod;
  LoadParams(this.path, this.knowledgeBaseId, this.indexMethod);
}

enum SplitType { text, json, csv, webPage, markdown }

class RagProcessor {
  static Set<String> supportedExtensions = {"docx", 'txt', 'md'};

  /// 核心的耗时逻辑：必须是一个顶级函数或静态方法
  /// 这个函数在新 Isolate 中运行
  static Future<OriginalContent> _loadTextDocument(LoadParams params) async {
    var file = File(params.path);
    // 请确保所有在此函数内使用的依赖（如 p.basename, Uuid, docxToText 等）
    // 都是全局可访问的，并且不依赖于任何外部的类实例状态。

    var metadata = MetaData(
      originalName: p.basename(file.path),
      extension: p.extension(file.path),
      contentType: RagContentType.document,
      lastModified: await file.lastModified(),
    );
    String text;

    // 耗时的文件 I/O 和 docxToText 转换在这里执行
    switch (p.extension(file.path)) {
      case '.docx':
        final bytes = await file.readAsBytes();
        text = docxToText(bytes); // docxToText 是 CPU 密集型操作
        break; // 确保 default 语句前有 break
      default:
        text = await file.readAsString(); // readAsString 是 I/O 密集型操作
        break;
    }
    var oc = OriginalContent(
      id: Uuid().v4(),
      knowledgeBaseId: params.knowledgeBaseId,
      content: text,
      insertedAt: DateTime.now(),
      contentType: RagContentType.document,
      indexMethod: {...params.indexMethod},
      metadata: metadata,
    );
    return oc;
  }

  /// 原始函数：现在它只是一个启动后台任务的入口
  static Future<OriginalContent> loadTextDocument(
    String path,
    String knowledgeBaseId,
    Set<RAGIndexMethod> indexMethod,
  ) async {
    // 使用 compute 函数将实际的耗时工作转移到新的 Isolate
    // 这会解除 UI 线程的阻塞
    return await compute(
      _loadTextDocument,
      LoadParams(path, knowledgeBaseId, indexMethod), // 将所有参数打包成一个对象传递
    );
  }

  static Future<void> webCrawl(String url) async {
    final loader = WebBaseLoader([url]);
    final docs = await loader.load();
  }

  static Future<void> dataBaseWriteIn(List<ContentChunk> chunks) async {
    for (var chunk in chunks) {
      await RAGDatabaseManager().insertContentChunk(chunk);
    }
  }

  static Future<List<ContentChunk>> splitChunk(
    String content,
    String knowledgeBaseId,
    SplitType loaderType,
    String originalContentId,
  ) async {
    var cc = <ContentChunk>[];
    if (loaderType == SplitType.markdown) {
      List<Document> spiltDocs;
      final splitter = MarkdownHeaderTextSplitter(headersToSplitOn: []);
      spiltDocs = splitter.splitText(content);
      var uuid = Uuid();
      for (var d in spiltDocs) {
        var c = ContentChunk(
          id: uuid.v4(),
          hash: xxH3Sync(d.pageContent),
          knowledgeBaseId: knowledgeBaseId,
          originalContentId: originalContentId,
          content: d.pageContent,
          chunkMetadata: {},
        );
        cc.add(c);
      }
    } else {
      final splitter = RecursiveCharacterTextSplitter(
        chunkSize: 1000,
        chunkOverlap: 200,
      );
      var s = splitter.splitText(content);
      //TODO: add page and location based metadata
      //for now , we will stick with the ones stored in the original content
      var uuid = Uuid();
      for (var d in s) {
        var c = ContentChunk(
          id: uuid.v4(),
          hash: xxH3Sync(d),
          knowledgeBaseId: knowledgeBaseId,
          originalContentId: originalContentId,
          content: d,
          chunkMetadata: {},
        );
        cc.add(c);
      }
    }
    return cc;
  }

  static int xxH3Sync(String s) {
    return xxh3(utf8.encode(s));
  }

  static Future<int> xxH3(String s) async {
    return await compute((String s) {
      return xxh3(utf8.encode(s));
    }, s);
  }

  static Future<List<Document>> loadChunk(
    String path,
    SplitType loaderType,
    String knowledgeBaseId,
    String originalContentId,
  ) async {
    final List<Document> doc;
    switch (loaderType) {
      case SplitType.markdown:
      //markdown和text用一样的加载器
      case SplitType.text:
        final loader = TextLoader(path);
        doc = await loader.load();
        break;
      case SplitType.json:
        final loader = JsonLoader(path, jpSchema: '{}');
        doc = await loader.load();
        break;
      case SplitType.csv:
        final loader = CsvLoader(path);
        doc = await loader.load();
        break;
      case SplitType.webPage:
        final loader = WebBaseLoader([path]);
        doc = await loader.load();
        break;
    }
    return doc;
  }

  static Future<ContentProcessResult> processSingleContent(
    String knowledgeBaseId,
    int dimension,
    Map<String, dynamic> rawContent,
    LLMApiService? apiService,
  ) async {
    var tokenizer = Tokenizer();
    RegExp? chn;
    Uuid? uuid;
    TextSplitter? splitter;
    List<Exception>? exceptions;
    //在后台反序列化
    var result = ContentProcessResult();
    var content = OriginalContent.fromMap(rawContent);
    content.hash = xxH3Sync(content.content);
    //如果他需要关键词索引
    if (content.indexMethod.contains(RAGIndexMethod.keyword) &&
        !content.isTokenized) {
      await tokenizer.initJieba();
      var tk = tokenizer.zhHansTokenizeSync(content.content);
      //这里需要注意，fts5用的是row id一个int来关联，original content的主键实际上是一个int，但是对外抽象成string的
      result.writeToFts5 = (rawContent['row_id'], tk);
      content.isTokenized = true;
    }
    //如果需要向量索引
    if (content.indexMethod.contains(RAGIndexMethod.vector) &&
        !content.isEmbedded) {
      splitter ??=
          //TODO:add manual adjustment to this
          RecursiveCharacterTextSplitter(chunkSize: 1000, chunkOverlap: 100);
      var chunks = splitter.splitText(content.content);
      uuid ??= Uuid();
      var cc = <ContentChunk>[];
      for (var chunk in chunks) {
        //用v7对数据库更加友好一点
        var id = uuid.v7();
        cc.add(
          ContentChunk(
            id: id,
            knowledgeBaseId: knowledgeBaseId,
            originalContentId: content.id,
            hash: xxH3Sync(chunk),
            content: chunk,
            //TODO: implement page based metadata
            chunkMetadata: {},
          ),
        );
      }
      result.writeToContentChunkRaw = cc.map((e) => e.toMap()).toList();
      if (apiService == null) {
        throw Exception("apiService is null");
      }
      var er = await apiService.embedding(chunks, dimension);
      var vectors = <VectorQueryObject>[];
      for (int i = 0; i < er.length; i++) {
        switch (dimension) {
          case 384:
            vectors.add(
              VectorQueryObject384(
                chunkId: cc[i].id,
                embedding: matchDimensions(er[i], dimension),
              ),
            );
            break;
          case 768:
            vectors.add(
              VectorQueryObject768(
                chunkId: cc[i].id,
                embedding: matchDimensions(er[i], dimension),
              ),
            );
            break;
          case 1024:
            vectors.add(
              VectorQueryObject1024(
                chunkId: cc[i].id,
                embedding: matchDimensions(er[i], dimension),
              ),
            );
            break;
          case 1536:
            vectors.add(
              VectorQueryObject1536(
                chunkId: cc[i].id,
                embedding: matchDimensions(er[i], dimension),
              ),
            );
            break;
          case 2048:
            vectors.add(
              VectorQueryObject2048(
                chunkId: cc[i].id,
                embedding: matchDimensions(er[i], dimension),
              ),
            );
          default:
        }
      }
      content.isEmbedded = true;
      result.writeToVectorDb.addAll(vectors);
    }
    result.writeOrUpdateToOriginalContent = content.toMap();
    return result;
  }

  /*
  static Future<BatchContentProcessResult> processContent(
    String knowledgeBaseId,
    int dimension,
    List<Map<String, dynamic>> rawContent,
    LLMApiService? apiService,
  ) async {
    var tokenizer = Tokenizer();
    RegExp? chn;
    Uuid? uuid;
    TextSplitter? splitter;
    List<Exception>? exceptions;
    //在后台反序列化
    try {
      for (var item in rawContent) {
        var result = BatchContentProcessResult();
        try {
          var content = OriginalContent.fromMap(item);
          content.hash = xxH3Sync(content.content);
          //如果他需要关键词索引
          if (content.indexMethod.contains(RAGIndexMethod.keyword) &&
              !content.isTokenized) {
            await tokenizer.initJieba();
            var tk = tokenizer.zhHansTokenizeSync(content.content);
            //这里需要注意，fts5用的是row id一个int来关联，original content的主键实际上是一个int，但是对外抽象成string的
            result.rewriteToFTS5.add((item['row_id'], tk));
            content.isTokenized = true;
          }
          //如果需要向量索引
          if (content.indexMethod.contains(RAGIndexMethod.vector) &&
              !content.isEmbedded) {
            splitter ??=
                //TODO:add manual adjustment to this
                RecursiveCharacterTextSplitter(
                  chunkSize: 1000,
                  chunkOverlap: 100,
                );
            var chunks = splitter.splitText(content.content);
            uuid ??= Uuid();
            var cc = <ContentChunk>[];
            for (var chunk in chunks) {
              //用v7对数据库更加友好一点
              var id = uuid.v7();
              cc.add(
                ContentChunk(
                  id: id,
                  knowledgeBaseId: knowledgeBaseId,
                  originalContentId: content.id,
                  hash: xxH3Sync(chunk),
                  content: chunk,
                  //TODO: implement page based metadata
                  chunkMetadata: {},
                ),
              );
            }
            result.writeToContentChunkRaw = cc.map((e) => e.toMap()).toList();
            if (apiService == null) {
              throw Exception("apiService is null");
            }
            var er = await apiService.embedding(chunks, dimension);
            var vectors = <VectorQueryObject>[];
            for (int i = 0; i < er.length; i++) {
              switch (dimension) {
                case 384:
                  vectors.add(
                    VectorQueryObject384(
                      chunkId: cc[i].id,
                      embedding: matchDimensions(er[i], dimension),
                    ),
                  );
                  break;
                case 768:
                  vectors.add(
                    VectorQueryObject768(
                      chunkId: cc[i].id,
                      embedding: matchDimensions(er[i], dimension),
                    ),
                  );
                  break;
                case 1024:
                  vectors.add(
                    VectorQueryObject1024(
                      chunkId: cc[i].id,
                      embedding: matchDimensions(er[i], dimension),
                    ),
                  );
                  break;
                case 1536:
                  vectors.add(
                    VectorQueryObject1536(
                      chunkId: cc[i].id,
                      embedding: matchDimensions(er[i], dimension),
                    ),
                  );
                default:
              }
            }
            content.isEmbedded = true;
            result.writeToVectorDB.addAll(vectors);
          }
          result.updateToOriginalContent.add(content.toMap());
        } catch (eo) {
          var e = eo as Exception;
          result.isFullyFinished = false;
          exceptions ??= [];
          exceptions.add(e);
          port.send(result);
          continue;
        }
        result.isFullyFinished = false;
        port.send(result);
      }
    } catch (e) {
      port.send(
        BatchContentProcessResult(
          isFullyFinished: true,
          onError: (exceptions != null) ? exceptions.toString() : null,
        ),
      );
      return;
    }
    port.send(
      BatchContentProcessResult(
        isFullyFinished: true,
        onError: (exceptions != null) ? exceptions.toString() : null,
      ),
    );
  }
*/
  /// 匹配输入的维度
  /// 维度超出目标时截断
  /// 维度低于目标时补0
  static List<double> matchDimensions(
    List<double> dimensions,
    int targetDimensions,
  ) {
    if (dimensions.length == targetDimensions) {
      return dimensions;
    }
    if (dimensions.length > targetDimensions) {
      return dimensions.sublist(0, targetDimensions);
    }
    return List.generate(
      targetDimensions,
      (index) => dimensions.length > index ? dimensions[index] : 0,
    );
  }
}

class IsolateProcessResult<T extends Object?> {
  final T? result;
  final bool isFinished;
  final String? error;
  IsolateProcessResult({this.result, required this.isFinished, this.error});
}

class ContentProcessResult {
  late List<VectorQueryObject> writeToVectorDb;
  (int, String)? writeToFts5;
  late List<Map<String, dynamic>> writeToContentChunkRaw;
  Map<String, dynamic>? writeOrUpdateToOriginalContent;
  ContentProcessResult({
    List<VectorQueryObject>? writeToVectorDb,
    this.writeToFts5,
    List<Map<String, dynamic>>? writeToContentChunkRaw,
    this.writeOrUpdateToOriginalContent,
  }) {
    this.writeToContentChunkRaw = writeToContentChunkRaw ?? [];
    this.writeToVectorDb = writeToVectorDb ?? [];
  }
}

class BatchContentProcessResult {
  bool isFullyFinished = false;
  String? onError;
  late List<VectorQueryObject> writeToVectorDB;
  late List<Map<String, dynamic>> writeToContentChunkRaw;
  late List<Map<String, dynamic>> updateToOriginalContent;
  late List<(int, String)> rewriteToFTS5;
  BatchContentProcessResult({
    this.isFullyFinished = false,
    this.onError,
    List<VectorQueryObject>? writeToVectorDB,
    List<Map<String, dynamic>>? writeToContentChunkRaw,
    List<Map<String, dynamic>>? updateToOriginalContent,
    List<(int, String)>? rewriteToFTS5,
  }) {
    //dart似乎觉得const list不允许写，不知道哪个睿智想出来的
    this.writeToVectorDB = writeToVectorDB ?? [];
    this.writeToContentChunkRaw = writeToContentChunkRaw ?? [];
    this.updateToOriginalContent = updateToOriginalContent ?? [];
    this.rewriteToFTS5 = rewriteToFTS5 ?? [];
  }

  void addFromContentProcessResult(ContentProcessResult result) {
    if (result.writeToVectorDb.isNotEmpty) {
      writeToVectorDB.addAll(result.writeToVectorDb);
    }
    if (result.writeToContentChunkRaw.isNotEmpty) {
      writeToContentChunkRaw.addAll(result.writeToContentChunkRaw);
    }
    if (result.writeOrUpdateToOriginalContent != null) {
      updateToOriginalContent.add(result.writeOrUpdateToOriginalContent!);
    }
    if (result.writeToFts5 != null) {
      rewriteToFTS5.add(result.writeToFts5!);
    }
  }
}
