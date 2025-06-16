import 'package:kv_preferences/src/key_value_preferences.dart';

/// {@template key_value_preferences_base}
/// {@category Preferences}
/// An abstract base class for a type-safe key-value storage system.
/// This class provides the foundational structure for implementing
/// key-value preferences with versioning and initialization capabilities.
/// {@endtemplate}
abstract base class KeyValuePreferencesBase implements KeyValuePreferences {
  /// Initializes the underlying store.
  /// indicates whether the store has been initialized.
  bool isInited = false;

  /// Indicates whether the store is not initialized.
  bool get isNotInited => !isInited;
}
