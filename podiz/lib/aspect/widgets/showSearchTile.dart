import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/objects/show.dart';
import 'package:podiz/src/routing/app_router.dart';

class ShowSearchTile extends StatelessWidget {
  final Show show;
  const ShowSearchTile(this.show, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () => context.goNamed(
          AppRoute.show.name,
          params: {'showId': show.uid!},
        ),
        child: Container(
          height: 148,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kBorderRadius),
            color: theme.colorScheme.surface,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Column(children: [
              Row(
                children: [
                  PodcastAvatar(imageUrl: show.image_url, size: 68),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 68,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              show.name,
                              style: context.textTheme.labelLarge,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                show.description,
                style: context.textTheme.bodyMedium!.copyWith(
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            ]),
          ),
        ),
      ),
    );
  }
}
