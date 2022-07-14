import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/aspect/widgets/asyncElevatedButton.dart';
import 'package:podiz/authentication/AuthManager.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/profile/components.dart/backAppBar.dart';

class CommentPage extends ConsumerWidget {
  static const route = '/commentPage';
  Podcast podcast;
  CommentPage(this.podcast, {Key? key}) : super(key: key);

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: BackAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            PodcastAvatar(imageUrl: podcast.image_url, size: 128),
            const SizedBox(height: 24),
            Text(
              podcast.name,
              style: podcastTitle(),
            ),
            const SizedBox(height: 12),
            Text(
              podcast.show_name,
              style: podcastArtist(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              minLines: 1,
              maxLines: 6,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                  hintText: Locales.string(context, "typesmth"),
                  hintStyle: podcastInsightsQuickNote()),
              controller: controller,
            ),
            Spacer(),
            AsyncElevatedButton(
              onPressed: () => ref
                  .read(authManagerProvider)
                  .doComment(controller.text, podcast.uid!, podcast.duration_ms),
              child: Text(
                Locales.string(context, "doComent"),
                style: theme.textTheme.button,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
