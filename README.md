

# kv_preferences

[![Pub](https://img.shields.io/pub/v/kv_preferences.svg)](https://pub.dev/packages/kv_preferences)
[![License: Apache](https://img.shields.io/github/license/saltstack/salt)](https://github.com/4uzhoy/kv_preferences/blob/main/LICENSE)
[![Code size](https://img.shields.io/github/languages/code-size/4uzhoy/kv_preferences.svg)](https://github.com/4uzhoy/kv_preferences)

---

## `kv_preferences` is a type-safe wrapper around `SharedPreferences` with:


- Runtime type checking and compile time when passed T
- Complex object parsing
- Versioning and migration
- Grouped keys support
- Testing mocks


## 📚 Index

- [Motivation](#motivation)
- [Getting Started](#getting-started)
- [Key API](#key-api)
- [Writing with type enforcement](#writing-with-type-enforcement)
- [Primitive types](#primitive-types)
- [Complex types](#complex-types)
- [Invalidation](#invalidation)
- [Migration](#migration)
- [Grouped keys](#grouped-keys)
- [Testing](#testing)
- [Contributing](#contributing)


## 💡 Motivation

SharedPreferences work but lack safety and structure. You can write a string and accidentally read it as an int — no warnings, no errors.

`kv_preferences` makes your store safe by enforcing type expectations via `KeyPreferences<T>`.


## 🚀 Getting Started

```dart
final store = KeyValueSharedPreferences();
await store.initialization(version: 1);

final key = KeyPreferences<String>('token');
await store.write(key, 'abc123');
final token = store.read(key); // 'abc123'
```


## 🔑 Key API
Define keys once and reuse them safely:
```dart
final nameKey = KeyPreferences<String>('name');
final ageKey = KeyPreferences<int>('age', description: 'User age', keyGroup: 'user');
```

## ✍️ Writing with type enforcement

```dart
await store.write<String>(nameKey, 'Alice');      // OK
await store.write<int>(ageKey, 30);               // OK
await store.write<int>(nameKey, 10);              // Throws ArgumentError
```
⚠️ Type safety is enforced only when explicitly passing <T> in write<T>.


## 🔢 Primitive types
The following types are natively supported:
String, int, double, bool, DateTime, List<String>
No parser needed for these.

## 🧩 Complex types
You must provide a parser for non-primitive types:

``` dart
final userKey = KeyPreferences<User>(
  'user',
  valuePreferencesParser: (json) => User.fromJson(json as Map<String, Object?>),
);

  // use it like this
  await store.write<User>(KeyPreferencesGroup$Test.userKey, User.alice());
  final user = store.read(KeyPreferencesGroup$Test.userKey)!;
  print(user); // User(name: Alice, age: 30)

```

## ❗ Your class must implement `toJson()` for encoding
```dart
@immutable
final class User {
  const User({required this.name, required this.age});

  factory User.fromJson(Map<String, dynamic> json) =>
      User(name: json['name'] as String, age: json['age'] as int);

  factory User.alice() => const User(name: 'Alice', age: 30);
  
  ///...

  Map<String, dynamic> toJson() => <String, dynamic>{'name': name, 'age': age}; // <--- 

  /// ...
}
```

## 🔄 Invalidation
To clear all stored values:
```dart
await store.initialization(invalidate: true);
```

To selectively clear values:
```dart
await store.clear([
  KeyPreferences<String>('token'),
  KeyPreferences<int>('counter'),
]);
```


## ⬆️ Migration
To support store version upgrades:
```dart
class MyMigrator extends KeyValuePreferencesMigrator {
  @override
  Future<void> migrate(int fromVersion, int toVersion) async {
    if (fromVersion == 1 && toVersion == 2) {
      // perform migration
    }
  }

  @override
  Future<bool> needsMigration(int currentVersion) async {
    return currentVersion < 2;
  }
}

await store.initialization(
  version: 2,
  migrator: MyMigrator(),
);
```

Or in more complex case

```dart
class MultiStepMigrator extends KeyValuePreferencesMigrator {
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
```

### If migration is required and no migrator is provided — throws MigrationNotPassedException. 


## 🧭 Grouped keys
Group keys logically:

```dart
final emailKey = KeyPreferences<String>('email', keyGroup: 'user');
print(emailKey.groupedKey); // user.email

```

## 🧪 Testing
For testing you can use `mockInitiazation`
```dart
await store.mockInitiazation({
  'name': 'Test User',
  'age': 42,
});
```

## 🛠️ Contributing

Issues: [github.com/4uzhoy/kv_preferences/issues](https://github.com/4uzhoy/kv_preferences/issues)  
Pull requests: [github.com/4uzhoy/kv_preferences/pulls](https://github.com/4uzhoy/kv_preferences/pulls)


Your feedback is welcome.
