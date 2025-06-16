import 'dart:convert';

import 'package:kv_preferences/kv_preferences.dart';

/// {@template key_value_shared_preferences}
/// {@category Preferences}
/// Implementation of [KeyValuePreferences] using [SharedPreferences].
/// This class provides a singleton instance for accessing shared preferences
/// and supports initialization, reading, writing, and clearing preferences.
/// It also supports migration of preferences using a [KeyValuePreferencesMigrator].
/// {@endtemplate}
final class KeyValueSharedPreferences extends KeyValuePreferencesBase {
  /// {@macro key_value_shared_preferences}
  factory KeyValueSharedPreferences() => _singleton;

  KeyValueSharedPreferences._();

  static final KeyValueSharedPreferences _singleton =
      KeyValueSharedPreferences._();

  late SharedPreferences _sharedPreferences;

  /// for accessing the underlying [SharedPreferences] instance.
  SharedPreferences get sharedPreferences => _sharedPreferences;

  @override
  Future<void> initialization({
    SharedPreferences? sharedPreferences,
    KeyValuePreferencesMigrator? migrator,
    bool invalidate = false,
    int version = 1,
  }) async {
    if (isNotInited) {
      _sharedPreferences =
          sharedPreferences ?? await SharedPreferences.getInstance();
      isInited = true;
    }

    final fromVersion = read(KeyPreferencesGroup$Store.version) ?? 0;

    if (invalidate) {
      await _sharedPreferences.clear();
      await write(KeyPreferencesGroup$Store.version, 1);
      return;
    }

    if (fromVersion == 0 && version >= 1 && migrator == null) {
      // if the store is not initialized and no migrator is provided,
      // we set the version to 1.
      await write(KeyPreferencesGroup$Store.version, 1);
    } else if (migrator != null && fromVersion < version) {
      await _migrateUntilTarget(fromVersion, version, migrator);
    } else if (migrator == null && fromVersion < version) {
      throw MigrationNotPassedException(fromVersion, version);
    }
  }

  Future<void> _migrateUntilTarget(
    int fromVersion,
    int toVersion,
    KeyValuePreferencesMigrator migrator,
  ) async {
    var current = fromVersion;

    while (current < toVersion) {
      final next = current + 1;
      final need = await migrator.needsMigration(current);

      if (need) {
        await migrator.migrate(current, next);
      }

      await write(KeyPreferencesGroup$Store.version, next);
      current = next;
    }

    final currentVersion = read(KeyPreferencesGroup$Store.version) ?? 0;
    if (currentVersion < toVersion) {
      throw MigrationNotPassedException(currentVersion, toVersion);
    }
  }

  @override
  Future<void> mockInitiazation(
    Map<String, Object> mockInitialValue, {
    KeyValuePreferencesMigrator? migrator,
    int version = 1,
  }) async {
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues(mockInitialValue);
    _sharedPreferences = await SharedPreferences.getInstance();
    await initialization(sharedPreferences: _sharedPreferences);
  }

  @override
  T? read<T>(KeyPreferences<T> typedStoreKey) {
    final value = _sharedPreferences.get(typedStoreKey.groupedKey);

    if (typedStoreKey.type == DateTime) {
      return value == null ? null : DateTime.parse(value as String) as T;
    } else if (value != null &&
        value is String &&
        (value.startsWith('{') || value.startsWith('['))) {
      if (typedStoreKey.valuePreferencesParser == null) {
        Error.throwWithStackTrace(
          ValuePreferencesParserException<T>(
            typedStoreKey,
            T,
            typedStoreKey.valuePreferencesParser,
          ),
          StackTrace.current,
        );
      }
      if (value is List) {
        return typedStoreKey.valuePreferencesParser?.call(
          jsonDecode(value) as List<Object?>,
        );
      }
      if (value is Map) {
        return typedStoreKey.valuePreferencesParser?.call(
          jsonDecode(value) as Map<String, Object?>,
        );
      }
      return typedStoreKey.valuePreferencesParser?.call(jsonDecode(value));
    } else {
      return value as T?;
    }
  }

  @override
  Future<bool> contains(KeyPreferences<Object> typedStoreKey) async =>
      _sharedPreferences.containsKey(typedStoreKey.groupedKey);

  @override
  Future<void> write<T>(KeyPreferences<T> keyPreference, T? value) async {
    if (value != null && value.runtimeType != keyPreference.type) {
      throw ArgumentError(
        'Invalid type for key ${keyPreference.key}: ${value.runtimeType} != $T',
      );
    }
    if (value == null) {
      await _sharedPreferences.remove(keyPreference.groupedKey);
      return;
    }
    switch (T) {
      case const (int):
        await _sharedPreferences.setInt(keyPreference.groupedKey, value as int);
        break;
      case const (String):
        await _sharedPreferences.setString(
          keyPreference.groupedKey,
          value as String,
        );
        break;
      case const (double):
        await _sharedPreferences.setDouble(
          keyPreference.groupedKey,
          value as double,
        );
        break;
      case const (bool):
        await _sharedPreferences.setBool(
          keyPreference.groupedKey,
          value as bool,
        );
        break;
      case const (List<String>):
        await _sharedPreferences.setStringList(
          keyPreference.groupedKey,
          value as List<String>,
        );
        break;
      case const (DateTime):
        await _sharedPreferences.setString(
          keyPreference.groupedKey,
          (value as DateTime).toIso8601String(),
        );
        break;
      default:
        try {
          await _sharedPreferences.setString(
            keyPreference.groupedKey,
            jsonEncode(value),
          );
        } on Object catch (e, stackTrace) {
          Error.throwWithStackTrace(
            ValuePreferencesFailedToEncodeException(keyPreference, value),
            stackTrace,
          );
        }
    }
  }

  @override
  Set<String> getRawKeys() => _sharedPreferences.getKeys();

  @override
  Future<void> clear(
    List<KeyPreferences<Object>> keyPreferences, {
    List<KeyPreferences<Object>>? excludeKeys,
  }) {
    if (keyPreferences.isEmpty) {
      _sharedPreferences.getKeys().forEach((key) {
        if (excludeKeys != null &&
            excludeKeys.any(
              (typedStoreKey) => typedStoreKey.groupedKey == key,
            )) {
          return;
        }
        if (key == KeyPreferencesGroup$Store.version.groupedKey) {
          // Skip version key to avoid resetting the version.
          return;
        }
        _sharedPreferences.remove(key);
      });
    } else {
      for (final key in keyPreferences) {
        if (excludeKeys != null && excludeKeys.contains(key)) {
          continue;
        }
        if (key == KeyPreferencesGroup$Store.version) {
          // Skip version key to avoid resetting the version.
          continue;
        }
        _sharedPreferences.remove(key.groupedKey);
      }
    }

    return Future.value();
  }
}
