import 'package:flutter_test/flutter_test.dart';
import 'package:kv_preferences/kv_preferences.dart';

import 'key_preferences_group_utils.dart';

void main() {
  late KeyValueSharedPreferences store;

  setUp(() async {
    const versionValue = 1;
    final version = KeyPreferencesGroup$Store.version;
    final intKey = KeyPreferencesGroup$Test.intValue;
    final stringKey = KeyPreferencesGroup$Test.stringValue;
    final boolKey = KeyPreferencesGroup$Test.boolValue;
    final dateTimeKey = KeyPreferencesGroup$Test.dateTimeValue;
    final doubleKey = KeyPreferencesGroup$Test.doubleValue;
    final listStringKey = KeyPreferencesGroup$Test.listStringValue;
    final complexTypeKey = KeyPreferencesGroup$Test.complexTypeValue;
    SharedPreferences.setMockInitialValues({
      version.groupedKey: versionValue,
      intKey.groupedKey: 42,
      stringKey.groupedKey: 'test',
      boolKey.groupedKey: true,
      dateTimeKey.groupedKey: DateTime(2023, 1, 1).toIso8601String(),
      doubleKey.groupedKey: 3.14,
      listStringKey.groupedKey: ['value1', 'value2'],
      complexTypeKey.groupedKey: const ComplexType(
        string: 'complex',
        intValue: 100,
      ),
    });
    store = KeyValueSharedPreferences();
    await store.initialization(version: 1);
  });

  test(
    'test read int value',
    () => expect(store.read(KeyPreferencesGroup$Test.intValue), 42),
  );

  test('test read string value', () async {
    final store = KeyValueSharedPreferences();
    await store.initialization(version: 1);
    final stringValue = store.read(KeyPreferencesGroup$Test.stringValue);
    expect(stringValue, 'test');
  });

  test('test read bool value', () async {
    final store = KeyValueSharedPreferences();
    await store.initialization(version: 1);
    final boolValue = store.read(KeyPreferencesGroup$Test.boolValue);
    expect(boolValue, true);
  });

  test('test read DateTime value', () async {
    final store = KeyValueSharedPreferences();
    await store.initialization(version: 1);
    final dateTimeValue = store.read(KeyPreferencesGroup$Test.dateTimeValue);
    expect(dateTimeValue, DateTime(2023, 1, 1));
  });

  test('test read double value', () async {
    final store = KeyValueSharedPreferences();
    await store.initialization(version: 1);
    final doubleValue = store.read(KeyPreferencesGroup$Test.doubleValue);
    expect(doubleValue, 3.14);
  });

  test('test read List<String> value', () async {
    final store = KeyValueSharedPreferences();
    await store.initialization(version: 1);
    final listStringValue = store.read(
      KeyPreferencesGroup$Test.listStringValue,
    );
    expect(listStringValue, ['value1', 'value2']);
  });

  test('test read ComplexType value', () async {
    final store = KeyValueSharedPreferences();
    await store.initialization(version: 1);
    final complexTypeValue = store.read(
      KeyPreferencesGroup$Test.complexTypeValue,
    );
    expect(
      complexTypeValue,
      const ComplexType(string: 'complex', intValue: 100),
    );
  });

  test('test read empty group', () async {
    final store = KeyValueSharedPreferences();
    await store.initialization(version: 1);
    final emptyGroup = store.read(KeyPreferencesGroup$Test.nonExistingKey);
    expect(emptyGroup, null);
  });
  test('test read null group', () async {
    final store = KeyValueSharedPreferences();
    await store.initialization(version: 1);
    final nullGroup = store.read(KeyPreferencesGroup$Test.nonExistingKey);
    expect(nullGroup, null);
  });

  test('test write int value', () async {
    final store = KeyValueSharedPreferences();
    await store.initialization(version: 1);
    await store.write(KeyPreferencesGroup$Test.intValue, 100);
    final intValue = store.read(KeyPreferencesGroup$Test.intValue);
    expect(intValue, 100);
  });

  test('test write string value', () async {
    final store = KeyValueSharedPreferences();
    await store.initialization(version: 1);
    await store.write(KeyPreferencesGroup$Test.stringValue, 'new value');
    final stringValue = store.read(KeyPreferencesGroup$Test.stringValue);
    expect(stringValue, 'new value');
  });

  test('test write bool value', () async {
    final store = KeyValueSharedPreferences();
    await store.initialization(version: 1);
    await store.write(KeyPreferencesGroup$Test.boolValue, false);
    final boolValue = store.read(KeyPreferencesGroup$Test.boolValue);
    expect(boolValue, false);
  });

  test('test write DateTime value', () async {
    final store = KeyValueSharedPreferences();
    await store.initialization(version: 1);
    final newDateTime = DateTime(2024, 1, 1);
    await store.write(KeyPreferencesGroup$Test.dateTimeValue, newDateTime);
    final dateTimeValue = store.read(KeyPreferencesGroup$Test.dateTimeValue);
    expect(dateTimeValue, newDateTime);
  });

  test('test write double value', () async {
    final store = KeyValueSharedPreferences();
    await store.initialization(version: 1);
    await store.write(KeyPreferencesGroup$Test.doubleValue, 2.71);
    final doubleValue = store.read(KeyPreferencesGroup$Test.doubleValue);
    expect(doubleValue, 2.71);
  });

  test('test write List<String> value', () async {
    final store = KeyValueSharedPreferences();
    await store.initialization(version: 1);
    await store.write(KeyPreferencesGroup$Test.listStringValue, [
      'new1',
      'new2',
    ]);
    final listStringValue = store.read(
      KeyPreferencesGroup$Test.listStringValue,
    );
    expect(listStringValue, ['new1', 'new2']);
  });

  test('test write ComplexType value', () async {
    final store = KeyValueSharedPreferences();
    await store.initialization(version: 1);
    const newComplexType = ComplexType(string: 'new', intValue: 200);
    await store.write(
      KeyPreferencesGroup$Test.complexTypeValue,
      newComplexType,
    );
    final complexTypeValue = store.read(
      KeyPreferencesGroup$Test.complexTypeValue,
    );
    expect(complexTypeValue, newComplexType);
  });

  test('test contains key', () async {
    final store = KeyValueSharedPreferences();
    await store.initialization(version: 1);
    final containsIntKey = await store.contains(
      KeyPreferencesGroup$Test.intValue,
    );
    expect(containsIntKey, true);
    final containsNonExistentKey = await store.contains(
      KeyPreferences<String>('nonExistentKey'),
    );
    expect(containsNonExistentKey, false);
  });

  test('test remove key', () async {
    final store = KeyValueSharedPreferences();
    await store.initialization(version: 1);
    await store.write(KeyPreferencesGroup$Test.intValue, null);
    final intValue = store.read(KeyPreferencesGroup$Test.intValue);
    expect(intValue, null);
  });

  test('downgrade version — no migration is applied', () async {
    final migrator = MultiStepMigrator(store);

    await store.mockInitiazation({
      KeyPreferencesGroup$Store.version.groupedKey: 5,
      KeyPreferencesGroup$Test.intValue.groupedKey: 200,
    });

    await store.initialization(version: 1, migrator: migrator);

    expect(store.read(KeyPreferencesGroup$Test.intValue), 200);
    expect(migrator.stepsCalled, isEmpty);
  });
}
