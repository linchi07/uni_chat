import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_chat/Chat/chat_models.dart';
import 'package:uni_chat/utils/database_service.dart';

import '../utils/file_utils.dart';

enum PersonaEntryMode { alwaysInsert, whenEnoughContext, whenHitKeyWords }

class PersonaDataEntry {
  String name;
  String content;
  PersonaEntryMode entryMode;
  PersonaDataEntry({
    required this.name,
    required this.entryMode,
    required this.content,
  });
  Map<String, dynamic> toMap() {
    return {'name': name, 'entry_mode': entryMode.index, 'content': content};
  }

  factory PersonaDataEntry.fromMap(Map<String, dynamic> map) {
    return PersonaDataEntry(
      name: map['name'] as String,
      entryMode: PersonaEntryMode.values[map['entry_mode']],
      content: map['content'],
    );
  }
}

class Persona {
  final String id;
  final String name;
  final String content;
  final Map<String, PersonaDataEntry> data;
  bool isDefault;
  Persona({
    required this.id,
    required this.name,
    required this.content,
    required this.data,
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

  FormattedChatMessage getPersonaMessage() {
    String dataToString = "关于$name的一些数据：\n";
    for (var entry in data.values) {
      dataToString = '$dataToString${entry.name}:${entry.content}.\n';
    }
    var msgContent = "用户的名字是$name，$content,$dataToString";
    return FormattedChatMessage(
      type: ChatMessageType.text,
      id: "persona",
      sender: MessageSender.system,
      content: msgContent,
    );
  }

  // 转换为数据库可接受的 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'content': content,
      // 将 Dart Map 转换为 JSON 字符串存储，需要先将 PersonaDataEntry 转换为 Map
      'data': json.encode(
        data.map((key, value) => MapEntry(key, value.toMap())),
      ),
      // 将 Dart bool 转换为 SQLite INTEGER
      'is_default': isDefault ? 1 : 0,
    };
  }

  // 从数据库 Map 创建 Persona 对象
  factory Persona.fromMap(Map<String, dynamic> map) {
    return Persona(
      id: map['id'] as String,
      name: map['name'] as String,
      content: map['content'] as String,
      // 将 JSON 字符串解析为 Dart Map，并将每个 Map 转换回 PersonaDataEntry
      data: map['data'] != null
          ? Map<String, PersonaDataEntry>.from(
              json
                  .decode(map['data'])
                  .map(
                    (key, value) => MapEntry(
                      key,
                      PersonaDataEntry.fromMap(
                        Map<String, dynamic>.from(value),
                      ),
                    ),
                  ),
            )
          : {},
      // 将 SQLite INTEGER 转换为 Dart bool
      isDefault: map['is_default'] == 1,
    );
  }

  Persona copyWith({
    String? id,
    String? name,
    String? content,
    bool? isDefault,
    Map<String, PersonaDataEntry>? data,
  }) {
    return Persona(
      id: id ?? this.id,
      name: name ?? this.name,
      content: content ?? this.content,
      isDefault: isDefault ?? this.isDefault,
      data: data ?? this.data,
    );
  }
}

class PersonaProvider extends StateNotifier<Persona> {
  PersonaProvider() : super(Persona(id: '', name: '', content: '', data: {})) {
    //这里先创建一个初始值，然后后台异步获取数据，并更新state，不等待不阻塞
    loadDefaultPersona();
  }
  void loadDefaultPersona() async {
    await DatabaseService.instance.getDefaultPersona().then((persona) {
      if (persona == null) {
        return;
      }
      state = persona;
    });
  }

  Future<void> loadPersonaById(String id) async {
    var p = await DatabaseService.instance.getPersonaById(id);
    if (p == null) {
      return;
    }
    state = p;
  }

  void setPersona(Persona persona) {
    state = persona;
  }
}

final personaProvider = StateNotifierProvider<PersonaProvider, Persona>(
  (ref) => PersonaProvider(),
);
