import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_chat/Chat/chat_models.dart';
import 'package:uni_chat/database/database_service.dart';

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

  FormattedChatMessage? getPersonaMessage() {
    if (id.isEmpty) {
      // 如果id为空，则说明这是系统创建的默认人格，不需要创建消息
      return null;
    }
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

  factory Persona.fromDBModel(PersonaDbModel dbm) {
    return Persona(
      id: dbm.id,
      name: dbm.name,
      content: dbm.content,
      data: dbm.data ?? {},
      isDefault: dbm.isDefault,
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
  PersonaProvider()
    : super(Persona(id: '', name: '默认人格', content: '', data: {})) {
    //这里先创建一个初始值，然后后台异步获取数据，并更新state，不等待不阻塞
    loadDefaultPersona();
  }
  void loadDefaultPersona() async {
    await DatabaseService.instance.getDefaultPersona().then((persona) {
      if (persona == null) {
        return;
        //如果persona为空，则直接用默认的空人格
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
