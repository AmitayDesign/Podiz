import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/widgets/loadingButton.dart';
import 'package:podiz/providers.dart';

class SpotifySearch extends ConsumerStatefulWidget {
  final String query;
  const SpotifySearch(this.query, {Key? key}) : super(key: key);

  @override
  ConsumerState<SpotifySearch> createState() => _SpotifySearchState();
}

class _SpotifySearchState extends ConsumerState<SpotifySearch> {
  bool isLoading = false;

  void searchInSpotify() async {
    setState(() => isLoading = true);
    final user = ref.read(currentUserProvider);
    await FirebaseFunctions.instance.httpsCallable("searchInSpotify").call({
      "query": widget.query,
      "userUid": user.uid,
    }); //TODO verify arguments
    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${Locales.string(context, "noresults")} "${widget.query}"',
            style: context.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
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
