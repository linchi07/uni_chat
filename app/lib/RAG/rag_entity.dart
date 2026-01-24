/*



// ignore_for_file: prefer_final_fields

import 'dart:convert';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:objectbox/objectbox.dart';

import '../generated/l10n.dart';

enum RAGIndexMethod { vector, keyword, regex }

enum KnowledgeBaseStat { OK, pending }

extension KnowledgeBaseStatExtension on KnowledgeBaseStat {
  String getName(BuildContext context) {
    switch (this) {
      case KnowledgeBaseStat.OK:
        return S.of(context).base_stat_OK;
      case KnowledgeBaseStat.pending:
        return S.of(context).base_stat_PENDING;
    }
  }
}

class KnowledgeBase {
  final String id;
  final String name;
  final String description;
  final Set<RAGIndexMethod> defaultIndexMethod;
  final List<Embedding> embeddings;
  final DateTime createdAt;
  KnowledgeBaseStat status;

  KnowledgeBase({
    required this.id,
    required this.name,
    required this.description,
    required this.defaultIndexMethod,
    required this.embeddings,
    required this.createdAt,
    this.status = KnowledgeBaseStat.pending,
  });

  factory KnowledgeBase.fromMap(Map<String, dynamic> map) {
    final List<String> methodStrings =
        (jsonDecode(map['default_index_method']) as List).cast<String>();
    return KnowledgeBase(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      defaultIndexMethod: methodStrings.map((methodString) {
        // 2. 查找匹配的枚举值
        return RAGIndexMethod.values.firstWhere(
          (element) => element.toString() == methodString,
        );
      }).toSet(),
      embeddings: jsonDecode(
        map['embeddings'],
      ).map<Embedding>((embedding) => Embedding.fromMap(embedding)).toList(),
      createdAt: DateTime.parse(map['created_at']),
      status: KnowledgeBaseStat.values.firstWhere(
        (element) => element.toString() == map['status'],
      ),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'default_index_method': jsonEncode(
        defaultIndexMethod.map((method) => method.toString()).toList(),
      ),
      'embeddings': jsonEncode(
        embeddings.map((embedding) => embedding.toMap()).toList(),
      ),
      'created_at': createdAt.toIso8601String(),
      'status': status.toString(),
    };
  }
}

class Embedding {
  final String id;
  final String modelConfigId;
  final String knowledgeBaseId;
  final String embeddingModelName;
  final int vectorDimension;

  Embedding({
    required this.id,
    required this.modelConfigId,
    required this.knowledgeBaseId,
    required this.embeddingModelName,
    required this.vectorDimension,
  });

  factory Embedding.fromMap(Map<String, dynamic> map) {
    return Embedding(
      id: map['id'],
      modelConfigId: map['model_config_id'],
      knowledgeBaseId: map['knowledge_base_id'],
      embeddingModelName: map['embedding_model_name'],
      vectorDimension: map['vector_dimension'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'model_config_id': modelConfigId,
      'knowledge_base_id': knowledgeBaseId,
      'embedding_model_name': embeddingModelName,
      'vector_dimension': vectorDimension,
    };
  }
}

//真的是一个蠢的要死的数据库
//必须使用这种曲线救国的方法才能继承
//你猜啥？ObjectBox - Entity Super Classes
// Only available for Java/Kotlin at the moment
// 哦，太厉害了，我们用 compose multi platform 重写一遍吧
//这个数据库我都不敢存具体的文件只是拿来放向量
//还是sqlite靠谱，我曾经一直以为nosql都能够像mongo那样存文件的。。。。
//你知道我为了通过编译花了多久嘛？直接继承-不行！用getter setter不行！
//用普通函数 不行！ 哦 原来不能有私有的属性 哇你太厉害了！
//以及在macOS下：https://github.com/objectbox/objectbox-dart/issues/248
//Sandboxed macOS apps To use ObjectBox in a sandboxed macOS app, create an app group and pass the ID to macosApplicationGroup. Note: due to limitations in macOS the ID can be at most 19 characters long. By convention, the ID is <Developer team ID>.<group name>. You can verify the ID is correctly configured, by checking that the macos/ Runner/*.entitlements files contain the relevant key and value, for example: <dict> <key>com. apple. security. application-groups</ key> <array> <string>FGDTDLOBXDJ. demo</ string> </ array> </ dict> This is required to enable additional interprocess communication (IPC), like POSIX semaphores, used by mutexes in the ObjectBox database library for macOS. Specifically, macOS requires that semaphore names are prefixed with an application group ID.
//这个问题在官方文档下完全没有说明，就在create store的注释的最底下那里稍微提了一嘴。。。
//真的是垃圾，很难有一个数据库能够rang wo
abstract class VectorQueryObject {
  int? getId();
  String getChunkId();
  List<double> getEmbedding();
  void setEmbedding(List<double> embedding);
  int dimensions();

  ///获取余弦相似度
  double getCosineSimilarity(VectorQueryObject other) {
    //当gemini给我提到这个公式的时候我居然问他这是不是数量投影！
    //要是我亲爱的数学老师看到我做了这么多的立体几何能够问出这么蠢的问题
    //我估计她得哭死
    var vecThis = getEmbedding();
    var vecO = other.getEmbedding();
    if (vecThis.length != vecO.length || vecThis.isEmpty) {
      // 向量长度必须相同且非空
      return 0.0;
    }
    double dotProduct = 0.0;
    double magnitudeA = 0.0;
    double magnitudeB = 0.0;

    // 1. 计算点积 (Dot Product) 和各自的模 (Magnitude)
    for (int i = 0; i < vecThis.length; i++) {
      dotProduct += vecThis[i] * vecO[i];
      magnitudeA += vecThis[i] * vecThis[i]; // A的平方和
      magnitudeB += vecO[i] * vecO[i]; // B的平方和
    }

    // 2. 计算模的开方 (L2 Norm / Magnitude)
    final double magA = sqrt(magnitudeA);
    final double magB = sqrt(magnitudeB);

    if (magA == 0.0 || magB == 0.0) {
      // 避免除以零
      return 0.0;
    }
    // 3. 计算余弦相似度
    return dotProduct / (magA * magB);
  }

  ///获取余弦相似度
  double getCosineSimilarityByVector(List<double> vecOther) {
    //当gemini给我提到这个公式的时候我居然问他这是不是数量投影！
    //要是我亲爱的数学老师看到我做了这么多的立体几何能够问出这么蠢的问题
    //我估计她得哭死
    var vecThis = getEmbedding();
    if (vecThis.length != vecOther.length || vecThis.isEmpty) {
      // 向量长度必须相同且非空
      return 0.0;
    }
    double dotProduct = 0.0;
    double magnitudeA = 0.0;
    double magnitudeB = 0.0;

    // 1. 计算点积 (Dot Product) 和各自的模 (Magnitude)
    for (int i = 0; i < vecThis.length; i++) {
      dotProduct += vecThis[i] * vecOther[i];
      magnitudeA += vecThis[i] * vecThis[i]; // A的平方和
      magnitudeB += vecOther[i] * vecOther[i]; // B的平方和
    }

    // 2. 计算模的开方 (L2 Norm / Magnitude)
    final double magA = sqrt(magnitudeA);
    final double magB = sqrt(magnitudeB);

    if (magA == 0.0 || magB == 0.0) {
      // 避免除以零
      return 0.0;
    }
    // 3. 计算余弦相似度
    return dotProduct / (magA * magB);
  }

  VectorQueryObject();
}

@Entity()
class VectorQueryObject384 extends VectorQueryObject {
  @Id(assignable: false)
  int? id;
  String chunkId;
  @HnswIndex(dimensions: 384, distanceType: VectorDistanceType.cosine)
  @Property(type: PropertyType.floatVector)
  List<double> embedding;

  VectorQueryObject384({
    this.id,
    required this.chunkId,
    required this.embedding,
  });

  @override
  int? getId() => id;

  @override
  String getChunkId() => chunkId;

  @override
  List<double> getEmbedding() => embedding;

  @override
  void setEmbedding(List<double> embedding) {
    this.embedding = embedding;
  }

  @override
  int dimensions() => 384;
}

@Entity()
class VectorQueryObject768 extends VectorQueryObject {
  @Id(assignable: false)
  int? id;
  String chunkId;
  @HnswIndex(dimensions: 768, distanceType: VectorDistanceType.cosine)
  @Property(type: PropertyType.floatVector)
  List<double> embedding;

  VectorQueryObject768({
    this.id,
    required this.chunkId,
    required this.embedding,
  });

  @override
  int? getId() => id;

  @override
  String getChunkId() => chunkId;

  @override
  List<double> getEmbedding() => embedding;

  @override
  void setEmbedding(List<double> embedding) {
    this.embedding = embedding;
  }

  @override
  int dimensions() => 768;
}

@Entity()
class VectorQueryObject1024 extends VectorQueryObject {
  @Id(assignable: false)
  int? id;
  String chunkId;
  @HnswIndex(dimensions: 1024, distanceType: VectorDistanceType.cosine)
  @Property(type: PropertyType.floatVector)
  List<double> embedding;

  VectorQueryObject1024({
    this.id,
    required this.chunkId,
    required this.embedding,
  });

  @override
  int? getId() => id;

  @override
  String getChunkId() => chunkId;

  @override
  List<double> getEmbedding() => embedding;

  @override
  void setEmbedding(List<double> embedding) {
    this.embedding = embedding;
  }

  @override
  int dimensions() => 1024;
}

@Entity()
class VectorQueryObject1536 extends VectorQueryObject {
  @Id(assignable: false)
  int? id;
  String chunkId;
  @HnswIndex(dimensions: 1536, distanceType: VectorDistanceType.cosine)
  @Property(type: PropertyType.floatVector)
  List<double> embedding;

  VectorQueryObject1536({
    this.id,
    required this.chunkId,
    required this.embedding,
  });

  @override
  int? getId() => id;

  @override
  String getChunkId() => chunkId;

  @override
  List<double> getEmbedding() => embedding;

  @override
  void setEmbedding(List<double> embedding) {
    this.embedding = embedding;
  }

  @override
  int dimensions() => 1536;
}

@Entity()
class VectorQueryObject2048 extends VectorQueryObject {
  @Id(assignable: false)
  int? id;
  String chunkId;
  @HnswIndex(dimensions: 2048, distanceType: VectorDistanceType.cosine)
  @Property(type: PropertyType.floatVector)
  List<double> embedding;

  VectorQueryObject2048({
    this.id,
    required this.chunkId,
    required this.embedding,
  });

  @override
  int? getId() => id;

  @override
  String getChunkId() => chunkId;

  @override
  List<double> getEmbedding() => embedding;

  @override
  void setEmbedding(List<double> embedding) {
    this.embedding = embedding;
  }

  @override
  int dimensions() => 2048;
}

//虽然叫做content chunk但是基本上只为了向量搜索服务
class ContentChunk {
  final String id;
  final String knowledgeBaseId;
  final String originalContentId;
  final String content;
  final int hash;
  final Map<String, String> chunkMetadata;
  ContentChunk({
    required this.id,
    required this.knowledgeBaseId,
    required this.originalContentId,
    required this.hash,
    required this.content,
    required this.chunkMetadata,
  });

  factory ContentChunk.fromMap(Map<String, dynamic> json) {
    return ContentChunk(
      id: json['id'],
      knowledgeBaseId: json['knowledge_base_id'],
      originalContentId: json['original_content_id'],
      hash: json['hash'],
      content: json['content'],
      chunkMetadata: json['chunk_metadata'] != null
          ? (jsonDecode(json['chunk_metadata']) as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, value.toString()),
            )
          : {},
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'knowledge_base_id': knowledgeBaseId,
      'original_content_id': originalContentId,
      'hash': hash,
      'content': content,
      'chunk_metadata': jsonEncode(chunkMetadata),
    };
  }
}

enum RagContentType { document, website, memory, chatHistory }

class OriginalContent {
  final String id;
  final String knowledgeBaseId;
  String keyWords;
  late final List<String> regex;
  int? hash;
  final String content;
  final DateTime insertedAt;
  final Set<RAGIndexMethod> indexMethod;
  final MetaData metadata;
  final RagContentType contentType;
  bool isEmbedded;
  bool isTokenized;
  OriginalContent({
    required this.id,
    required this.knowledgeBaseId,
    this.hash,
    required this.content,
    required this.insertedAt,
    required this.indexMethod,
    required this.contentType,
    required this.metadata,
    this.isEmbedded = false,
    this.keyWords = "",
    List<String>? regex,
    this.isTokenized = false,
  }) {
    this.regex = regex ?? [];
  }

  OriginalContent copyWith({
    String? id,
    String? knowledgeBaseId,
    int? hash,
    String? keyWords,
    String? content,
    DateTime? insertedAt,
    Set<RAGIndexMethod>? indexMethod,
    RagContentType? contentType,
    MetaData? metadata,
    bool? isEmbedded,
    List<String>? regex,
  }) {
    return OriginalContent(
      id: id ?? this.id,
      knowledgeBaseId: knowledgeBaseId ?? this.knowledgeBaseId,
      keyWords: keyWords ?? this.keyWords,
      hash: hash ?? this.hash,
      content: content ?? this.content,
      insertedAt: insertedAt ?? this.insertedAt,
      indexMethod: indexMethod ?? this.indexMethod,
      contentType: contentType ?? this.contentType,
      metadata: metadata ?? this.metadata,
      isEmbedded: isEmbedded ?? this.isEmbedded,
      regex: regex ?? this.regex,
      isTokenized: isTokenized,
    );
  }

  factory OriginalContent.fromMap(Map<String, dynamic> map) {
    //为了加速查询，这里使用bool而不是set转换为json的方式
    var indexMethod = <RAGIndexMethod>{};
    if (map['is_vec_index'] == 1) {
      indexMethod.add(RAGIndexMethod.vector);
    }
    if (map['is_keyword_index'] == 1) {
      indexMethod.add(RAGIndexMethod.keyword);
    }
    if (map['is_regex_index'] == 1) {
      indexMethod.add(RAGIndexMethod.regex);
    }
    return OriginalContent(
      id: map['id'],
      knowledgeBaseId: map['knowledge_base_id'],
      content: map['content'],
      hash: map['hash'],
      keyWords: map['key_words'],
      insertedAt: DateTime.parse(map['inserted_at']),
      contentType: RagContentType.values.firstWhere(
        (element) => element.toString() == map['content_type'],
      ),
      regex: map['regex'] != null
          ? (jsonDecode(map['regex']) as List<dynamic>).cast<String>()
          : null,
      indexMethod: indexMethod,
      metadata: MetaData.fromMap(jsonDecode(map['metadata'])),
      isEmbedded: map['is_embedded'] == 1,
      isTokenized: map['is_tokenized'] == 1,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'knowledge_base_id': knowledgeBaseId,
      'content': content,
      'key_words': keyWords,
      'inserted_at': insertedAt.toIso8601String(),
      'is_vec_index': indexMethod.contains(RAGIndexMethod.vector) ? 1 : 0,
      'is_keyword_index': indexMethod.contains(RAGIndexMethod.keyword) ? 1 : 0,
      'is_regex_index': indexMethod.contains(RAGIndexMethod.regex) ? 1 : 0,
      'metadata': jsonEncode(metadata.toMap()),
      'regex': jsonEncode(regex),
      'is_embedded': isEmbedded ? 1 : 0,
      'is_tokenized': isTokenized ? 1 : 0,
      'hash': hash,
      'content_type': contentType.toString(),
    };
  }
}

class MetaData {
  String? originalName;
  final String? author;
  final String? url;
  final String? description;
  final DateTime? createdAt;
  final DateTime? lastModified;
  final String? extension;
  final String? sessionId;
  final RagContentType contentType;
  late final Map<String, String> data;
  MetaData({
    this.originalName,
    this.author,
    this.url,
    this.description,
    this.createdAt,
    this.lastModified,
    this.extension,
    this.sessionId,
    required this.contentType,
    Map<String, String>? data,
  }) {
    this.data = data ?? {};
  }

  MetaData copyWith({
    String? originalName,
    String? author,
    String? url,
    String? description,
    DateTime? createdAt,
    DateTime? lastModified,
    String? extension,
    Map<String, String>? data,
    String? sessionId,
    RagContentType? contentType,
  }) {
    return MetaData(
      originalName: originalName ?? this.originalName,
      author: author ?? this.author,
      url: url ?? this.url,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      extension: extension ?? this.extension,
      data: data ?? this.data,
      sessionId: sessionId ?? this.sessionId,
      contentType: contentType ?? this.contentType,
    );
  }

  factory MetaData.fromMap(Map<String, dynamic> json) {
    return MetaData(
      originalName: json['original_name'],
      author: json['author'],
      url: json['url'],
      description: json['description'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      lastModified: json['last_modified'] != null
          ? DateTime.parse(json['last_modified'])
          : null,
      extension: json['extension'],
      data: json['data'] != null
          ? (json['data'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, value.toString()),
            )
          : {},
      sessionId: json['session_id'],
      contentType: RagContentType.values.firstWhere(
        (element) => element.toString() == json['content_type'],
      ),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'original_name': originalName,
      'author': author,
      'url': url,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'last_modified': lastModified?.toIso8601String(),
      'extension': extension,
      'data': data,
      'session_id': sessionId,
      'content_type': contentType.toString(),
    };
  }
}

enum Issuer { user, assistant, any }

enum AutoIndexMethod { regex, keyword, always }

class AutoIndexRule {
  final String id;
  final String knowledgeBaseId;
  List<String> agents;
  final Set<RAGIndexMethod> ragIndexMethod;
  AutoIndexMethod autoIndexMethod;
  String? keyword;
  //Issuer? issuer;
  List<String>? regex;
  AutoIndexRule({
    required this.id,
    required this.knowledgeBaseId,
    required this.agents,
    required this.autoIndexMethod,
    required this.ragIndexMethod,
    this.keyword,
    //this.issuer,
    this.regex,
  });
  factory AutoIndexRule.fromMap(Map<String, dynamic> map) {
    return AutoIndexRule(
      id: map['id'],
      knowledgeBaseId: map['knowledge_base_id'],
      agents: (jsonDecode(map['agents']) as List<dynamic>).cast<String>(),
      ragIndexMethod: (jsonDecode(map['rag_index_method']) as List<dynamic>)
          .map<RAGIndexMethod>(
            (method) => RAGIndexMethod.values.firstWhere(
              (element) => element.toString() == method,
            ),
          )
          .toSet(),
      autoIndexMethod: AutoIndexMethod.values.firstWhere(
        (element) => element.toString() == map['auto_index_method'],
      ),
      keyword: map['keyword'],
      /* issuer: map['issuer'] != null
          ? Issuer.values.firstWhere(
              (element) => element.toString() == map['issuer'],
            )
          : null,*/
      regex: map['regex'] != null
          ? (jsonDecode(map['regex']) as List<dynamic>).cast<String>()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'knowledge_base_id': knowledgeBaseId,
      'agents': jsonEncode(agents),
      'rag_index_method': jsonEncode(
        ragIndexMethod.map((method) => method.toString()).toList(),
      ),
      'auto_index_method': autoIndexMethod.toString(),
      'keyword': keyword,
      //'issuer': issuer?.toString(),
      'regex': regex != null ? jsonEncode(regex) : null,
    };
  }

  RegExp? _regExp;
  RegExp? get _regexInstance {
    if (regex?.firstOrNull == null) return null;
    return _regExp ??= RegExp(regex!.first);
  }

  bool match(String text) {
    switch (autoIndexMethod) {
      case AutoIndexMethod.keyword:
        if (keyword == null || keyword!.isEmpty) return false;
        return text.contains(keyword!);
      case AutoIndexMethod.regex:
        if (_regexInstance?.hasMatch(text) ?? false) return true;
        return false;
      case AutoIndexMethod.always:
        return true;
    }
  }
}

///在rag中我们查询的时候不一定需要返回所有的数据
///这个类能够显著加速反序列化的过程
class SimpleContent {
  final String content;
  final MetaData metadata;
  final bool isContentChunk;
  final int hash;
  //这一列只是content chunk和original content之间查重
  final int? originalContentHash;

  SimpleContent({
    required this.content,
    required this.metadata,
    required this.hash,
    this.originalContentHash,
    required this.isContentChunk,
  });

  factory SimpleContent.fromOriginalContent(Map<String, dynamic> map) {
    return SimpleContent(
      content: map['content'],
      metadata: MetaData.fromMap(jsonDecode(map['metadata'])),
      hash: map['hash'],
      isContentChunk: false,
    );
  }

  factory SimpleContent.fromMapContentChunk(
    Map<String, dynamic> map,
    dynamic metadata,
    dynamic ocHash,
  ) {
    return SimpleContent(
      content: map['content'],
      metadata: MetaData.fromMap(jsonDecode(metadata)),
      hash: map['hash'],
      originalContentHash: ocHash,
      isContentChunk: true,
    );
  }
}

 */
 
 */
