import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:http/http.dart' show Client;
import 'dart:convert';

import 'package:podiz/objects/AuthorizationModel.dart';

class AuthorizationTokenApiProvider {
  Client client = Client();

  Future<String> fetchToken(String code) async {
    HttpsCallableResult result = await FirebaseFunctions.instance
        .httpsCallable("getAccessTokenWithCode")
        .call({"code": code});

    return result.data;
  }
}
