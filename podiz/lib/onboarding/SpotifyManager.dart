import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/authentication/auth_manager.dart';
import 'package:podiz/onboarding/logic/Repository.dart';
import 'package:podiz/providers.dart';

final spotifyManagerProvider = Provider<SpotifyManager>(
  (ref) => SpotifyManager(ref.read),
);

class SpotifyManager {
  final Reader _read;
  SpotifyManager(this._read);

  FirebaseFirestore get firestore => _read(firestoreProvider);
  AuthManager get authManager => _read(authManagerProvider);

  final _repository = RepositoryAuthorization();

  // final PublishSubject _authorizationTokenFetcher = PublishSubject<String>();
  // final PublishSubject _authorizationCodeFetcher = PublishSubject<String>();

  // Stream<dynamic> get authorizationCode => _authorizationCodeFetcher.stream;
  // Stream<dynamic> get authorizationToken => _authorizationTokenFetcher.stream;

  Future<String> fetchAuthorizationCode() {
    return _repository.fetchAuthorizationCode();
    // _authorizationCodeFetcher.sink.add(code);
  }

  Future<String> fetchAuthorizationToken(String code) {
    return _repository.fetchAuthorizationToken(code);
    // _authorizationTokenFetcher.sink.add(authorizationModel);
  }

  // disposeCode() {
  //   _authorizationCodeFetcher.close();
  // }

  // disposeToken() {
  //   _authorizationTokenFetcher.close();
  // }
}
