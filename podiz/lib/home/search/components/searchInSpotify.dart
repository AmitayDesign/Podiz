import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/widgets/asyncElevatedButton.dart';
import 'package:podiz/authentication/AuthManager.dart';

class SearchInSpotify extends ConsumerWidget {
  String query;
  SearchInSpotify(this.query, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return AsyncElevatedButton(
      onPressed: () => FirebaseFunctions.instance
          .httpsCallable("searchInSpotify")
          .call({
        "query": query,
        "userUid": ref.read(authManagerProvider).userBloc!.uid
      }),
      child: Text(
        Locales.string(context, "searchSpotify"),
        style: theme.textTheme.button,
      ),
    );
  }
}
