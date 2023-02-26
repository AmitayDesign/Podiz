import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/data/user_repository.dart';
import 'package:podiz/src/routing/app_router.dart';

class FollowingTile extends ConsumerWidget {
  const FollowingTile(this.userId, {Key? key}) : super(key: key);

  final String userId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(userFutureProvider(userId));
    final currentUser = ref.read(authRepositoryProvider).currentUser!;
    print(currentUser);
    return user.maybeWhen(
      orElse: () => Container(color: Colors.red),
      data: (user) => ListTile(
        onTap: () => context
            .pushNamed(AppRoute.profile.name, params: {'userId': user.id}),
        leading: UserAvatar(user: user),
        title: Text(user.name),
        trailing: userId == currentUser.id
            ? Container() //I m the user
            : !currentUser.following.any((element) => element == userId)
                ? const Icon(Icons.add) //Follow
                : const Icon(Icons.read_more), //Unfollow
      ),
      loading: () => const CircularProgressIndicator(), //TODO shimmer effect
    );
  }
}
