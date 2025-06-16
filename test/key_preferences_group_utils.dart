import 'package:flutter/foundation.dart';
import 'package:kv_preferences/kv_preferences.dart';

final class KeyPreferencesGroup$Test extends KeyPreferencesGroup {
  const KeyPreferencesGroup$Test._();

  static String get keyPreferencesGroup => 'test';

  static KeyPreferences<String> get nonExistingKey =>
      KeyPreferences<String>('nonExistingKey');

  static KeyPreferences<int> get intValue =>
      KeyPreferences<int>('intValue', keyGroup: keyPreferencesGroup);

  static KeyPreferences<double> wrongTypeValue = KeyPreferences<double>(
    'wrongIntTypeValue',
    keyGroup: keyPreferencesGroup,
  );

  static KeyPreferences<String> get stringValue =>
      KeyPreferences<String>('stringValue', keyGroup: keyPreferencesGroup);
  static KeyPreferences<bool> get boolValue =>
      KeyPreferences<bool>('boolValue', keyGroup: keyPreferencesGroup);

  static KeyPreferences<DateTime> get dateTimeValue =>
      KeyPreferences<DateTime>('dateTimeValue', keyGroup: keyPreferencesGroup);

  static KeyPreferences<double> get doubleValue =>
      KeyPreferences<double>('doubleValue', keyGroup: keyPreferencesGroup);

  static KeyPreferences<List<String>> get listStringValue =>
      KeyPreferences<List<String>>(
        'listStringValue',
        keyGroup: keyPreferencesGroup,
        valuePreferencesParser:
            (value) => List<String>.from(<String>[
              'value',
              'value',
              'value',
            ], growable: false),
      );

  static KeyPreferences<ComplexType> get complexTypeValue =>
      KeyPreferences<ComplexType>(
        'complexTypeValue',
        keyGroup: keyPreferencesGroup,
        valuePreferencesParser:
            (value) => ComplexType.fromJson(value as Map<String, dynamic>),
      );

  static KeyPreferences<User> get userKeyWithoutParser => KeyPreferences<User>(
    'userKeyWithoutParser',
    keyGroup: keyPreferencesGroup,
    valuePreferencesParser:
        null, // This will cause an error if used without a parser
  );

  static KeyPreferences<User> get userKey => KeyPreferences<User>(
    'userKey',
    keyGroup: keyPreferencesGroup,
    valuePreferencesParser:
        (value) => User.fromJson(value as Map<String, dynamic>),
  );
}

@immutable
class ComplexType {
  const ComplexType({required this.string, required this.intValue});

  factory ComplexType.fromJson(Map<String, dynamic> json) => ComplexType(
    string: json['string'] as String,
    intValue: json['intValue'] as int,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'string': string,
    'intValue': intValue,
  };
  final String string;
  final int intValue;

  @override
  String toString() => 'ComplexType(string: $string, intValue: $intValue)';
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ComplexType &&
        other.string == string &&
        other.intValue == intValue;
  }

  @override
  int get hashCode => string.hashCode ^ intValue.hashCode;
}

@immutable
final class User {
  const User({required this.name, required this.age});
  factory User.fromJson(Map<String, dynamic> json) =>
      User(name: json['name'] as String, age: json['age'] as int);

  factory User.alice() => const User(name: 'Alice', age: 30);
  final String name;
  final int age;

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

class TestMigrator implements KeyValuePreferencesMigrator {
  final KeyValuePreferences store;

  TestMigrator(this.store);

  @override
  Future<bool> needsMigration(int fromVersion) async => fromVersion == 1;

  @override
  Future<void> migrate(int fromVersion, int toVersion) async {
    await store.write(KeyPreferencesGroup$Test.intValue, 999);
    await store.write(KeyPreferencesGroup$Test.stringValue, 'migrated');
    await store.write(KeyPreferencesGroup$Test.boolValue, false);
    await store.write(
      KeyPreferencesGroup$Test.dateTimeValue,
      DateTime(2024, 1, 1),
    );
    await store.write(KeyPreferencesGroup$Test.doubleValue, 6.28);
    await store.write(KeyPreferencesGroup$Test.listStringValue, ['m1', 'm2']);
    await store.write(
      KeyPreferencesGroup$Test.complexTypeValue,
      const ComplexType(string: 'migrated', intValue: 200),
    );
  }
}

class TestMigratorNoOp implements KeyValuePreferencesMigrator {
  @override
  Future<bool> needsMigration(int fromVersion) async => false;

  @override
  Future<void> migrate(int fromVersion, int toVersion) async {
    throw Exception('Should not be called');
  }
}

class MultiStepMigrator implements KeyValuePreferencesMigrator {
  final KeyValuePreferences store;
  final List<int> stepsCalled = [];

  MultiStepMigrator(this.store);

  @override
  Future<bool> needsMigration(int fromVersion) async => fromVersion < 5;

  @override
  Future<void> migrate(int fromVersion, int toVersion) async {
    stepsCalled.add(fromVersion);
    switch (fromVersion) {
      case 1:
        await store.write(KeyPreferencesGroup$Test.intValue, 101);
        break;
      case 2:
        await store.write(KeyPreferencesGroup$Test.intValue, 102);
        break;
      case 3:
        await store.write(KeyPreferencesGroup$Test.intValue, 103);
        break;
      case 4:
        await store.write(KeyPreferencesGroup$Test.intValue, 104);
        break;
    }
  }
}

class FailingMigrator implements KeyValuePreferencesMigrator {
  @override
  Future<bool> needsMigration(int fromVersion) async => true;

  @override
  Future<void> migrate(int fromVersion, int toVersion) async {
    throw MigrationException(fromVersion, toVersion);
  }
}
