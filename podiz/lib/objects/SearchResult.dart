import 'package:podiz/home/search/showManager.dart';

class SearchResult {
  String name;
  String image_url;
  String? show_name;
  int? duration_ms;

  SearchResult({required this.name, required this.image_url, this.show_name, this.duration_ms});
}
