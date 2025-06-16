// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:kv_preferences/kv_preferences.dart';

Future<void> main() async {
  final store = KeyValueSharedPreferences();

  await store.initialization(version: 1);

  final tokenKey = KeyPreferences<String>('token');
  final userKey = KeyPreferences<User>(
    'user',
    valuePreferencesParser:
        (json) => User.fromJson(json as Map<String, Object?>),
  );

  // Write primitive
  await store.write<String>(tokenKey, 'abc123');
  // await store.write<int>(tokenKey, 10); // This line is incorrect and will cause a type error, as the key expects a String.
  await store.write(
    tokenKey,
    10, // This line is incorrect and will cause a type error, as the key expects a String.
  ); // Be careful with types! That's OK for compilation, but not for runtime.
  // throw ArgumentError if the type does not match the key type.

  // Read primitive
  final token = store.read(tokenKey);
  print('Token: $token');

  // Write complex object
  const user = User(name: 'Alice', age: 30);
  await store.write(userKey, user);

  // Read complex object
  final storedUser = store.read(userKey);
  print('User: $storedUser');

  // Clear one key
  await store.clear([tokenKey]);

  // Re-read token
  final clearedToken = store.read(tokenKey);
  print('Token after clear: $clearedToken');
}

/// Example data class for testing
@immutable
final class User {
  /// Example data class for testing
  const User({required this.name, required this.age});

  /// Creates a [User] instance from JSON.
  factory User.fromJson(Map<String, dynamic> json) =>
      User(name: json['name'] as String, age: json['age'] as int);

  /// Factory method to create a predefined user instance.
  factory User.alice() => const User(name: 'Alice', age: 30);

  /// The name of the user.
  final String name;

  /// The age of the user.
  final int age;

  /// Converts the user instance to JSON.
  /// This is `required` for complex types!
  Map<String, dynamic> toJson() => <String, dynamic>{'name': name, 'age': age};

  @override
  String toString() => 'User(name: $name, age: $age)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.name == name && other.age == age;
  }

  @override
  int get hashCode => name.hashCode ^ age.hashCode;
}
