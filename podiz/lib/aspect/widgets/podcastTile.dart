import 'package:flutter/material.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/home/components/stackedImages.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/SearchResult.dart';

class PodcastTile extends StatefulWidget {
  SearchResult result;

  PodcastTile(this.result, {Key? key}) : super(key: key);

  @override
  State<PodcastTile> createState() => _PodcastTileState();
}

class _PodcastTileState extends State<PodcastTile> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        height: 92,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kBorderRadius),
          color: theme.colorScheme.surface,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                width: 68,
                height: 68,
                child: Image.network(
                  widget.result.image_url,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 250,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.result.name,
                        style: podcastTitle(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    widget.result.show_name != null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: SizedBox(
                                    width: 120,
                                    child: Text(widget.result.show_name!,
                                        style: podcastArtist()),
                                  )),
                              const SizedBox(width: 12),
                              ClipOval(
                                  child: Container(
                                width: 4,
                                height: 4,
                                color: const Color(0xFFD9D9D9),
                              )),
                              const SizedBox(width: 12),
                              Text(widget.result.duration_ms!.toString(),
                                  style: podcastArtist()), //TODO formatter here
                            ],
                          )
                        : Container(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
