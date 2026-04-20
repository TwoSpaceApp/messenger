import 'package:drift/drift.dart';
import 'package:two_space_app/features/chat/data/local/connection/_shared.dart';

part 'aegis_chat_database.g.dart';

class AegisConversations extends Table {
  @override
  String get tableName => 'aegis_conversations';

  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get kind => text()();
  IntColumn get updatedAtEpochMs => integer()();
  TextColumn get lastMessage => text().nullable()();
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get description => text().nullable()();
  IntColumn get peerUserId => integer().nullable()();
  TextColumn get peerUsername => text().nullable()();
  IntColumn get channelId => integer().nullable()();
  BoolColumn get isPublic => boolean().withDefault(const Constant(false))();
  BoolColumn get showMessageHistory =>
      boolean().withDefault(const Constant(false))();
  TextColumn get memberUserIdsJson =>
      text().withDefault(const Constant('[]'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AegisMessages extends Table {
  @override
  String get tableName => 'aegis_messages';

  TextColumn get id => text()();
  TextColumn get roomId => text()();
  TextColumn get senderId => text()();
  TextColumn get content => text()();
  IntColumn get sentAtEpochMs => integer()();
  TextColumn get type => text().withDefault(const Constant('m.text'))();
  TextColumn get mediaId => text().nullable()();
  IntColumn get replyToMessageId => integer().nullable()();
  BoolColumn get isDelivered => boolean().withDefault(const Constant(false))();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  IntColumn get deliveredAtEpochMs => integer().nullable()();
  IntColumn get readAtEpochMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AegisProfiles extends Table {
  @override
  String get tableName => 'aegis_profiles';

  IntColumn get userId => integer()();
  TextColumn get payloadJson => text()();
  TextColumn get username => text().nullable()();
  TextColumn get displayName => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get presenceStatus => text().nullable()();
  BoolColumn get isOnline => boolean().withDefault(const Constant(false))();
  IntColumn get lastSeenAtEpochMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {userId};
}

class AegisMetadata extends Table {
  @override
  String get tableName => 'aegis_metadata';

  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

class AegisOfflineQueue extends Table {
  @override
  String get tableName => 'aegis_offline_queue';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get chatId => text()();
  TextColumn get content => text()();
  TextColumn get type => text()();
  TextColumn get localMessageId => text().nullable()();
  TextColumn get mediaFileId => text().nullable()();
  IntColumn get replyToMessageId => integer().nullable()();
  IntColumn get createdAtEpochMs => integer()();
  BoolColumn get sent => boolean().withDefault(const Constant(false))();
  TextColumn get errorMessage => text().nullable()();
}

class AegisPeopleFavorites extends Table {
  @override
  String get tableName => 'aegis_people_favorites';

  TextColumn get personId => text()();

  @override
  Set<Column<Object>> get primaryKey => {personId};
}

class AegisPeopleEntries extends Table {
  @override
  String get tableName => 'aegis_people_entries';

  TextColumn get bucket => text()();
  TextColumn get personId => text()();
  TextColumn get payloadJson => text()();
  TextColumn get displayName => text()();
  TextColumn get username => text().nullable()();
  TextColumn get remoteUserId => text().nullable()();
  BoolColumn get isTwoSpaceUser =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isDeviceContact =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isOnline => boolean().withDefault(const Constant(false))();
  TextColumn get presenceStatus => text().nullable()();
  IntColumn get lastSeenAtEpochMs => integer().nullable()();
  IntColumn get lastInteractionAtEpochMs => integer().nullable()();
  IntColumn get sortEpochMs => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {bucket, personId};
}

class AegisPeopleCallHistory extends Table {
  @override
  String get tableName => 'aegis_people_call_history';

  TextColumn get id => text()();
  TextColumn get personId => text()();
  TextColumn get payloadJson => text()();
  IntColumn get startedAtEpochMs => integer()();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  BoolColumn get isVideo => boolean().withDefault(const Constant(false))();
  TextColumn get direction => text()();
  TextColumn get outcome => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    AegisConversations,
    AegisMessages,
    AegisProfiles,
    AegisMetadata,
    AegisOfflineQueue,
    AegisPeopleFavorites,
    AegisPeopleEntries,
    AegisPeopleCallHistory,
  ],
)
class AegisChatDatabase extends _$AegisChatDatabase {
  factory AegisChatDatabase() => _shared;
  AegisChatDatabase._internal() : super(openDatabase());

  static final AegisChatDatabase _shared = AegisChatDatabase._internal();

  static AegisChatDatabase get instance => _shared;

  AegisChatDatabase.forExecutor(super.executor);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _createIndexes();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 1) {
        await migrator.createAll();
      }
      if (from < 2) {
        await migrator.createTable(aegisOfflineQueue);
      }
      if (from < 3) {
        await migrator.createTable(aegisPeopleFavorites);
        await migrator.createTable(aegisPeopleEntries);
        await migrator.createTable(aegisPeopleCallHistory);
      }
      if (from < 4) {
        await migrator.addColumn(aegisMessages, aegisMessages.isDelivered);
        await migrator.addColumn(aegisMessages, aegisMessages.isRead);
        await migrator.addColumn(
          aegisMessages,
          aegisMessages.deliveredAtEpochMs,
        );
        await migrator.addColumn(aegisMessages, aegisMessages.readAtEpochMs);
      }
      if (from < 5) {
        await migrator.addColumn(
          aegisMessages,
          aegisMessages.replyToMessageId,
        );
      }
      if (from < 6) {
        await migrator.addColumn(
          aegisOfflineQueue,
          aegisOfflineQueue.localMessageId,
        );
        await migrator.addColumn(
          aegisOfflineQueue,
          aegisOfflineQueue.mediaFileId,
        );
        await migrator.addColumn(
          aegisOfflineQueue,
          aegisOfflineQueue.replyToMessageId,
        );
      }
      await _createIndexes();
    },
  );

  Future<void> _createIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_aegis_messages_room_time '
      'ON aegis_messages (room_id, sent_at_epoch_ms)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_aegis_conversations_updated '
      'ON aegis_conversations (updated_at_epoch_ms)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_aegis_people_entries_bucket_sort '
      'ON aegis_people_entries (bucket, sort_epoch_ms DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_aegis_people_call_history_started '
      'ON aegis_people_call_history (started_at_epoch_ms DESC)',
    );
  }
}
