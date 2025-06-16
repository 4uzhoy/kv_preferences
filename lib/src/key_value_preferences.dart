import 'package:kv_preferences/src/key_preferences.dart';
import 'package:kv_preferences/src/key_value_preferences_migrator.dart';

/// A parser function that converts JSON data into a value of type [T].
// ignore: avoid_annotating_with_dynamic
typedef ValuePreferencesParser<T> = T? Function(dynamic json);

/// {@template key_value_store}
/// {@category Preferences}
///
/// An abstract interface for a type-safe key-value storage system.
///
/// This interface is designed to work with [KeyPreferences], providing safe
/// read/write access to primitive and complex types using typed keys.
///
/// It also supports versioned initialization and test mocking.
///
/// Also provides [KeyValuePreferencesMigrator] for handling version migrations.
/// {@endtemplate}
abstract interface class KeyValuePreferences {
  /// Checks whether the given [keyPreferences] exists in the store.
  Future<bool> contains(KeyPreferences<Object> keyPreferences);

  /// Initializes the underlying store.
  ///
  /// If [invalidate] is true, all existing values will be cleared.
  ///
  /// You can optionally provide a [migrator] to handle version migrations.
  Future<void> initialization({
    bool invalidate = false,
    int version = 1,
    KeyValuePreferencesMigrator? migrator,
  });

  /// Initializes the store with mock data for testing purposes.
  ///
  /// This method overrides the storage with [mockInitialValue].
  ///
  /// You can optionally provide a [migrator] to handle version migrations.
  Future<void> mockInitiazation(
    Map<String, Object> mockInitialValue, {
    int version = 1,
    KeyValuePreferencesMigrator? migrator,
  });

  /// Reads the value associated with the given [typedStoreKey].
  ///
  /// Returns `null` if the key does not exist.
  ///
  /// If the value is a complex type, you must provide a
  /// [ValuePreferencesParser] in the [KeyPreferences] definition.
  T? read<T>(KeyPreferences<T> typedStoreKey);

  /// Writes a value to the store using the given [typedStoreKey].
  ///
  /// Pass `null` as [value] to remove the key from the store.
  Future<void> write<T>(KeyPreferences<T> typedStoreKey, T? value);

  /// Clears values from the store by the specified [typedStoreKeys].
  ///
  /// If [excludeKeys] is provided, those keys will be preserved.
  /// If [typedStoreKeys] is empty, all values will be cleared (except exclusions).
  Future<void> clear(
    List<KeyPreferences<Object>> typedStoreKeys, {
    List<KeyPreferences<Object>>? excludeKeys,
  });

  /// Returns all raw string keys currently stored.
  Set<String> getRawKeys();
}

/// {@template value_preferences_parser_exception}
/// {@category Preferences}
/// Exception thrown when a value cannot be parsed from the store.
////// This typically occurs when the stored value does not match the expected
/// type or format defined by the [KeyPreferences] parser.
/// {@endtemplate}
final class ValuePreferencesParserException<T> implements Exception {
  /// Creates a new [ValuePreferencesParserException].
  ValuePreferencesParserException(
    this.key,
    this.type, [
    this.valuePreferencesParser,
  ]);

  /// The key that caused the exception.
  final KeyPreferences<T> key;

  /// The type of the value that was expected.
  final Type type;

  /// The parser that was used to parse the value, if any.
  final ValuePreferencesParser<T>? valuePreferencesParser;

  @override
  String toString() =>
      'ValuePreferencesParserException: Failed to parse value for key "${key.key}" of type $type, ensure the value is stored correctly and the parser is defined. You should pass method to parse non-primitive value from store, current valuePreferencesParser: $valuePreferencesParser';
}

/// {@template value_preferences_failed_to_encode_exception}
/// {@category Preferences}
/// Exception thrown when a value cannot be encoded to JSON for storage.
/// This typically occurs when the value is not serializable or does not match
/// the expected format defined by the [KeyPreferences] parser.
/// {@endtemplate}
final class ValuePreferencesFailedToEncodeException<T> implements Exception {
  /// Creates a new [ValuePreferencesFailedToEncodeException].
  ValuePreferencesFailedToEncodeException(this.key, this.value);

  /// The key that caused the exception.
  final KeyPreferences<T> key;

  /// The value that failed to encode.
  final T value;

  @override
  String toString() =>
      'ValuePreferencesFailedToEncodeException: Failed to encode value "$value" for key "${key.key}". Ensure the value is serializable. Pass the `Map<String, dynamic> toJson` method in model class';
}
