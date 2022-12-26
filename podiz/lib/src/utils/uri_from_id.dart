String uriFromId(String id) => 'spotify:episode:$id';
String idFromUri(String uri) => uri.split(':').last;
