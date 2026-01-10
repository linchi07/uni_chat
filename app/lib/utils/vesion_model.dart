import 'package:flutter/cupertino.dart';

@immutable
class Version {
  final String identifier;
  final int version;

  const Version(this.identifier, this.version);
}
