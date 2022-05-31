import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PodcastTile extends ConsumerWidget {
  const PodcastTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // return ItemTile(
    //   imageURL: restaurant.imageURL,
    //   title: restaurant.name,
    //   onTap: () {
    //     ref
    //         .read(appManagerProvider)
    //         .changeRestaurantSetUpAllStreams(restaurant);
    //     Navigator.pushNamed(
    //       context,
    //       RestaurantPage.route,
    //       arguments: restaurant,
    //     );
    //   },
    //   subtitle: restaurant.schedule == null
    //       ? null
    //       : RestaurantInfo.todaysSchedule(
    //           restaurant,
    //           style: theme.textTheme.caption!,
    //         ),
    // );
    return Container();
  }
}
