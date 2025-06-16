import 'package:kv_preferences/kv_preferences.dart';

/// {@template key_preferences_group}
/// {@category Preferences}
/// Represents a group of preferences identified by a unique key.
/// This class is used to categorize and organize preferences within a key-value store.
/// Each group has a unique identifier, which is used to categorize preferences.
/// The group key is used to categorize preferences, allowing for better organization
/// and management of preferences.
/// {@endtemplate}
abstract class KeyPreferencesGroup {
  /// Creates a new [KeyPreferencesGroup] instance.
  const KeyPreferencesGroup();
}

/// A concrete implementation of [KeyPreferencesGroup] for storing application-wide preferences.
///
/// {@macro key_preferences_group}
final class KeyPreferencesGroup$Store extends KeyPreferencesGroup {
  /// hide default constructor, cause used only static members
  const KeyPreferencesGroup$Store._();

  /// The unique key used to categorize preferences in this group.
  static String get keyPreferencesGroup => 'store';

  /// The version of the preferences store.
  static KeyPreferences<int> get version =>
      KeyPreferences<int>('version', keyGroup: keyPreferencesGroup);
}
