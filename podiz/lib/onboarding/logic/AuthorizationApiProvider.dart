import 'dart:async';

import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' show Client;

class AuthorizationApiProvider {
  Client client = Client();

  static String url = "https://accounts.spotify.com/authorize";
  static String client_id = "9a8daaf39e784f1c90770da4a252087f";
  static String response_type = "code";
  static String redirect_uri = "podiz:/";
  static String scope =
      "user-follow-read user-read-private user-read-email user-modify-playback-state user-read-playback-state"; //TODO change this
  static String state = "34fFs29kd09";

  String urlDireccion =
      "$url?client_id=$client_id&response_type=$response_type&redirect_uri=$redirect_uri&scope=$scope&state=$state";

  Future<String> fetchCode() async {
    //TODO web view
    final response = await FlutterWebAuth.authenticate(
        url: urlDireccion, callbackUrlScheme: "podiz");
    final error = Uri.parse(response).queryParameters['error'];
    if (error == null) {
      final code = Uri.parse(response).queryParameters['code'];
      return code!;
    } else {
      throw Exception(error);
    }
  }
}
