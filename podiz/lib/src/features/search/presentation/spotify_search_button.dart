import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/loading_button.dart';
import 'package:podiz/src/features/auth/data/spotify_api.dart';
import 'package:podiz/src/utils/instances.dart';

class SpotifySearchButton extends ConsumerStatefulWidget {
  final String query;
  const SpotifySearchButton(this.query, {Key? key}) : super(key: key);

  @override
  ConsumerState<SpotifySearchButton> createState() =>
      _SpotifySearchButtonState();
}

class _SpotifySearchButtonState extends ConsumerState<SpotifySearchButton> {
  bool isLoading = false;

  //TODO put this in a repository
  void searchInSpotify() async {
    setState(() => isLoading = true);
    final accessToken = await ref.read(spotifyApiProvider).getAccessToken();
    await ref
        .read(functionsProvider)
        .httpsCallable("fetchSpotifySearch")
        .call({'accessToken': accessToken, 'query': widget.query});
    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Text(
          //   '${Locales.string(context, "noresults")} "${widget.query}"',
          //   style: context.textTheme.bodySmall,
          //   textAlign: TextAlign.center,
          // ),
          // const SizedBox(height: 8),
          LoadingTextButton(
            loading: isLoading,
            onPressed: searchInSpotify,
            child: Text(Locales.string(context, "searchSpotify")),
          ),
        ],
      ),
    );
  }
}
