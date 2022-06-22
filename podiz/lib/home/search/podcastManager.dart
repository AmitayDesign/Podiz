import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/typedefs.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/providers.dart';
import 'package:rxdart/rxdart.dart';

final podcastManagerProvider = Provider<PodcastManager>(
  (ref) => PodcastManager(ref.read),
);

class PodcastManager {
  final Reader _read;

  get userStream => _read(userStreamProvider);
  FirebaseFirestore get firestore => _read(firestoreProvider);

  Map<String, Podcast> podcastBloc = {};

  final _podcastStream = BehaviorSubject<Map<String, Podcast>>();
  Stream<Map<String, Podcast>> get podcasts => _podcastStream.stream;

  PodcastManager(this._read);

  setUpPodcastStream() {
    firestore.collection("podcasts").snapshots().listen((snapshot) async {
      for (DocChange podcastChange in snapshot.docChanges) {
        if (podcastChange.type == DocumentChangeType.added) {
          await addPodcastToBloc(podcastChange.doc);
        }
      }
      _podcastStream.add(podcastBloc);
    });
  }

  // General Functions

  addPodcastToBloc(Doc doc) {
    Podcast podcast = Podcast.fromJson(doc.data()!);
    podcast.uid = doc.id;
    podcastBloc.addAll({doc.id: podcast});
  }

  resetManager() async {
    // await podcastStreamSubscription?.cancel();
    // await productsStream?.close();
    podcastBloc = {};
  }
}
