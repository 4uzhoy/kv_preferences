/// {@template key_value_preferences_migrator}
/// {@category Preferences}
/// An abstract class for migrating key-value preferences stores.
/// This class provides methods to migrate the store from one version to another,
/// and to check if migration is needed based on the current store version.
/// {@endtemplate}
abstract interface class KeyValuePreferencesMigrator {
  /// Migrates the store from the current version to the specified [toVersion].
  ///
  /// The [fromVersion] is the current version of the store.
  Future<void> migrate(int fromVersion, int toVersion);

  /// Checks if migration is needed based on the current store version.
  ///
  /// Returns `true` if migration is required, otherwise `false`.
  Future<bool> needsMigration(int currentVersion);
}

/// {@template migration_exception}
/// {@category Preferences}
/// An exception thrown when migration cannot be performed.
/// This exception indicates that the current version of the store
/// cannot be migrated to the target version.
/// {@endtemplate}
final class MigrationException implements Exception {
  /// The current version of the store.
  final int currentVersion;

  /// The target version to migrate to.
  final int targetVersion;

  /// Creates a new [MigrationException].
  MigrationException(this.currentVersion, this.targetVersion);

  @override
  String toString() =>
      'MigrationException: Cannot migrate from version $currentVersion to $targetVersion.';
}

/// {@template migration_not_passed_exception}
/// {@category Preferences}
/// An exception thrown when a migration has not been passed.
/// This exception indicates that the migration process was not completed
/// successfully, and the store is still at the current version.
/// {@endtemplate}
final class MigrationNotPassedException implements Exception {
  /// The current version of the store.
  final int currentVersion;

  /// The target version to migrate to.
  final int targetVersion;

  /// Creates a new [MigrationNotPassedException].
  MigrationNotPassedException(this.currentVersion, this.targetVersion);

  @override
  String toString() =>
      'MigrationNotPassedException: Migration from version $currentVersion to $targetVersion was not passed.';
}
