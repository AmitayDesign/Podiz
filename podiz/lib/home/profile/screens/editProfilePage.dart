import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/widgets/asyncElevatedButton.dart';
import 'package:podiz/aspect/widgets/asyncElevatedButtonColor.dart';
import 'package:podiz/aspect/widgets/preferredAppBar.dart';
import 'package:podiz/authentication/AuthManager.dart';
import 'package:podiz/home/profile/components/hashtagContainer.dart';
import 'package:podiz/home/profile/components/imageInkwell.dart';
import 'package:podiz/objects/user/User.dart';


class EditProfilePage extends ConsumerStatefulWidget {
  static const route = '/editProfile';
  EditProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final user = UserPodiz("uid",
      name: "Amitay", email: "amitay@gmail.com", timestamp: DateTime.now());

  @override
  Widget build(BuildContext context) {
    final authManager = ref.read(authManagerProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: PreferredAppBar(true),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const CircleAvatar(
            radius: 80,
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            user.name,
            style: theme.textTheme.headline5,
          ),
          const SizedBox(
            height: 16,
          ),
          ImageInkwell(),
          const SizedBox(
            height: 20,
          ),
          HashtagContainerMock2(),
          SizedBox(
            height: 20,
          ),
          Text(
            "Software Engineer\nI'd rather regret the things I've done then regret the things I haven't done - Lucille Ball",
            style: theme.textTheme.bodyText1,
          ),
          Spacer(),
          AsyncElevatedButtonColor(
              color: Colors.white,
              onPressed: () {
                throw UnimplementedError();
              },
              children: [
                Icon(Icons.people),
                SizedBox(width: 5),
                Text(Locales.string(context, "invite")),
              ]),
          const SizedBox(height: 24),
          AsyncElevatedButtonColor(
              color: theme.primaryColor,
              onPressed: () {
                throw UnimplementedError();
              },
              children: [
                Icon(Icons.music_note),
                SizedBox(
                  width: 5,
                ),
                Text(Locales.string(context, "replace")),
              ]),
          const SizedBox(height: 24),
          AsyncElevatedButtonColor(
              color: Color(0xFFA21E1E),
              onPressed: () => authManager.signOut(context),
              children: [Text(Locales.string(context, "logout"))]),
          const SizedBox(height: 24),
          Text(Locales.string(context, "privacy"))
        ]),
      ),
    );
  }
}
