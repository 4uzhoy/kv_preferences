import 'package:kv_preferences/src/key_value_preferences.dart';
import 'package:meta/meta.dart';

/// {@template key_preferences}
/// {@category Preferences}
///
/// Represents a typed key in a key-value preferences store.
///
/// The generic type [T] defines the expected value type associated with the key.
/// This enables type-safe access to preferences.
///
/// For primitive types like `int`, `double`, `String`, and `bool`, no additional configuration is needed.
///
/// For complex or non-primitive types, provide a [valuePreferencesParser]
/// — a function that decodes the stored JSON string into an object of type [T].
///
/// An optional [description] can be used to document the purpose of the key,
/// but it does not affect functionality.
///
/// [keyGroup] can be used to categorize keys, allowing for better organization
/// and management of preferences.
/// {@endtemplate}
@immutable
final class KeyPreferences<T> {
  /// Creates a new [KeyPreferences] instance.
  KeyPreferences(
    this.key, {
    this.valuePreferencesParser,
    this.description,

    this.keyGroup,
  }) : assert(key.isNotEmpty, 'Key must not be empty'),
       assert(T != dynamic, 'Type parameter T must be specified');

  /// The type of the value associated with this key.
  final type = T;

  /// The unique identifier used to store the value.
  final String key;

  /// The full key used for grouping, if [keyGroup] is provided.
  String get groupedKey =>
      keyGroup == null || keyGroup!.isEmpty ? key : '$keyGroup.$key';

  /// Optional documentation about the key's purpose.
  final String? description;

  /// Optional parser for deserializing complex types from JSON.
  final ValuePreferencesParser<T>? valuePreferencesParser;

  /// Optional group name for categorizing keys.
  final String? keyGroup;
  @override
  String toString() =>
      'KeyPreferences(key: $key, valueType: $type, description: $description)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KeyPreferences<T> && other.key == key && other.type == type;
  }

  @override
  int get hashCode => key.hashCode ^ type.hashCode;
}
