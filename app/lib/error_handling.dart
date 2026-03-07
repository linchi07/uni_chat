import 'package:flutter/widgets.dart';

import 'generated/l10n.dart';

abstract class AppException implements Exception {
  final AppException? ancestor;
  const AppException({this.ancestor});

  String unwrapAndGetMessage(BuildContext context);

  List<String> onRecursiveUnwrapAndGetMessage(BuildContext context);
}

enum ChatExceptionType {
  sessionNotFound,
  messageNotFound,
  failToSaveMessage,
  failToGenerateTitle,
  branchSessionFailed,

  modelNotSupportFileType,

  failParsingMessage,

  unknownError,
}

extension ChatExceptionTypeExt on ChatExceptionType {
  String getI18n(BuildContext context) {
    switch (this) {
      case ChatExceptionType.sessionNotFound:
        return S.of(context).chatEx_sessionNotFound;
      case ChatExceptionType.messageNotFound:
        return S.of(context).chatEx_messageNotFound;
      case ChatExceptionType.failToSaveMessage:
        return S.of(context).chatEx_failToSaveMessage;
      case ChatExceptionType.unknownError:
        return S.of(context).chatEx_unknownError;
      case ChatExceptionType.failToGenerateTitle:
        return S.of(context).chatEx_failToGenerateTitle;
      case ChatExceptionType.failParsingMessage:
        return S.of(context).chatEx_failParsingMessage;
      case ChatExceptionType.modelNotSupportFileType:
        return S.of(context).chatEx_modelNotSupportFileType;
      case ChatExceptionType.branchSessionFailed:
        return "测试";
    }
  }
}

@immutable
class ChatException extends AppException {
  final ChatExceptionType? error;
  final String? message;
  const ChatException(this.error, {this.message, super.ancestor});
  const ChatException._onlyAncestor(AppException ancestor)
    : this(null, ancestor: ancestor);
  @override
  String unwrapAndGetMessage(BuildContext context) {
    if (ancestor != null) {
      var msg = ancestor!.onRecursiveUnwrapAndGetMessage(context);
      if (msg.length == 2) {
        return "${S.of(context).chatEx}: ${S.of(context).ex_while(msg[0])},${msg[1]}";
      }
      if (msg.length >= 3) {
        return "${S.of(context).chatEx}: ${S.of(context).ex_while(msg.sublist(1, msg.length - 1).join(S.of(context).ex_and))},${msg.last}";
      }
      return "${S.of(context).chatEx}: ${msg.lastOrNull ?? S.of(context).error_occurred}";
    } else {
      return "${S.of(context).chatEx}: ${error?.getI18n(context) ?? S.of(context).error_occurred} ${((message != null) ? ":$message" : null) ?? ""}";
    }
  }

  @override
  List<String> onRecursiveUnwrapAndGetMessage(BuildContext context) {
    if (ancestor != null) {
      var ans = ancestor!.onRecursiveUnwrapAndGetMessage(context);
      return [S.of(context).chatEx_recursive_call, ...ans];
    } else {
      return [
        S.of(context).chatEx_recursive_call,
        ((message != null)
                ? ("${error?.getI18n(context)}:$message")
                : error?.getI18n(context)) ??
            S.of(context).error_occurred,
      ];
    }
  }

  factory ChatException.fromAncestor(AppException ancestor) {
    if (ancestor is ChatException) return ancestor;
    return ChatException._onlyAncestor(ancestor);
  }

  factory ChatException.fromException(Exception e) {
    return ChatException(ChatExceptionType.unknownError, message: e.toString());
  }
}

enum AgentExceptionType {
  agentNotLoaded,
  agentNotFound,
  unknownError,
  failLoadingAgent_ParseError,
}

extension AgentExceptionTypeExt on AgentExceptionType {
  String getI18n(BuildContext context) {
    switch (this) {
      case AgentExceptionType.agentNotFound:
        return S.of(context).agentEx_agentNotFound;
      case AgentExceptionType.unknownError:
        return S.of(context).agentEx_unknownError;
      case AgentExceptionType.failLoadingAgent_ParseError:
        return S.of(context).agentEx_failLoading_parse_error;
      case AgentExceptionType.agentNotLoaded:
        return S.of(context).agentEx_agentNotLoaded;
    }
  }
}

@immutable
class AgentException extends AppException {
  final AgentExceptionType? error;
  final String? message;
  const AgentException(this.error, {this.message, super.ancestor});
  const AgentException._onlyAncestor(AppException ancestor)
    : this(null, ancestor: ancestor);
  @override
  String unwrapAndGetMessage(BuildContext context) {
    if (ancestor != null) {
      var msg = ancestor!.onRecursiveUnwrapAndGetMessage(context);
      if (msg.length == 2) {
        return "${S.of(context).agentEx}: ${S.of(context).ex_while(msg[0])},${msg[1]}";
      }
      if (msg.length >= 3) {
        return "${S.of(context).agentEx}: ${S.of(context).ex_while(msg.sublist(1, msg.length - 1).join(S.of(context).ex_and))},${msg.last}";
      }
      return "${S.of(context).agentEx}: ${msg.lastOrNull ?? S.of(context).error_occurred}";
    } else {
      return "${S.of(context).agentEx}: ${error?.getI18n(context) ?? S.of(context).error_occurred} ${((message != null) ? ":$message" : null) ?? ""}";
    }
  }

  @override
  List<String> onRecursiveUnwrapAndGetMessage(BuildContext context) {
    if (ancestor != null) {
      var ans = ancestor!.onRecursiveUnwrapAndGetMessage(context);
      return [S.of(context).agentEx_recursive_call, ...ans];
    } else {
      return [
        S.of(context).agentEx_recursive_call,
        ((message != null)
                ? ("${error?.getI18n(context)}:$message")
                : error?.getI18n(context)) ??
            S.of(context).error_occurred,
      ];
      // who on hell would come up with shit codes like this?
      // well , I would
    }
  }

  factory AgentException.fromAncestor(AppException ancestor) {
    if (ancestor is AgentException) return ancestor;
    return AgentException._onlyAncestor(ancestor);
  }

  factory AgentException.fromException(Exception e) {
    return AgentException(
      AgentExceptionType.unknownError,
      message: e.toString(),
    );
  }
}

enum PersonaExceptionType {
  personaNotFound,
  unknownError,
  failLoadingPersona_ParseError,
}

extension PersonaExceptionTypeExt on PersonaExceptionType {
  String getI18n(BuildContext context) {
    switch (this) {
      case PersonaExceptionType.personaNotFound:
        return S.of(context).personaEX_personaNotFound;
      case PersonaExceptionType.unknownError:
        return S.of(context).personaEX_unknownError;
      case PersonaExceptionType.failLoadingPersona_ParseError:
        return S.of(context).personaEx_failLoading_parse_error;
    }
  }
}

@immutable
class PersonaException extends AppException {
  final PersonaExceptionType? error;
  final String? message;
  const PersonaException(this.error, {this.message, super.ancestor});
  const PersonaException._onlyAncestor(AppException ancestor)
    : this(null, ancestor: ancestor);
  @override
  String unwrapAndGetMessage(BuildContext context) {
    if (ancestor != null) {
      var msg = ancestor!.onRecursiveUnwrapAndGetMessage(context);
      if (msg.length == 2) {
        return "${S.of(context).personaEx}: ${S.of(context).ex_while(msg[0])},${msg[1]}";
      }
      if (msg.length >= 3) {
        return "${S.of(context).personaEx}: ${S.of(context).ex_while(msg.sublist(1, msg.length - 1).join(S.of(context).ex_and))},${msg.last}";
      }
      return "${S.of(context).personaEx}: ${msg.lastOrNull ?? S.of(context).error_occurred}";
    } else {
      return "${S.of(context).personaEx}: ${error?.getI18n(context) ?? S.of(context).error_occurred} ${((message != null) ? ":$message" : null) ?? ""}";
    }
  }

  @override
  List<String> onRecursiveUnwrapAndGetMessage(BuildContext context) {
    if (ancestor != null) {
      var ans = ancestor!.onRecursiveUnwrapAndGetMessage(context);
      return [S.of(context).personaEx_recursive_call, ...ans];
    } else {
      return [
        S.of(context).personaEx_recursive_call,
        ((message != null)
                ? ("${error?.getI18n(context)}:$message")
                : error?.getI18n(context)) ??
            S.of(context).error_occurred,
      ];
    }
  }

  factory PersonaException.fromAncestor(AppException ancestor) {
    if (ancestor is PersonaException) return ancestor;
    return PersonaException._onlyAncestor(ancestor);
  }
  factory PersonaException.fromException(Exception e) {
    return PersonaException(
      PersonaExceptionType.unknownError,
      message: e.toString(),
    );
  }
}

enum ApiExceptionType {
  providerNotFound,
  modelNotAvailableForProvider,
  modelNotFound,

  unknownError,

  request_timeout,
  request_badRequest,
  request_emptyBody,
  request_apiFail,
  request_other,

  apikey_noAvailableKeys,
}

extension ApiExceptionTypeExt on ApiExceptionType {
  String getI18n(BuildContext context) {
    switch (this) {
      case ApiExceptionType.providerNotFound:
        return S.of(context).apiEx_providerNotFound;
      case ApiExceptionType.modelNotAvailableForProvider:
        return S.of(context).apiEx_modelNotAvailableForProvider;
      case ApiExceptionType.modelNotFound:
        return S.of(context).apiEx_modelNotFound;
      case ApiExceptionType.request_timeout:
        return S.of(context).apiEx_request_timeout;
      case ApiExceptionType.request_badRequest:
        return S.of(context).apiEx_request_badRequest;
      case ApiExceptionType.request_emptyBody:
        return S.of(context).apiEx_request_emptyBody;
      case ApiExceptionType.request_apiFail:
        return S.of(context).apiEx_request_apiFail;
      case ApiExceptionType.request_other:
        return S.of(context).apiEx_request_other;
      case ApiExceptionType.apikey_noAvailableKeys:
        return S.of(context).apiEx_apikey_noAvailableKeys;
      case ApiExceptionType.unknownError:
        return S.of(context).apiEx_unknownError;
    }
  }
}

@immutable
class ApiException extends AppException {
  final ApiExceptionType? error;
  final String? message;
  const ApiException(this.error, {this.message, super.ancestor});

  @override
  String unwrapAndGetMessage(BuildContext context) {
    if (ancestor != null) {
      var msg = ancestor!.onRecursiveUnwrapAndGetMessage(context);
      if (msg.length == 2) {
        return "${S.of(context).apiEx}: ${S.of(context).ex_while(msg[0])},${msg[1]}";
      }
      if (msg.length >= 3) {
        return "${S.of(context).apiEx}: ${S.of(context).ex_while(msg.sublist(1, msg.length - 1).join(S.of(context).ex_and))},${msg.last}";
      }
      return "${S.of(context).apiEx}: ${msg.lastOrNull ?? S.of(context).error_occurred}";
    } else {
      return "${S.of(context).apiEx}: ${error?.getI18n(context) ?? S.of(context).error_occurred} ${((message != null) ? ":$message" : null) ?? ""}";
    }
  }

  @override
  List<String> onRecursiveUnwrapAndGetMessage(BuildContext context) {
    if (ancestor != null) {
      var ans = ancestor!.onRecursiveUnwrapAndGetMessage(context);
      return [S.of(context).apiEx_recursive_call, ...ans];
    } else {
      return [
        S.of(context).apiEx_recursive_call,
        ((message != null)
                ? ("${error?.getI18n(context)}:$message")
                : error?.getI18n(context)) ??
            S.of(context).error_occurred,
      ];
    }
  }

  factory ApiException.fromAncestor(AppException ancestor) {
    if (ancestor is ApiException) return ancestor;
    return ApiException(null, ancestor: ancestor);
  }
  factory ApiException.fromException(Exception e) {
    return ApiException(ApiExceptionType.unknownError, message: e.toString());
  }
}
