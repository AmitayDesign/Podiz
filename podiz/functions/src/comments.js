const admin = require("firebase-admin");
const { firebaseConfig, FunctionBuilder } = require("firebase-functions/v1");
//

function formatDate(date) {
  return (
    date.getFullYear().toString() +
    "-" +
    (date.getMonth() + 1).toString() +
    "-" +
    date.getDate().toString()
  );
}
exports.updateWeeklyComments = async () => {
  var snapshot = await admin.firestore().collection("episodeCounters").get();

  var date = new Date();
  var formattedDate = formatDate(date);
  date.setDate(date.getDate() - 7);
  var formattedOldDate = formatDate(date);
  console.log(formattedOldDate);
  snapshot.docs.map((doc) => {
    var document = doc.data();
    let counters = document.counters;
    console.log(counters[formattedOldDate]);
    if (counters[formattedOldDate] != null) {
      console.log("entrou");
      let counter = counters[formattedOldDate];
      admin
        .firestore()
        .collection("episodes")
        .doc(doc.id)
        .update({
          weeklyCounters: admin.firestore.FieldValue.increment(-counter),
        });
      delete counters[formattedOldDate];
    }
    counters[formattedDate] = 0;

    admin
      .firestore()
      .collection("episodeCounters")
      .doc(doc.id)
      .set({ counters: counters });
  });
};

exports.propagateDeletion = (commentId, episodeId, parentIds) =>
  admin.firestore().runTransaction(async (t) => {
    // reads

    // get episode counters
    let episodeCountersRef =
      admin.firestore().collection('episodeCounters').doc(episodeId);
    let episodeCountersDoc = await t.get(episodeCountersRef);

    // get child comments
    let repliesRef = admin.firestore().collection('comments')
      .where(parentIds, 'array-contains', commentId);
    let repliesSnapshot = await t.get(repliesRef);

    // get parent comments
    let parentDocs = await Promise.all(parentIds.map((parentId) => {
      let parentRef = admin.firestore().collection('comments').doc(parentId);
      return t.get(parentRef);
    }));

    // writes

    // decrement episode comment counter
    let episodeRef = firestore.collection('episodes').doc(episodeId);
    t.update(episodeRef, {
      'commentsCount': admin.firestore.FieldValue.increment(-1),
    });

    // decrement episode counters
    let countersData = episodeCountersDoc.data;
    let counters = countersData.counters;

    let now = new Date();
    let year = date.getFullYear();
    let month = date.getMonth() + 1;
    let day = date.getDate();

    let count = counters[`$year-$month-$day`];
    counters[`$year-$month-$day`] = count - 1;

    t.set(
      episodeCountersRef,
      { counters: counters },
      { merge: true },
    );

    // decrement parent comments reply counter
    for (let parentDoc of parentDocs) {
      if (parentDoc.exists) {
        t.update(parentDoc, {
          'replyCount': FieldValue.increment(-1)
        });
      }
    }

    // delete child comments
    for (let replyDoc of repliesSnapshot.docs) t.delete(replyDoc);
  });
