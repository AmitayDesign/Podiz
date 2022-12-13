// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppUser with EquatableMixin {
  final String id;
  final String name;
  final String? email;
  final String? imageUrl;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.imageUrl,
  });

  static AppUser? fromAuth(User? user) => user == null
      ? null
      : AppUser(
          id: user.uid,
          name: user.displayName ?? '',
          email: user.email,
          imageUrl: user.photoURL,
        );

  @override
  List<Object> get props => [id];
}
