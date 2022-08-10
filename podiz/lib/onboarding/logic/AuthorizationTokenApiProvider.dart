import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:http/http.dart' show Client;

class AuthorizationTokenApiProvider {
  Client client = Client();

  Future<String> fetchToken(String code) async {
    HttpsCallableResult result = await FirebaseFunctions.instance
        .httpsCallable("getAccessTokenWithCode")
        .call({"code": code});

    final String token = result.data;

    if (token == '0') {
      throw Exception(
        'Something went wrong, check your internet connection or try again later!',
      );
    }
    return token;
  }
}
