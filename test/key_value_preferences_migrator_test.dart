import 'package:flutter_test/flutter_test.dart';
import 'package:kv_preferences/kv_preferences.dart';

import 'key_preferences_group_utils.dart';

void main() {
  late KeyValueSharedPreferences store;
  setUp(() async {
    store = KeyValueSharedPreferences();
    await store.mockInitiazation({
      KeyPreferencesGroup$Store.version.groupedKey: 1,
      KeyPreferencesGroup$Test.intValue.groupedKey: 42,
      KeyPreferencesGroup$Test.stringValue.groupedKey: 'test',
      KeyPreferencesGroup$Test.boolValue.groupedKey: true,
      KeyPreferencesGroup$Test.dateTimeValue.groupedKey: DateTime(2023, 1, 1),
      KeyPreferencesGroup$Test.doubleValue.groupedKey: 3.14,
      KeyPreferencesGroup$Test.listStringValue.groupedKey: ['value1', 'value2'],
      KeyPreferencesGroup$Test.complexTypeValue.groupedKey: const ComplexType(
        string: 'complex',
        intValue: 100,
      ),
    });
  });

  group('Migrator tests', () {
    test('initialization with equal version — allowed', () async {
      await store.initialization(version: 1);
    });

    test('initialization with version < current — allowed', () async {
      await store.initialization(version: 0);
    });

    test(
      'initialization with version > current — throws MigrationNotPassedException',
      () async {
        await expectLater(
          store.initialization(version: 6),
          throwsA(isA<MigrationNotPassedException>()),
        );
      },
    );

    test(
      'initialization with migrator applies changes and sets version',
      () async {
        final migrator = TestMigrator(store);

        await store.initialization(version: 2, migrator: migrator);

        expect(store.read(KeyPreferencesGroup$Store.version), 2);
        expect(store.read(KeyPreferencesGroup$Test.intValue), 999);
        expect(store.read(KeyPreferencesGroup$Test.stringValue), 'migrated');
        expect(store.read(KeyPreferencesGroup$Test.boolValue), false);
        expect(
          store.read(KeyPreferencesGroup$Test.dateTimeValue),
          DateTime(2024, 1, 1),
        );
        expect(store.read(KeyPreferencesGroup$Test.doubleValue), 6.28);
        expect(store.read(KeyPreferencesGroup$Test.listStringValue), [
          'm1',
          'm2',
        ]);
        expect(
          store.read(KeyPreferencesGroup$Test.complexTypeValue),
          const ComplexType(string: 'migrated', intValue: 200),
        );
      },
    );

    test(
      'initialization with migrator where migration not needed — does nothing',
      () async {
        final store = KeyValueSharedPreferences();
        final migrator = TestMigratorNoOp();

        await store.initialization(version: 2, migrator: migrator);

        expect(store.read(KeyPreferencesGroup$Test.intValue), 42);
        expect(store.read(KeyPreferencesGroup$Test.stringValue), 'test');
      },
    );
  });

  test('initialization with invalidate == true clears preferences', () async {
    final store = KeyValueSharedPreferences();

    await store.initialization(version: 1, invalidate: true);

    expect(store.read(KeyPreferencesGroup$Test.intValue), isNull);
    expect(store.read(KeyPreferencesGroup$Test.stringValue), isNull);
    expect(store.read(KeyPreferencesGroup$Test.boolValue), isNull);
    expect(store.read(KeyPreferencesGroup$Test.dateTimeValue), isNull);
    expect(store.read(KeyPreferencesGroup$Test.doubleValue), isNull);
    expect(store.read(KeyPreferencesGroup$Test.listStringValue), isNull);
    expect(store.read(KeyPreferencesGroup$Test.complexTypeValue), isNull);
    expect(store.read(KeyPreferencesGroup$Store.version), 1);
  });

  test('migrator upgrades from v1 to v5 with correct steps', () async {
    final store = KeyValueSharedPreferences();
    final migrator = MultiStepMigrator(store);

    await store.mockInitiazation({
      KeyPreferencesGroup$Store.version.groupedKey: 1,
      KeyPreferencesGroup$Test.intValue.groupedKey: 100,
    });

    await store.initialization(version: 5, migrator: migrator);

    expect(store.read(KeyPreferencesGroup$Store.version), 5);
    expect(store.read(KeyPreferencesGroup$Test.intValue), 104);
    expect(migrator.stepsCalled, [1, 2, 3, 4]);
  });

  test('migrator is not called when fromVersion == toVersion', () async {
    final migrator = MultiStepMigrator(store);
    await store.initialization(version: 1, migrator: migrator);
    expect(migrator.stepsCalled, isEmpty);
  });

  test('migrator applies all intermediate steps sequentially', () async {
    final migrator = MultiStepMigrator(store);

    await store.mockInitiazation({
      KeyPreferencesGroup$Store.version.groupedKey: 2,
      KeyPreferencesGroup$Test.intValue.groupedKey: 99,
    });

    await store.initialization(version: 5, migrator: migrator);

    expect(store.read(KeyPreferencesGroup$Test.intValue), 104);
    expect(migrator.stepsCalled, [2, 3, 4]);
  });

  test('exception in migrator throws', () async {
    final store = KeyValueSharedPreferences();
    final migrator = FailingMigrator();

    await store.mockInitiazation({
      KeyPreferencesGroup$Store.version.groupedKey: 1,
    });

    await expectLater(
      store.initialization(version: 2, migrator: migrator),
      throwsException,
    );
  });
}
