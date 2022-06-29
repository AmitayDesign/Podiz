import 'package:podiz/objects/AuthorizationModel.dart';
import 'package:podiz/onboarding/logic/AuthorizationApiProvider.dart';
import 'package:podiz/onboarding/logic/AuthorizationTokenApiProvider.dart';

class RepositoryAuthorization {
  final authorizationCodeApiProvider = AuthorizationApiProvider();
  final authorizationTokenApiProvider = AuthorizationTokenApiProvider();
  Future<String> fetchAuthorizationCode() =>
      authorizationCodeApiProvider.fetchCode();
  Future<String> fetchAuthorizationToken(String code) =>
      authorizationTokenApiProvider.fetchToken(code);
}
