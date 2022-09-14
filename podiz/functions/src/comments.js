const admin = require("firebase-admin");
const { firebaseConfig } = require("firebase-functions/v1");
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
