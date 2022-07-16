import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/typedefs.dart';
import 'package:podiz/objects/Podcaster.dart';
import 'package:podiz/providers.dart';
import 'package:rxdart/rxdart.dart';

final showManagerProvider = Provider<ShowManager>(
  (ref) => ShowManager(ref.read),
);

class ShowManager {
  final Reader _read;

  get userStream => _read(userStreamProvider);
  FirebaseFirestore get firestore => _read(firestoreProvider);

  List<Podcaster> showBloc = [];

  final _showStream = BehaviorSubject<List<Podcaster>>();
  Stream<List<Podcaster>> get podcasts => _showStream.stream;

  ShowManager(this._read) {
    print("Settings up show stream!");
    firestore.collection("podcasters").snapshots().listen((snapshot) async {
      for (DocChange showChange in snapshot.docChanges) {
        if (showChange.type == DocumentChangeType.added) {
          await addShowToBloc(showChange.doc);
        }
        if (showChange.type == DocumentChangeType.modified) {
          await editShowToBloc(showChange.doc);
        }
      }
      _showStream.add(showBloc);
    });
  }

  // General Functions

  addShowToBloc(Doc doc) {
    Podcaster podcaster = Podcaster.fromJson(doc.data()!);
    podcaster.uid = doc.id;
    showBloc.add(podcaster);
  }

  editShowToBloc(Doc doc) {
    Podcaster podcaster = Podcaster.fromJson(doc.data()!);
    podcaster.uid = doc.id;
    int index = showBloc.indexWhere((element) => element.uid == doc.id);
    if (index == -1) return;
    showBloc[index] = podcaster;
  }

  resetManager() async {
    // await podcastStreamSubscription?.cancel();
    // await productsStream?.close();
    showBloc = [];
  }

  List<String> getEpisodes(String showId) {
    Iterable<Podcaster> podcaster =
        showBloc.where((show) => show.uid == showId);
    if (podcaster != null) {
      return podcaster.first.podcasts;
    }
    return [];
  }

  String getShowImageUrl(String showUid) {
    for (int i = 0; i < showBloc.length; i++) {
      if (showBloc[i].uid == showUid) {
        return showBloc[i].image_url;
      }
    }
    return "not_found";
  }
}
