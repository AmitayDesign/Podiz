import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import 'showcase_repository.dart';

class ShowcaseViewRepository implements ShowcaseRepository {
  final StreamingSharedPreferences preferences;
  ShowcaseViewRepository({required this.preferences});

  final key = 'firstTimeShowcase';

  @override
  bool get isFirstTime =>
      preferences.getBool(key, defaultValue: true).getValue();

  @override
  Future<void> disable() => preferences.setBool(key, false);
}
