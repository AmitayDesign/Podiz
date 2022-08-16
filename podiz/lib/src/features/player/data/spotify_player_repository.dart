import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/player/domain/player.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

import 'player_repository.dart';

class SpotifyPlayerRepository implements PlayerRepository {
  final EpisodeRepository episodeRepository;

  SpotifyPlayerRepository({required this.episodeRepository});

  @override
  Stream<Player?> playerStateChanges() =>
      SpotifySdk.subscribePlayerState().map(playerFromPlayerState);

  @override
  Future<Player?> currentPlayerState() async {
    final state = await SpotifySdk.getPlayerState();
    if (state == null) return null;
    return playerFromPlayerState(state);
  }

  Player? playerFromPlayerState(PlayerState state) {
    final track = state.track; //TODO decide what to do with null track
    if (track == null || !track.isEpisode || !track.isPodcast) return null;
    return Player(
      episodeId: track.uri,
      episodeName: track.name,
      episodeImageUrl: track.imageUri.raw, //TODO this is not a url
      episodeDuration: track.duration,
      playbackPosition: state.playbackPosition,
      isPlaying: !state.isPaused,
    );
  }

  @override
  Future<void> play(String podcastId, [int? time]) async {
    if (time != null) {
      await SpotifySdk.seekTo(positionedMilliseconds: time);
      return resume();
    }
    return SpotifySdk.play(spotifyUri: podcastId);
  }

  @override
  Future<void> resume() => SpotifySdk.resume();

  @override
  Future<void> pause() => SpotifySdk.pause();

  @override
  Future<void> fastForward([int seconds = 30]) {
    final position = Duration(seconds: seconds).inMilliseconds;
    return SpotifySdk.seekToRelativePosition(relativeMilliseconds: position);
  }

  @override
  Future<void> rewind([int seconds = 30]) {
    final position = -Duration(seconds: seconds).inMilliseconds;
    return SpotifySdk.seekToRelativePosition(relativeMilliseconds: position);
  }
}
