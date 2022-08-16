import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/player/PlayerManager.dart';
import 'package:podiz/player/components/insightSheet.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/theme/palette.dart';

class DiscussionSnackBar extends ConsumerStatefulWidget {
  final Episode episode;
  const DiscussionSnackBar(
    this.episode, {
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<DiscussionSnackBar> createState() => _DiscussionSnackBarState();
}

class _DiscussionSnackBarState extends ConsumerState<DiscussionSnackBar> {
  bool isVisible = true;
  late String episodeUid;
  bool firstTime = true;

  @override
  void dispose() {
    FirebaseFirestore.instance
        .collection("podcasts")
        .doc(episodeUid)
        .update({"watching": FieldValue.increment(-1)});
    super.dispose();
  }

  void openSheet() {
    setState(() => isVisible = false);
    ref.read(playerRepositoryProvider).pause();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Palette.grey900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(kBorderRadius),
        ),
      ),
      builder: (context) => WillPopScope(
        onWillPop: () async {
          setState(() => isVisible = true);
          return true;
        },
        child: Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: InsightSheet(
            episode: widget.episode,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerManager = ref.watch(playerManagerProvider);
    if (firstTime) {
      episodeUid = widget.episode.id;
      playerManager.increment(episodeUid);
      firstTime = false;
    }
    return Visibility(
      visible: isVisible,
      child: Container(
        decoration: const BoxDecoration(
          color: Palette.grey900,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(kBorderRadius),
          ),
        ),
        child: InsightSheet(episode: widget.episode),
      ),
    );
  }
}
