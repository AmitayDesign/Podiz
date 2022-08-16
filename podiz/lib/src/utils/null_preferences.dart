import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

extension NullPreferences on StreamingSharedPreferences {
  String? getStringOrNull(String key) => watchString(key).getValue();
  Preference<String?> watchString(String key) {
    return getCustomValue(
      key,
      defaultValue: null,
      adapter: StringAdapter.instance,
    );
  }
}
