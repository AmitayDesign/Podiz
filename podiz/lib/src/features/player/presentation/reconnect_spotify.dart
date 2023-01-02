import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/spotify_icon.dart';
import 'package:podiz/src/features/auth/data/spotify_api.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';
import 'package:podiz/src/theme/context_theme.dart';

class ReconnectSpotify extends ConsumerWidget {
  const ReconnectSpotify(this.episodeId, {Key? key}) : super(key: key);
  final String episodeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        backgroundColor: context.colorScheme.error,
        foregroundColor: context.colorScheme.background,
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpotifyIcon(color: context.colorScheme.onPrimary),
          const SizedBox(width: 12),
          Text(
            "RECONNECT TO SPOTIFY".hardcoded,
            style: context.textTheme.titleSmall!.copyWith(
              color: context.colorScheme.onPrimary,
            ),
            // maxLines: 1,
          )
        ],
      ),
      onPressed: () async {
        ref.read(spotifyApiProvider).connectToSdk();
      },
    );
  }
}
