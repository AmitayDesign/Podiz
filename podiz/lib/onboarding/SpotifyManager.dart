import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/src/widgets/async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/authentication/AuthManager.dart';
import 'package:podiz/objects/AuthorizationModel.dart';
import 'package:podiz/onboarding/logic/Repository.dart';
import 'package:podiz/providers.dart';
import 'package:rxdart/rxdart.dart';

final spotifyManagerProvider = Provider<SpotifyManager>(
  (ref) => SpotifyManager(ref.read),
);

class SpotifyManager {
  Reader _read;
  SpotifyManager(this._read);

  FirebaseFirestore get firestore => _read(firestoreProvider);
  AuthManager get authManager => _read(authManagerProvider);

  final _repository = RepositoryAuthorization();

  final PublishSubject _authorizationTokenFetcher = PublishSubject<String>();
  final PublishSubject _authorizationCodeFetcher = PublishSubject<String>();

  Stream<dynamic> get authorizationCode => _authorizationCodeFetcher.stream;
  Stream<dynamic> get authorizationToken => _authorizationTokenFetcher.stream;

  fetchAuthorizationCode() async {
    String code = await _repository.fetchAuthorizationCode();
    _authorizationCodeFetcher.sink.add(code);
  }

  fetchAuthorizationToken(String code) async {
    String authorizationModel = await _repository.fetchAuthorizationToken(code);
    _authorizationTokenFetcher.sink.add(authorizationModel);
  }

  disposeCode() {
    _authorizationCodeFetcher.close();
  }

  disposeToken() {
    _authorizationTokenFetcher.close();
  }

  Future<void> setUpAuthStream(AsyncSnapshot snapshot) async {
    await authManager.fetchUserInfo(snapshot.data);
    print("USERRRRRRRRRRRRRR");
  }
}
