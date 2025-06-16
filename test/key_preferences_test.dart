import 'package:flutter_test/flutter_test.dart';
import 'package:kv_preferences/kv_preferences.dart';

import 'key_preferences_group_utils.dart';

void main() {
  late KeyValueSharedPreferences store;

  setUp(() async {
    store = KeyValueSharedPreferences();
    await store.mockInitiazation({
      KeyPreferencesGroup$Store.version.groupedKey: 1,
      KeyPreferencesGroup$Test.wrongTypeValue.groupedKey:
          43.0, // Intentionally wrong type
      KeyPreferencesGroup$Test.intValue.groupedKey: 42,
      KeyPreferencesGroup$Test.stringValue.groupedKey: 'test',
      KeyPreferencesGroup$Test.boolValue.groupedKey: true,
      KeyPreferencesGroup$Test.dateTimeValue.groupedKey:
          DateTime(2023, 1, 1).toIso8601String(),
      KeyPreferencesGroup$Test.doubleValue.groupedKey: 3.14,
      KeyPreferencesGroup$Test.listStringValue.groupedKey: ['value1', 'value2'],
      KeyPreferencesGroup$Test.complexTypeValue.groupedKey: const ComplexType(
        string: 'complex',
        intValue: 100,
      ),
    });

    store = KeyValueSharedPreferences();
    await store.initialization(version: 1);
  });

  group('read', () {
    test(
      'int',
      () => expect(store.read(KeyPreferencesGroup$Test.intValue), 42),
    );
    test(
      'string',
      () => expect(store.read(KeyPreferencesGroup$Test.stringValue), 'test'),
    );
    test(
      'bool',
      () => expect(store.read(KeyPreferencesGroup$Test.boolValue), true),
    );
    test(
      'DateTime',
      () => expect(
        store.read(KeyPreferencesGroup$Test.dateTimeValue),
        DateTime(2023, 1, 1),
      ),
    );
    test(
      'double',
      () => expect(store.read(KeyPreferencesGroup$Test.doubleValue), 3.14),
    );
    test(
      'List<String>',
      () => expect(store.read(KeyPreferencesGroup$Test.listStringValue), [
        'value1',
        'value2',
      ]),
    );
    test(
      'ComplexType',
      () => expect(
        store.read(KeyPreferencesGroup$Test.complexTypeValue),
        const ComplexType(string: 'complex', intValue: 100),
      ),
    );
    test(
      'unknown key returns null',
      () => expect(store.read(KeyPreferences<String>('unknown')), isNull),
    );
  });

  group('write', () {
    test('int', () async {
      await store.write(KeyPreferencesGroup$Test.intValue, 100);
      expect(store.read(KeyPreferencesGroup$Test.intValue), 100);
    });

    test('string', () async {
      await store.write(KeyPreferencesGroup$Test.stringValue, 'new value');
      expect(store.read(KeyPreferencesGroup$Test.stringValue), 'new value');
    });

    test('bool', () async {
      await store.write(KeyPreferencesGroup$Test.boolValue, false);
      expect(store.read(KeyPreferencesGroup$Test.boolValue), false);
    });

    test('DateTime', () async {
      final newDateTime = DateTime(2024, 1, 1);
      await store.write(KeyPreferencesGroup$Test.dateTimeValue, newDateTime);
      expect(store.read(KeyPreferencesGroup$Test.dateTimeValue), newDateTime);
    });

    test('double', () async {
      await store.write(KeyPreferencesGroup$Test.doubleValue, 2.71);
      expect(store.read(KeyPreferencesGroup$Test.doubleValue), 2.71);
    });

    test('List<String>', () async {
      await store.write(KeyPreferencesGroup$Test.listStringValue, [
        'new1',
        'new2',
      ]);
      expect(store.read(KeyPreferencesGroup$Test.listStringValue), [
        'new1',
        'new2',
      ]);
    });

    test('ComplexType', () async {
      const newValue = ComplexType(string: 'new', intValue: 200);
      await store.write(KeyPreferencesGroup$Test.complexTypeValue, newValue);
      expect(store.read(KeyPreferencesGroup$Test.complexTypeValue), newValue);
    });

    test('reading wrong type returns null', () async {
      final key = KeyPreferencesGroup$Test.wrongTypeValue; //double
      await expectLater(
        store.write(key, 'String is not a double'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('contains & remove', () {
    test('contains', () async {
      expect(await store.contains(KeyPreferencesGroup$Test.intValue), isTrue);
      expect(
        await store.contains(KeyPreferences<String>('nonExistentKey')),
        isFalse,
      );
    });

    test('remove', () async {
      await store.write(KeyPreferencesGroup$Test.intValue, null);
      expect(store.read(KeyPreferencesGroup$Test.intValue), isNull);
    });
  });

  group('complex user model read write remove', () {
    test('write and read user model without parser', () async {
      await store.write(
        KeyPreferencesGroup$Test.userKeyWithoutParser,
        User.alice(),
      );

      expect(
        () => store.read(KeyPreferencesGroup$Test.userKeyWithoutParser),
        throwsA(isA<ValuePreferencesParserException<User>>()),
      );
    });
    test('write and read user model', () async {
      await store.write(KeyPreferencesGroup$Test.userKey, User.alice());
      final user = store.read(KeyPreferencesGroup$Test.userKey)!;
      expect(user, isNotNull);
      expect(user.name, 'Alice');
      expect(user.age, 30);
    });

    test('write and remove user model', () async {
      await store.write(KeyPreferencesGroup$Test.userKey, User.alice());
      final user = store.read(KeyPreferencesGroup$Test.userKey)!;
      expect(user, isNotNull);
      await store.write(KeyPreferencesGroup$Test.userKey, null);
      expect(store.read(KeyPreferencesGroup$Test.userKey), isNull);
    });
  });
}
