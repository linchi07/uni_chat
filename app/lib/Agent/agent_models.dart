import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:uni_chat/database/database_service.dart';
import 'package:uni_chat/error_handling.dart';

import '../api_configs/api_models.dart';
import '../utils/file_utils.dart';

const int CURRENT_MODEL_CONFIG_VERSION = 1;
const int CURRENT_PERSONA_CONFIG_VERSION = 1;
const int CURRENT_OPENING_CONFIG_VERSION = 1;
const int CURRENT_AGENT_DATA_VERSION = 1;

@immutable
class ModelConfigure {
  final String modelId;
  final String providerId;

  final int maxGenerationTokens;
  final int maxContextTokens;

  //parameters (such as temperature)
  final List<ModelParameters> parameters;

  // basic info pass
  final bool enableTimeTelling;
  final bool enableUsrLanguage;
  final bool enableUsrSystemInformation;

  const ModelConfigure({
    required this.modelId,
    required this.providerId,
    this.maxGenerationTokens = 2560,
    this.maxContextTokens = 1000000000,
    this.parameters = const [],
    this.enableTimeTelling = true,
    this.enableUsrLanguage = true,
    this.enableUsrSystemInformation = true,
  });

  ModelConfigure copyWith({
    String? modelId,
    String? providerId,
    int? maxGenerationTokens,
    int? maxContextTokens,
    List<ModelParameters>? parameters,
    bool? enableTimeTelling,
    bool? enableUsrLanguage,
    bool? enableUsrSystemInformation,
  }) {
    return ModelConfigure(
      modelId: modelId ?? this.modelId,
      providerId: providerId ?? this.providerId,
      maxGenerationTokens: maxGenerationTokens ?? this.maxGenerationTokens,
      maxContextTokens: maxContextTokens ?? this.maxContextTokens,
      parameters: parameters ?? this.parameters,
      enableTimeTelling: enableTimeTelling ?? this.enableTimeTelling,
      enableUsrLanguage: enableUsrLanguage ?? this.enableUsrLanguage,
      enableUsrSystemInformation:
          enableUsrSystemInformation ?? this.enableUsrSystemInformation,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'version': CURRENT_MODEL_CONFIG_VERSION,
      'model_id': modelId,
      'provider_id': providerId,
      'max_generation_tokens': maxGenerationTokens,
      'max_context_tokens': maxContextTokens,
      'parameters': parameters.map((e) => e.toMap()).toList(),
      'enable_time_telling': enableTimeTelling,
      'enable_usr_language': enableUsrLanguage,
      'enable_usr_system_information': enableUsrSystemInformation,
    };
  }

  factory ModelConfigure.fromMap(Map<String, dynamic> map) {
    var version = map['version'] as int? ?? 1;
    if (version > CURRENT_MODEL_CONFIG_VERSION) {
      throw AgentException(
        AgentExceptionType.versionMismatch,
        message: "Model config version mismatch: $version",
      );
    }
    return ModelConfigure(
      modelId: map['model_id'] as String,
      providerId: map['provider_id'] as String,
      maxGenerationTokens: map['max_generation_tokens'] as int,
      maxContextTokens: map['max_context_tokens'] as int,
      parameters: ModelParameters.fromMap((map['parameters'] as List)),
      enableTimeTelling: map['enable_time_telling'] as bool,
    );
  }
}

@immutable
class PersonaConfigure {
  final String? defaultPersona;
  final String? personaAdditionalInfo;

  const PersonaConfigure({this.defaultPersona, this.personaAdditionalInfo});

  PersonaConfigure copyWith({
    String? defaultPersona,
    String? personaAdditionalInfo,
  }) {
    return PersonaConfigure(
      defaultPersona: defaultPersona ?? this.defaultPersona,
      personaAdditionalInfo:
          personaAdditionalInfo ?? this.personaAdditionalInfo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'version': CURRENT_PERSONA_CONFIG_VERSION,
      'default_persona': defaultPersona,
      'persona_additional_info': personaAdditionalInfo,
    };
  }

  static PersonaConfigure? fromMap(Map<String, dynamic> map) {
    var version = map['version'] as int? ?? 1;
    if (version > CURRENT_PERSONA_CONFIG_VERSION) {
      // Non-core module, fallback to null instead of throwing
      return null;
    }
    return PersonaConfigure(
      defaultPersona: map['default_persona'] as String?,
      personaAdditionalInfo: map['persona_additional_info'] as String?,
    );
  }
}

@immutable
class OpeningConfigure {
  final String? slogan;
  final String? firstMessage;

  const OpeningConfigure({this.slogan, this.firstMessage});

  OpeningConfigure copyWith({String? slogan, String? firstMessage}) {
    return OpeningConfigure(
      slogan: slogan ?? this.slogan,
      firstMessage: firstMessage ?? this.firstMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'version': CURRENT_OPENING_CONFIG_VERSION,
      'slogan': slogan,
      'first_message': firstMessage,
    };
  }

  static OpeningConfigure? fromMap(Map<String, dynamic> map) {
    var version = map['version'] as int? ?? 1;
    if (version > CURRENT_OPENING_CONFIG_VERSION) {
      return null;
    }
    return OpeningConfigure(
      slogan: map['slogan'] as String?,
      firstMessage: map['first_message'] as String?,
    );
  }
}

class AgentData implements Insertable<AgentDbModel> {
  final int version;
  // the version of agent settings

  //basic info
  final String id;
  final String name;
  final String? description;

  final String? systemPrompt;

  final ModelConfigure modelConfigure;

  final PersonaConfigure? userIdentityConfigure;
  final OpeningConfigure? openingConfigure;

  final DateTime createdAt;
  final bool isDefault;

  AgentData({
    required this.version,
    required this.id,
    required this.name,
    required this.modelConfigure,
    this.description,
    required this.userIdentityConfigure,
    this.openingConfigure,
    this.systemPrompt,
    List<String>? knowledgeBases,
    required this.createdAt,
    this.isDefault = false,
  });

  Future<File?> getAvatar() async {
    var f = await PathProvider.getPath("chat/avatars/$id");
    var f1 = File("$f.png");
    if (await f1.exists()) {
      return f1;
    } else {
      var f2 = File("$f.jpg");
      if (await f2.exists()) {
        return f2;
      }
      var f3 = File("$f.jpeg");
      if (await f3.exists()) {
        return f3;
      }
    }
    return null;
  }

  String _parameterToJson() {
    Map<String, dynamic> parameters = {
      'version': CURRENT_AGENT_DATA_VERSION,
      'model_configure': modelConfigure.toMap(),
      'persona_configure': userIdentityConfigure?.toMap(),
      'opening_configure': openingConfigure?.toMap(),
      'system_prompt': systemPrompt,
    };
    return jsonEncode(parameters);
  }

  factory AgentData.fromAgentDBModel(AgentDbModel adbm) {
    try {
      var parameters = jsonDecode(adbm.configure);
      var topVersion = parameters['version'] as int? ?? 1;
      if (topVersion > CURRENT_AGENT_DATA_VERSION) {
        throw AgentException(
          AgentExceptionType.versionMismatch,
          message: "Agent data version mismatch: $topVersion",
        );
      }

      PersonaConfigure? uidc;
      var uidcp = parameters['persona_configure'];
      if (uidcp != null) {
        uidc = PersonaConfigure.fromMap(uidcp);
      }

      OpeningConfigure? opc;
      var opcp = parameters['opening_configure'];
      if (opcp != null) {
        opc = OpeningConfigure.fromMap(opcp);
      }

      return AgentData(
        version: topVersion,
        id: adbm.id,
        name: adbm.name,
        description: adbm.description,
        systemPrompt: parameters['system_prompt'] as String?,
        createdAt: DateTime.parse(adbm.createdAt),
        isDefault: adbm.isDefault,
        modelConfigure: ModelConfigure.fromMap(parameters['model_configure']),
        userIdentityConfigure: uidc,
        openingConfigure: opc,
      );
    } on AgentException {
      rethrow;
    } catch (e) {
      throw AgentException(
        AgentExceptionType.failLoadingAgent_ParseError,
        message: e.toString(),
      );
    }
  }

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return AgentsCompanion.insert(
      id: id,
      name: name,
      configure: _parameterToJson(),
      createdAt: createdAt.toIso8601String(), //TODO:to UNIX time
    ).toColumns(nullToAbsent);
  }
}
