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

  ShowManager(this._read);

  setUpShowStream() {
    firestore.collection("podcasters").snapshots().listen((snapshot) async {
      for (DocChange showChange in snapshot.docChanges) {
        if (showChange.type == DocumentChangeType.added) {
          await addShowToBloc(showChange.doc);
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

  resetManager() async {
    // await podcastStreamSubscription?.cancel();
    // await productsStream?.close();
    showBloc = [];
  }
}
