import 'package:flutter/cupertino.dart';

@immutable
class Version {
  final String identifier;
  final int version;

  const Version(this.identifier, this.version);

  Map<String, dynamic> toMap() {
    return {'identifier': identifier, 'version': version};
  }

  factory Version.fromMap(Map<String, dynamic> map) {
    return Version(map['identifier'], map['version']);
  }
}
