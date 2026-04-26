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

const String INSTANT_AGENT_ID = '@instant';

@immutable
class ModelConfigure {
  final String modelId;
  final String providerId;

  final int maxGenerationTokens;
  final int maxContextTokens;

  //parameters (such as temperature)
  final Map<ModelParamName, dynamic> customParameters;

  final ThinkingMode thinkingMode;

  // basic info pass
  final bool enableTimeTelling;
  final bool enableUsrLanguage;
  final bool enableUsrSystemInformation;

  const ModelConfigure({
    required this.modelId,
    required this.providerId,
    this.maxGenerationTokens = 2560,
    this.maxContextTokens = 1000000000,
    this.customParameters = const {},
    this.thinkingMode = ThinkingMode.defaultMode,
    this.enableTimeTelling = true,
    this.enableUsrLanguage = true,
    this.enableUsrSystemInformation = true,
  });

  ModelConfigure copyWith({
    String? modelId,
    String? providerId,
    int? maxGenerationTokens,
    int? maxContextTokens,
    Map<ModelParamName, dynamic>? customParameters,
    ThinkingMode? thinkingMode,
    bool? enableTimeTelling,
    bool? enableUsrLanguage,
    bool? enableUsrSystemInformation,
  }) {
    return ModelConfigure(
      modelId: modelId ?? this.modelId,
      providerId: providerId ?? this.providerId,
      maxGenerationTokens: maxGenerationTokens ?? this.maxGenerationTokens,
      maxContextTokens: maxContextTokens ?? this.maxContextTokens,
      customParameters: customParameters ?? this.customParameters,
      thinkingMode: thinkingMode ?? this.thinkingMode,
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
      'custom_parameters': customParameters.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'thinking_mode': thinkingMode.name,
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
    Map<ModelParamName, dynamic> params = {};
    if (map.containsKey('custom_parameters')) {
      var cp = map['custom_parameters'] as Map<String, dynamic>;
      cp.forEach((key, value) {
        try {
          params[ModelParamName.values.byName(key)] = value;
        } catch (e) {
          // Ignore unknown parameters
        }
      });
    }

    ThinkingMode tMode = ThinkingMode.defaultMode;
    if (map.containsKey('thinking_mode')) {
      try {
        tMode = ThinkingMode.values.byName(map['thinking_mode'] as String);
      } catch (_) {}
    }

    return ModelConfigure(
      modelId: map['model_id'] as String,
      providerId: map['provider_id'] as String,
      maxGenerationTokens: map['max_generation_tokens'] as int,
      maxContextTokens: map['max_context_tokens'] as int,
      customParameters: params,
      thinkingMode: tMode,
      enableTimeTelling: map['enable_time_telling'] as bool? ?? true,
      enableUsrLanguage: map['enable_usr_language'] as bool? ?? true,
      enableUsrSystemInformation: map['enable_usr_system_information'] as bool? ?? true,
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

  AgentData copyWith({
    int? version,
    String? id,
    String? name,
    String? description,
    String? systemPrompt,
    ModelConfigure? modelConfigure,
    PersonaConfigure? userIdentityConfigure,
    OpeningConfigure? openingConfigure,
    DateTime? createdAt,
    bool? isDefault,
  }) {
    return AgentData(
      version: version ?? this.version,
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      modelConfigure: modelConfigure ?? this.modelConfigure,
      userIdentityConfigure:
          userIdentityConfigure ?? this.userIdentityConfigure,
      openingConfigure: openingConfigure ?? this.openingConfigure,
      createdAt: createdAt ?? this.createdAt,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toConfigureMap() {
    return {
      'version': CURRENT_AGENT_DATA_VERSION,
      'model_configure': modelConfigure.toMap(),
      'persona_configure': userIdentityConfigure?.toMap(),
      'opening_configure': openingConfigure?.toMap(),
      'system_prompt': systemPrompt,
    };
  }

  AgentData applyOverride(String overrideJson) {
    try {
      final Map<String, dynamic> overrides = jsonDecode(overrideJson);

      PersonaConfigure? uidc;
      var uidcp = overrides['persona_configure'];
      if (uidcp != null) {
        uidc = PersonaConfigure.fromMap(uidcp);
      }

      OpeningConfigure? opc;
      var opcp = overrides['opening_configure'];
      if (opcp != null) {
        opc = OpeningConfigure.fromMap(opcp);
      }

      return copyWith(
        systemPrompt: overrides['system_prompt'] as String?,
        modelConfigure: ModelConfigure.fromMap(overrides['model_configure']),
        userIdentityConfigure: uidc,
        openingConfigure: opc,
      );
    } catch (e) {
      // If parsing fails, return original data
      return this;
    }
  }

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
    return jsonEncode(toConfigureMap());
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
