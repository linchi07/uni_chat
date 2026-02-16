import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:uni_chat/error_handling.dart';

import '../api_configs/api_models.dart';
import '../utils/file_utils.dart';

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
    this.maxContextTokens = 4096,
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
      'default_persona': defaultPersona,
      'persona_additional_info': personaAdditionalInfo,
    };
  }

  static PersonaConfigure fromMap(Map<String, dynamic> map) {
    return PersonaConfigure(
      defaultPersona: map['default_persona'] as String?,
      personaAdditionalInfo: map['persona_additional_info'] as String?,
    );
  }
}

class AgentData {
  final int version;
  // the version of agent settings

  //basic info
  final String id;
  final String name;
  final String? description;

  final String? systemPrompt;

  final ModelConfigure modelConfigure;

  final PersonaConfigure? userIdentityConfigure;

  final DateTime createdAt;
  final bool isDefault;

  AgentData({
    required this.version,
    required this.id,
    required this.name,
    required this.modelConfigure,
    this.description,
    required this.userIdentityConfigure,
    this.systemPrompt,
    List<String>? knowledgeBases,
    required this.createdAt,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'system_prompt': systemPrompt,
      'created_at': createdAt.toIso8601String(),
      'is_default': isDefault ? 1 : 0,
    };
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
    Map<String, dynamic> parameters = {
      'version': version,
      'model_configure': modelConfigure.toMap(),
      'persona_configure': userIdentityConfigure?.toMap(),
      'system_prompt': systemPrompt,
    };
    return jsonEncode(parameters);
  }

  Map<String, dynamic> toDatabaseStorage() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'configure': _parameterToJson(),
      'created_at': createdAt.toIso8601String(),
      'is_default': isDefault ? 1 : 0,
    };
  }

  factory AgentData.fromDatabaseStorage(Map<String, dynamic> map) {
    try {
      var parameters = jsonDecode(map['configure']);
      PersonaConfigure? uidc;
      var uidcp = parameters['persona_configure'];
      if (uidcp != null) {
        uidc = PersonaConfigure.fromMap(uidcp);
      }
      return AgentData(
        version: parameters['version'] as int,
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String?,
        systemPrompt: parameters['system_prompt'] as String?,
        createdAt: DateTime.parse(map['created_at']),
        isDefault: map['is_default'] == 1,
        modelConfigure: ModelConfigure.fromMap(parameters['model_configure']),
        userIdentityConfigure: uidc,
      );
    } catch (e) {
      throw AgentException(AgentExceptionType.failLoadingAgent_ParseError);
    }
  }
}
