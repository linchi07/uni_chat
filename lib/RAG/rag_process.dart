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

class DocumentLoader {
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
      lastModified: await file.lastModified(), // 这是一个异步操作，但很快
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
}
