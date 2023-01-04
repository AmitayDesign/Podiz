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
    // delete child comments
    let repliesRef = admin
      .firestore()
      .collection("comments")
      .where("parentIds", "array-contains", commentId);
    let repliesSnapshot = await t.get(repliesRef);
    // decrement episode comment counter
    let episodeRef = admin.firestore().collection("episodes").doc(episodeId);
    t.update(episodeRef, {
      commentsCount: admin.firestore.FieldValue.increment(-1),
    });

    //Get Parents and update counters
    for (let parentId of parentIds) {
      let parentRef = admin.firestore().collection("comments").doc(parentId);
      let parentDoc = await parentRef.get();
      if (parentDoc.exists) {
        t.update(parentRef, {
          replyCount: admin.firestore.FieldValue.increment(-1),
        });
      }
    }

    // delete child comments
    for (let replyDoc of repliesSnapshot.docs) t.delete(replyDoc.ref);
    console.log("replyDoc");
  });
