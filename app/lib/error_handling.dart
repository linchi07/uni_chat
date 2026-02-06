import 'package:flutter/widgets.dart';
abstract class AppException implements Exception{
  final AppException? ancestor;
  const AppException({this.ancestor});
  
  String unwrapAndGetMessage(BuildContext context);
  
  String onRecursiveUnwrapAndGetMessage(BuildContext context);
}


enum AgentExceptionType{
  agentNotFound,
  failLoadingAgent_UnknownError,
  failLoadingAgent_ParseError,
}
extension AgentExceptionTypeExt on AgentExceptionType{
  String getI18n(BuildContext context){
    switch(this){
      case AgentExceptionType.agentNotFound:
        return "Agent not found";
      case AgentExceptionType.failLoadingAgent_UnknownError:
        return "Fail loading agent: Unknown error";
      case AgentExceptionType.failLoadingAgent_ParseError:
        return "Fail loading agent: Parse error";
    }
  }
}
@immutable
class AgentException extends AppException {
  final AgentExceptionType error;
  const AgentException(this.error,{super.ancestor});

  @override
  String unwrapAndGetMessage(BuildContext context) {
    // TODO: implement unwrapAndGetMessage
    throw UnimplementedError();
  }
  
  @override
  String onRecursiveUnwrapAndGetMessage(BuildContext context) {
    // TODO: implement onRecursiveUnwrapAndGetMessage
    throw UnimplementedError();
  }
}

enum PersonaExceptionType{
  personaNotFound,
  failLoadingPersona_UnknownError,
  failLoadingPersona_ParseError,
}

extension PersonaExceptionTypeExt on PersonaExceptionType{
  String getI18n(BuildContext context){
    switch(this){
      case PersonaExceptionType.personaNotFound:
        return "Persona not found";
      case PersonaExceptionType.failLoadingPersona_UnknownError:
        return "Fail loading persona: Unknown error";
      case PersonaExceptionType.failLoadingPersona_ParseError:
        return "Fail loading persona: Parse error";
    }
  }
}

@immutable
class PersonaException extends AppException {
  final PersonaExceptionType error;
  const PersonaException(this.error,{super.ancestor});

  @override
  String unwrapAndGetMessage(BuildContext context) {
    // TODO: implement unwrapAndGetMessage
    throw UnimplementedError();
  }
  
  @override
  String onRecursiveUnwrapAndGetMessage(BuildContext context) {
    // TODO: implement
    throw UnimplementedError();
  }
}

enum ApiExceptionType{
  providerNotFound,
  modelNotAvailableForProvider,
  modelNotFound,
  
  request_timeout,
  request_badRequest,
  request_emptyBody,
  request_apiFail,
  request_other,
  
  apikey_noAvailableKeys,
}

extension ApiExceptionTypeExt on ApiExceptionType{
  String getI18n(BuildContext context){
    switch(this){
      case ApiExceptionType.providerNotFound:
        return "Provider not found";
      case ApiExceptionType.modelNotAvailableForProvider:
        return "Model not available for provider";
      case ApiExceptionType.modelNotFound:
        return "Model not found";
      case ApiExceptionType.request_timeout:
        return "Request timeout";
      case ApiExceptionType.request_badRequest:
      case ApiExceptionType.request_emptyBody:
        // TODO: Handle this case.
        throw UnimplementedError();
      case ApiExceptionType.request_apiFail:
        // TODO: Handle this case.
        throw UnimplementedError();
      case ApiExceptionType.request_other:
        // TODO: Handle this case.
        throw UnimplementedError();
      case ApiExceptionType.apikey_noAvailableKeys:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}

@immutable
class ApiException extends AppException {
  final ApiExceptionType error;
  final String? message;
  const ApiException(this.error,{this.message,super.ancestor});

  @override
  String unwrapAndGetMessage(BuildContext context) {
    // TODO: implement unwrapAndGetMessage
    throw UnimplementedError();
  }
  
  @override
  String onRecursiveUnwrapAndGetMessage(BuildContext context) {
    // TODO: implement
    throw UnimplementedError();
  }
}


