// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aegis_chat_database.dart';

// ignore_for_file: type=lint
class $AegisConversationsTable extends AegisConversations
    with TableInfo<$AegisConversationsTable, AegisConversation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AegisConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtEpochMsMeta = const VerificationMeta(
    'updatedAtEpochMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtEpochMs = GeneratedColumn<int>(
    'updated_at_epoch_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastMessageMeta = const VerificationMeta(
    'lastMessage',
  );
  @override
  late final GeneratedColumn<String> lastMessage = GeneratedColumn<String>(
    'last_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unreadCountMeta = const VerificationMeta(
    'unreadCount',
  );
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
    'unread_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _peerUserIdMeta = const VerificationMeta(
    'peerUserId',
  );
  @override
  late final GeneratedColumn<int> peerUserId = GeneratedColumn<int>(
    'peer_user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _peerUsernameMeta = const VerificationMeta(
    'peerUsername',
  );
  @override
  late final GeneratedColumn<String> peerUsername = GeneratedColumn<String>(
    'peer_username',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _channelIdMeta = const VerificationMeta(
    'channelId',
  );
  @override
  late final GeneratedColumn<int> channelId = GeneratedColumn<int>(
    'channel_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPublicMeta = const VerificationMeta(
    'isPublic',
  );
  @override
  late final GeneratedColumn<bool> isPublic = GeneratedColumn<bool>(
    'is_public',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_public" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _showMessageHistoryMeta =
      const VerificationMeta('showMessageHistory');
  @override
  late final GeneratedColumn<bool> showMessageHistory = GeneratedColumn<bool>(
    'show_message_history',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_message_history" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _memberUserIdsJsonMeta = const VerificationMeta(
    'memberUserIdsJson',
  );
  @override
  late final GeneratedColumn<String> memberUserIdsJson =
      GeneratedColumn<String>(
        'member_user_ids_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    kind,
    updatedAtEpochMs,
    lastMessage,
    unreadCount,
    avatarUrl,
    description,
    peerUserId,
    peerUsername,
    channelId,
    isPublic,
    showMessageHistory,
    memberUserIdsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'aegis_conversations';
  @override
  VerificationContext validateIntegrity(
    Insertable<AegisConversation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('updated_at_epoch_ms')) {
      context.handle(
        _updatedAtEpochMsMeta,
        updatedAtEpochMs.isAcceptableOrUnknown(
          data['updated_at_epoch_ms']!,
          _updatedAtEpochMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtEpochMsMeta);
    }
    if (data.containsKey('last_message')) {
      context.handle(
        _lastMessageMeta,
        lastMessage.isAcceptableOrUnknown(
          data['last_message']!,
          _lastMessageMeta,
        ),
      );
    }
    if (data.containsKey('unread_count')) {
      context.handle(
        _unreadCountMeta,
        unreadCount.isAcceptableOrUnknown(
          data['unread_count']!,
          _unreadCountMeta,
        ),
      );
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('peer_user_id')) {
      context.handle(
        _peerUserIdMeta,
        peerUserId.isAcceptableOrUnknown(
          data['peer_user_id']!,
          _peerUserIdMeta,
        ),
      );
    }
    if (data.containsKey('peer_username')) {
      context.handle(
        _peerUsernameMeta,
        peerUsername.isAcceptableOrUnknown(
          data['peer_username']!,
          _peerUsernameMeta,
        ),
      );
    }
    if (data.containsKey('channel_id')) {
      context.handle(
        _channelIdMeta,
        channelId.isAcceptableOrUnknown(data['channel_id']!, _channelIdMeta),
      );
    }
    if (data.containsKey('is_public')) {
      context.handle(
        _isPublicMeta,
        isPublic.isAcceptableOrUnknown(data['is_public']!, _isPublicMeta),
      );
    }
    if (data.containsKey('show_message_history')) {
      context.handle(
        _showMessageHistoryMeta,
        showMessageHistory.isAcceptableOrUnknown(
          data['show_message_history']!,
          _showMessageHistoryMeta,
        ),
      );
    }
    if (data.containsKey('member_user_ids_json')) {
      context.handle(
        _memberUserIdsJsonMeta,
        memberUserIdsJson.isAcceptableOrUnknown(
          data['member_user_ids_json']!,
          _memberUserIdsJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AegisConversation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AegisConversation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      updatedAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_epoch_ms'],
      )!,
      lastMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_message'],
      ),
      unreadCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unread_count'],
      )!,
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      peerUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}peer_user_id'],
      ),
      peerUsername: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}peer_username'],
      ),
      channelId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}channel_id'],
      ),
      isPublic: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_public'],
      )!,
      showMessageHistory: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_message_history'],
      )!,
      memberUserIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_user_ids_json'],
      )!,
    );
  }

  @override
  $AegisConversationsTable createAlias(String alias) {
    return $AegisConversationsTable(attachedDatabase, alias);
  }
}

class AegisConversation extends DataClass
    implements Insertable<AegisConversation> {
  final String id;
  final String title;
  final String kind;
  final int updatedAtEpochMs;
  final String? lastMessage;
  final int unreadCount;
  final String? avatarUrl;
  final String? description;
  final int? peerUserId;
  final String? peerUsername;
  final int? channelId;
  final bool isPublic;
  final bool showMessageHistory;
  final String memberUserIdsJson;
  const AegisConversation({
    required this.id,
    required this.title,
    required this.kind,
    required this.updatedAtEpochMs,
    this.lastMessage,
    required this.unreadCount,
    this.avatarUrl,
    this.description,
    this.peerUserId,
    this.peerUsername,
    this.channelId,
    required this.isPublic,
    required this.showMessageHistory,
    required this.memberUserIdsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['kind'] = Variable<String>(kind);
    map['updated_at_epoch_ms'] = Variable<int>(updatedAtEpochMs);
    if (!nullToAbsent || lastMessage != null) {
      map['last_message'] = Variable<String>(lastMessage);
    }
    map['unread_count'] = Variable<int>(unreadCount);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || peerUserId != null) {
      map['peer_user_id'] = Variable<int>(peerUserId);
    }
    if (!nullToAbsent || peerUsername != null) {
      map['peer_username'] = Variable<String>(peerUsername);
    }
    if (!nullToAbsent || channelId != null) {
      map['channel_id'] = Variable<int>(channelId);
    }
    map['is_public'] = Variable<bool>(isPublic);
    map['show_message_history'] = Variable<bool>(showMessageHistory);
    map['member_user_ids_json'] = Variable<String>(memberUserIdsJson);
    return map;
  }

  AegisConversationsCompanion toCompanion(bool nullToAbsent) {
    return AegisConversationsCompanion(
      id: Value(id),
      title: Value(title),
      kind: Value(kind),
      updatedAtEpochMs: Value(updatedAtEpochMs),
      lastMessage: lastMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessage),
      unreadCount: Value(unreadCount),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      peerUserId: peerUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(peerUserId),
      peerUsername: peerUsername == null && nullToAbsent
          ? const Value.absent()
          : Value(peerUsername),
      channelId: channelId == null && nullToAbsent
          ? const Value.absent()
          : Value(channelId),
      isPublic: Value(isPublic),
      showMessageHistory: Value(showMessageHistory),
      memberUserIdsJson: Value(memberUserIdsJson),
    );
  }

  factory AegisConversation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AegisConversation(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      kind: serializer.fromJson<String>(json['kind']),
      updatedAtEpochMs: serializer.fromJson<int>(json['updatedAtEpochMs']),
      lastMessage: serializer.fromJson<String?>(json['lastMessage']),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      description: serializer.fromJson<String?>(json['description']),
      peerUserId: serializer.fromJson<int?>(json['peerUserId']),
      peerUsername: serializer.fromJson<String?>(json['peerUsername']),
      channelId: serializer.fromJson<int?>(json['channelId']),
      isPublic: serializer.fromJson<bool>(json['isPublic']),
      showMessageHistory: serializer.fromJson<bool>(json['showMessageHistory']),
      memberUserIdsJson: serializer.fromJson<String>(json['memberUserIdsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'kind': serializer.toJson<String>(kind),
      'updatedAtEpochMs': serializer.toJson<int>(updatedAtEpochMs),
      'lastMessage': serializer.toJson<String?>(lastMessage),
      'unreadCount': serializer.toJson<int>(unreadCount),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'description': serializer.toJson<String?>(description),
      'peerUserId': serializer.toJson<int?>(peerUserId),
      'peerUsername': serializer.toJson<String?>(peerUsername),
      'channelId': serializer.toJson<int?>(channelId),
      'isPublic': serializer.toJson<bool>(isPublic),
      'showMessageHistory': serializer.toJson<bool>(showMessageHistory),
      'memberUserIdsJson': serializer.toJson<String>(memberUserIdsJson),
    };
  }

  AegisConversation copyWith({
    String? id,
    String? title,
    String? kind,
    int? updatedAtEpochMs,
    Value<String?> lastMessage = const Value.absent(),
    int? unreadCount,
    Value<String?> avatarUrl = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<int?> peerUserId = const Value.absent(),
    Value<String?> peerUsername = const Value.absent(),
    Value<int?> channelId = const Value.absent(),
    bool? isPublic,
    bool? showMessageHistory,
    String? memberUserIdsJson,
  }) => AegisConversation(
    id: id ?? this.id,
    title: title ?? this.title,
    kind: kind ?? this.kind,
    updatedAtEpochMs: updatedAtEpochMs ?? this.updatedAtEpochMs,
    lastMessage: lastMessage.present ? lastMessage.value : this.lastMessage,
    unreadCount: unreadCount ?? this.unreadCount,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    description: description.present ? description.value : this.description,
    peerUserId: peerUserId.present ? peerUserId.value : this.peerUserId,
    peerUsername: peerUsername.present ? peerUsername.value : this.peerUsername,
    channelId: channelId.present ? channelId.value : this.channelId,
    isPublic: isPublic ?? this.isPublic,
    showMessageHistory: showMessageHistory ?? this.showMessageHistory,
    memberUserIdsJson: memberUserIdsJson ?? this.memberUserIdsJson,
  );
  AegisConversation copyWithCompanion(AegisConversationsCompanion data) {
    return AegisConversation(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      kind: data.kind.present ? data.kind.value : this.kind,
      updatedAtEpochMs: data.updatedAtEpochMs.present
          ? data.updatedAtEpochMs.value
          : this.updatedAtEpochMs,
      lastMessage: data.lastMessage.present
          ? data.lastMessage.value
          : this.lastMessage,
      unreadCount: data.unreadCount.present
          ? data.unreadCount.value
          : this.unreadCount,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      description: data.description.present
          ? data.description.value
          : this.description,
      peerUserId: data.peerUserId.present
          ? data.peerUserId.value
          : this.peerUserId,
      peerUsername: data.peerUsername.present
          ? data.peerUsername.value
          : this.peerUsername,
      channelId: data.channelId.present ? data.channelId.value : this.channelId,
      isPublic: data.isPublic.present ? data.isPublic.value : this.isPublic,
      showMessageHistory: data.showMessageHistory.present
          ? data.showMessageHistory.value
          : this.showMessageHistory,
      memberUserIdsJson: data.memberUserIdsJson.present
          ? data.memberUserIdsJson.value
          : this.memberUserIdsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AegisConversation(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('kind: $kind, ')
          ..write('updatedAtEpochMs: $updatedAtEpochMs, ')
          ..write('lastMessage: $lastMessage, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('description: $description, ')
          ..write('peerUserId: $peerUserId, ')
          ..write('peerUsername: $peerUsername, ')
          ..write('channelId: $channelId, ')
          ..write('isPublic: $isPublic, ')
          ..write('showMessageHistory: $showMessageHistory, ')
          ..write('memberUserIdsJson: $memberUserIdsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    kind,
    updatedAtEpochMs,
    lastMessage,
    unreadCount,
    avatarUrl,
    description,
    peerUserId,
    peerUsername,
    channelId,
    isPublic,
    showMessageHistory,
    memberUserIdsJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AegisConversation &&
          other.id == this.id &&
          other.title == this.title &&
          other.kind == this.kind &&
          other.updatedAtEpochMs == this.updatedAtEpochMs &&
          other.lastMessage == this.lastMessage &&
          other.unreadCount == this.unreadCount &&
          other.avatarUrl == this.avatarUrl &&
          other.description == this.description &&
          other.peerUserId == this.peerUserId &&
          other.peerUsername == this.peerUsername &&
          other.channelId == this.channelId &&
          other.isPublic == this.isPublic &&
          other.showMessageHistory == this.showMessageHistory &&
          other.memberUserIdsJson == this.memberUserIdsJson);
}

class AegisConversationsCompanion extends UpdateCompanion<AegisConversation> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> kind;
  final Value<int> updatedAtEpochMs;
  final Value<String?> lastMessage;
  final Value<int> unreadCount;
  final Value<String?> avatarUrl;
  final Value<String?> description;
  final Value<int?> peerUserId;
  final Value<String?> peerUsername;
  final Value<int?> channelId;
  final Value<bool> isPublic;
  final Value<bool> showMessageHistory;
  final Value<String> memberUserIdsJson;
  final Value<int> rowid;
  const AegisConversationsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.kind = const Value.absent(),
    this.updatedAtEpochMs = const Value.absent(),
    this.lastMessage = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.peerUserId = const Value.absent(),
    this.peerUsername = const Value.absent(),
    this.channelId = const Value.absent(),
    this.isPublic = const Value.absent(),
    this.showMessageHistory = const Value.absent(),
    this.memberUserIdsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AegisConversationsCompanion.insert({
    required String id,
    required String title,
    required String kind,
    required int updatedAtEpochMs,
    this.lastMessage = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.peerUserId = const Value.absent(),
    this.peerUsername = const Value.absent(),
    this.channelId = const Value.absent(),
    this.isPublic = const Value.absent(),
    this.showMessageHistory = const Value.absent(),
    this.memberUserIdsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       kind = Value(kind),
       updatedAtEpochMs = Value(updatedAtEpochMs);
  static Insertable<AegisConversation> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? kind,
    Expression<int>? updatedAtEpochMs,
    Expression<String>? lastMessage,
    Expression<int>? unreadCount,
    Expression<String>? avatarUrl,
    Expression<String>? description,
    Expression<int>? peerUserId,
    Expression<String>? peerUsername,
    Expression<int>? channelId,
    Expression<bool>? isPublic,
    Expression<bool>? showMessageHistory,
    Expression<String>? memberUserIdsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (kind != null) 'kind': kind,
      if (updatedAtEpochMs != null) 'updated_at_epoch_ms': updatedAtEpochMs,
      if (lastMessage != null) 'last_message': lastMessage,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (description != null) 'description': description,
      if (peerUserId != null) 'peer_user_id': peerUserId,
      if (peerUsername != null) 'peer_username': peerUsername,
      if (channelId != null) 'channel_id': channelId,
      if (isPublic != null) 'is_public': isPublic,
      if (showMessageHistory != null)
        'show_message_history': showMessageHistory,
      if (memberUserIdsJson != null) 'member_user_ids_json': memberUserIdsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AegisConversationsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? kind,
    Value<int>? updatedAtEpochMs,
    Value<String?>? lastMessage,
    Value<int>? unreadCount,
    Value<String?>? avatarUrl,
    Value<String?>? description,
    Value<int?>? peerUserId,
    Value<String?>? peerUsername,
    Value<int?>? channelId,
    Value<bool>? isPublic,
    Value<bool>? showMessageHistory,
    Value<String>? memberUserIdsJson,
    Value<int>? rowid,
  }) {
    return AegisConversationsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      kind: kind ?? this.kind,
      updatedAtEpochMs: updatedAtEpochMs ?? this.updatedAtEpochMs,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      description: description ?? this.description,
      peerUserId: peerUserId ?? this.peerUserId,
      peerUsername: peerUsername ?? this.peerUsername,
      channelId: channelId ?? this.channelId,
      isPublic: isPublic ?? this.isPublic,
      showMessageHistory: showMessageHistory ?? this.showMessageHistory,
      memberUserIdsJson: memberUserIdsJson ?? this.memberUserIdsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (updatedAtEpochMs.present) {
      map['updated_at_epoch_ms'] = Variable<int>(updatedAtEpochMs.value);
    }
    if (lastMessage.present) {
      map['last_message'] = Variable<String>(lastMessage.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (peerUserId.present) {
      map['peer_user_id'] = Variable<int>(peerUserId.value);
    }
    if (peerUsername.present) {
      map['peer_username'] = Variable<String>(peerUsername.value);
    }
    if (channelId.present) {
      map['channel_id'] = Variable<int>(channelId.value);
    }
    if (isPublic.present) {
      map['is_public'] = Variable<bool>(isPublic.value);
    }
    if (showMessageHistory.present) {
      map['show_message_history'] = Variable<bool>(showMessageHistory.value);
    }
    if (memberUserIdsJson.present) {
      map['member_user_ids_json'] = Variable<String>(memberUserIdsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AegisConversationsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('kind: $kind, ')
          ..write('updatedAtEpochMs: $updatedAtEpochMs, ')
          ..write('lastMessage: $lastMessage, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('description: $description, ')
          ..write('peerUserId: $peerUserId, ')
          ..write('peerUsername: $peerUsername, ')
          ..write('channelId: $channelId, ')
          ..write('isPublic: $isPublic, ')
          ..write('showMessageHistory: $showMessageHistory, ')
          ..write('memberUserIdsJson: $memberUserIdsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AegisMessagesTable extends AegisMessages
    with TableInfo<$AegisMessagesTable, AegisMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AegisMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
    'room_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
    'sender_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sentAtEpochMsMeta = const VerificationMeta(
    'sentAtEpochMs',
  );
  @override
  late final GeneratedColumn<int> sentAtEpochMs = GeneratedColumn<int>(
    'sent_at_epoch_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('m.text'),
  );
  static const VerificationMeta _mediaIdMeta = const VerificationMeta(
    'mediaId',
  );
  @override
  late final GeneratedColumn<String> mediaId = GeneratedColumn<String>(
    'media_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _replyToMessageIdMeta = const VerificationMeta(
    'replyToMessageId',
  );
  @override
  late final GeneratedColumn<int> replyToMessageId = GeneratedColumn<int>(
    'reply_to_message_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDeliveredMeta = const VerificationMeta(
    'isDelivered',
  );
  @override
  late final GeneratedColumn<bool> isDelivered = GeneratedColumn<bool>(
    'is_delivered',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_delivered" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deliveredAtEpochMsMeta =
      const VerificationMeta('deliveredAtEpochMs');
  @override
  late final GeneratedColumn<int> deliveredAtEpochMs = GeneratedColumn<int>(
    'delivered_at_epoch_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _readAtEpochMsMeta = const VerificationMeta(
    'readAtEpochMs',
  );
  @override
  late final GeneratedColumn<int> readAtEpochMs = GeneratedColumn<int>(
    'read_at_epoch_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    roomId,
    senderId,
    content,
    sentAtEpochMs,
    type,
    mediaId,
    replyToMessageId,
    isDelivered,
    isRead,
    deliveredAtEpochMs,
    readAtEpochMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'aegis_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<AegisMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('room_id')) {
      context.handle(
        _roomIdMeta,
        roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('sent_at_epoch_ms')) {
      context.handle(
        _sentAtEpochMsMeta,
        sentAtEpochMs.isAcceptableOrUnknown(
          data['sent_at_epoch_ms']!,
          _sentAtEpochMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sentAtEpochMsMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('media_id')) {
      context.handle(
        _mediaIdMeta,
        mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta),
      );
    }
    if (data.containsKey('reply_to_message_id')) {
      context.handle(
        _replyToMessageIdMeta,
        replyToMessageId.isAcceptableOrUnknown(
          data['reply_to_message_id']!,
          _replyToMessageIdMeta,
        ),
      );
    }
    if (data.containsKey('is_delivered')) {
      context.handle(
        _isDeliveredMeta,
        isDelivered.isAcceptableOrUnknown(
          data['is_delivered']!,
          _isDeliveredMeta,
        ),
      );
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    if (data.containsKey('delivered_at_epoch_ms')) {
      context.handle(
        _deliveredAtEpochMsMeta,
        deliveredAtEpochMs.isAcceptableOrUnknown(
          data['delivered_at_epoch_ms']!,
          _deliveredAtEpochMsMeta,
        ),
      );
    }
    if (data.containsKey('read_at_epoch_ms')) {
      context.handle(
        _readAtEpochMsMeta,
        readAtEpochMs.isAcceptableOrUnknown(
          data['read_at_epoch_ms']!,
          _readAtEpochMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AegisMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AegisMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      roomId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_id'],
      )!,
      senderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      sentAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sent_at_epoch_ms'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_id'],
      ),
      replyToMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reply_to_message_id'],
      ),
      isDelivered: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_delivered'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      deliveredAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delivered_at_epoch_ms'],
      ),
      readAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}read_at_epoch_ms'],
      ),
    );
  }

  @override
  $AegisMessagesTable createAlias(String alias) {
    return $AegisMessagesTable(attachedDatabase, alias);
  }
}

class AegisMessage extends DataClass implements Insertable<AegisMessage> {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final int sentAtEpochMs;
  final String type;
  final String? mediaId;
  final int? replyToMessageId;
  final bool isDelivered;
  final bool isRead;
  final int? deliveredAtEpochMs;
  final int? readAtEpochMs;
  const AegisMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.sentAtEpochMs,
    required this.type,
    this.mediaId,
    this.replyToMessageId,
    required this.isDelivered,
    required this.isRead,
    this.deliveredAtEpochMs,
    this.readAtEpochMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['room_id'] = Variable<String>(roomId);
    map['sender_id'] = Variable<String>(senderId);
    map['content'] = Variable<String>(content);
    map['sent_at_epoch_ms'] = Variable<int>(sentAtEpochMs);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || mediaId != null) {
      map['media_id'] = Variable<String>(mediaId);
    }
    if (!nullToAbsent || replyToMessageId != null) {
      map['reply_to_message_id'] = Variable<int>(replyToMessageId);
    }
    map['is_delivered'] = Variable<bool>(isDelivered);
    map['is_read'] = Variable<bool>(isRead);
    if (!nullToAbsent || deliveredAtEpochMs != null) {
      map['delivered_at_epoch_ms'] = Variable<int>(deliveredAtEpochMs);
    }
    if (!nullToAbsent || readAtEpochMs != null) {
      map['read_at_epoch_ms'] = Variable<int>(readAtEpochMs);
    }
    return map;
  }

  AegisMessagesCompanion toCompanion(bool nullToAbsent) {
    return AegisMessagesCompanion(
      id: Value(id),
      roomId: Value(roomId),
      senderId: Value(senderId),
      content: Value(content),
      sentAtEpochMs: Value(sentAtEpochMs),
      type: Value(type),
      mediaId: mediaId == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaId),
      replyToMessageId: replyToMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(replyToMessageId),
      isDelivered: Value(isDelivered),
      isRead: Value(isRead),
      deliveredAtEpochMs: deliveredAtEpochMs == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveredAtEpochMs),
      readAtEpochMs: readAtEpochMs == null && nullToAbsent
          ? const Value.absent()
          : Value(readAtEpochMs),
    );
  }

  factory AegisMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AegisMessage(
      id: serializer.fromJson<String>(json['id']),
      roomId: serializer.fromJson<String>(json['roomId']),
      senderId: serializer.fromJson<String>(json['senderId']),
      content: serializer.fromJson<String>(json['content']),
      sentAtEpochMs: serializer.fromJson<int>(json['sentAtEpochMs']),
      type: serializer.fromJson<String>(json['type']),
      mediaId: serializer.fromJson<String?>(json['mediaId']),
      replyToMessageId: serializer.fromJson<int?>(json['replyToMessageId']),
      isDelivered: serializer.fromJson<bool>(json['isDelivered']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      deliveredAtEpochMs: serializer.fromJson<int?>(json['deliveredAtEpochMs']),
      readAtEpochMs: serializer.fromJson<int?>(json['readAtEpochMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'roomId': serializer.toJson<String>(roomId),
      'senderId': serializer.toJson<String>(senderId),
      'content': serializer.toJson<String>(content),
      'sentAtEpochMs': serializer.toJson<int>(sentAtEpochMs),
      'type': serializer.toJson<String>(type),
      'mediaId': serializer.toJson<String?>(mediaId),
      'replyToMessageId': serializer.toJson<int?>(replyToMessageId),
      'isDelivered': serializer.toJson<bool>(isDelivered),
      'isRead': serializer.toJson<bool>(isRead),
      'deliveredAtEpochMs': serializer.toJson<int?>(deliveredAtEpochMs),
      'readAtEpochMs': serializer.toJson<int?>(readAtEpochMs),
    };
  }

  AegisMessage copyWith({
    String? id,
    String? roomId,
    String? senderId,
    String? content,
    int? sentAtEpochMs,
    String? type,
    Value<String?> mediaId = const Value.absent(),
    Value<int?> replyToMessageId = const Value.absent(),
    bool? isDelivered,
    bool? isRead,
    Value<int?> deliveredAtEpochMs = const Value.absent(),
    Value<int?> readAtEpochMs = const Value.absent(),
  }) => AegisMessage(
    id: id ?? this.id,
    roomId: roomId ?? this.roomId,
    senderId: senderId ?? this.senderId,
    content: content ?? this.content,
    sentAtEpochMs: sentAtEpochMs ?? this.sentAtEpochMs,
    type: type ?? this.type,
    mediaId: mediaId.present ? mediaId.value : this.mediaId,
    replyToMessageId: replyToMessageId.present
        ? replyToMessageId.value
        : this.replyToMessageId,
    isDelivered: isDelivered ?? this.isDelivered,
    isRead: isRead ?? this.isRead,
    deliveredAtEpochMs: deliveredAtEpochMs.present
        ? deliveredAtEpochMs.value
        : this.deliveredAtEpochMs,
    readAtEpochMs: readAtEpochMs.present
        ? readAtEpochMs.value
        : this.readAtEpochMs,
  );
  AegisMessage copyWithCompanion(AegisMessagesCompanion data) {
    return AegisMessage(
      id: data.id.present ? data.id.value : this.id,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      content: data.content.present ? data.content.value : this.content,
      sentAtEpochMs: data.sentAtEpochMs.present
          ? data.sentAtEpochMs.value
          : this.sentAtEpochMs,
      type: data.type.present ? data.type.value : this.type,
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      replyToMessageId: data.replyToMessageId.present
          ? data.replyToMessageId.value
          : this.replyToMessageId,
      isDelivered: data.isDelivered.present
          ? data.isDelivered.value
          : this.isDelivered,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      deliveredAtEpochMs: data.deliveredAtEpochMs.present
          ? data.deliveredAtEpochMs.value
          : this.deliveredAtEpochMs,
      readAtEpochMs: data.readAtEpochMs.present
          ? data.readAtEpochMs.value
          : this.readAtEpochMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AegisMessage(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('senderId: $senderId, ')
          ..write('content: $content, ')
          ..write('sentAtEpochMs: $sentAtEpochMs, ')
          ..write('type: $type, ')
          ..write('mediaId: $mediaId, ')
          ..write('replyToMessageId: $replyToMessageId, ')
          ..write('isDelivered: $isDelivered, ')
          ..write('isRead: $isRead, ')
          ..write('deliveredAtEpochMs: $deliveredAtEpochMs, ')
          ..write('readAtEpochMs: $readAtEpochMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    roomId,
    senderId,
    content,
    sentAtEpochMs,
    type,
    mediaId,
    replyToMessageId,
    isDelivered,
    isRead,
    deliveredAtEpochMs,
    readAtEpochMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AegisMessage &&
          other.id == this.id &&
          other.roomId == this.roomId &&
          other.senderId == this.senderId &&
          other.content == this.content &&
          other.sentAtEpochMs == this.sentAtEpochMs &&
          other.type == this.type &&
          other.mediaId == this.mediaId &&
          other.replyToMessageId == this.replyToMessageId &&
          other.isDelivered == this.isDelivered &&
          other.isRead == this.isRead &&
          other.deliveredAtEpochMs == this.deliveredAtEpochMs &&
          other.readAtEpochMs == this.readAtEpochMs);
}

class AegisMessagesCompanion extends UpdateCompanion<AegisMessage> {
  final Value<String> id;
  final Value<String> roomId;
  final Value<String> senderId;
  final Value<String> content;
  final Value<int> sentAtEpochMs;
  final Value<String> type;
  final Value<String?> mediaId;
  final Value<int?> replyToMessageId;
  final Value<bool> isDelivered;
  final Value<bool> isRead;
  final Value<int?> deliveredAtEpochMs;
  final Value<int?> readAtEpochMs;
  final Value<int> rowid;
  const AegisMessagesCompanion({
    this.id = const Value.absent(),
    this.roomId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.content = const Value.absent(),
    this.sentAtEpochMs = const Value.absent(),
    this.type = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.replyToMessageId = const Value.absent(),
    this.isDelivered = const Value.absent(),
    this.isRead = const Value.absent(),
    this.deliveredAtEpochMs = const Value.absent(),
    this.readAtEpochMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AegisMessagesCompanion.insert({
    required String id,
    required String roomId,
    required String senderId,
    required String content,
    required int sentAtEpochMs,
    this.type = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.replyToMessageId = const Value.absent(),
    this.isDelivered = const Value.absent(),
    this.isRead = const Value.absent(),
    this.deliveredAtEpochMs = const Value.absent(),
    this.readAtEpochMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       roomId = Value(roomId),
       senderId = Value(senderId),
       content = Value(content),
       sentAtEpochMs = Value(sentAtEpochMs);
  static Insertable<AegisMessage> custom({
    Expression<String>? id,
    Expression<String>? roomId,
    Expression<String>? senderId,
    Expression<String>? content,
    Expression<int>? sentAtEpochMs,
    Expression<String>? type,
    Expression<String>? mediaId,
    Expression<int>? replyToMessageId,
    Expression<bool>? isDelivered,
    Expression<bool>? isRead,
    Expression<int>? deliveredAtEpochMs,
    Expression<int>? readAtEpochMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roomId != null) 'room_id': roomId,
      if (senderId != null) 'sender_id': senderId,
      if (content != null) 'content': content,
      if (sentAtEpochMs != null) 'sent_at_epoch_ms': sentAtEpochMs,
      if (type != null) 'type': type,
      if (mediaId != null) 'media_id': mediaId,
      if (replyToMessageId != null) 'reply_to_message_id': replyToMessageId,
      if (isDelivered != null) 'is_delivered': isDelivered,
      if (isRead != null) 'is_read': isRead,
      if (deliveredAtEpochMs != null)
        'delivered_at_epoch_ms': deliveredAtEpochMs,
      if (readAtEpochMs != null) 'read_at_epoch_ms': readAtEpochMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AegisMessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? roomId,
    Value<String>? senderId,
    Value<String>? content,
    Value<int>? sentAtEpochMs,
    Value<String>? type,
    Value<String?>? mediaId,
    Value<int?>? replyToMessageId,
    Value<bool>? isDelivered,
    Value<bool>? isRead,
    Value<int?>? deliveredAtEpochMs,
    Value<int?>? readAtEpochMs,
    Value<int>? rowid,
  }) {
    return AegisMessagesCompanion(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      sentAtEpochMs: sentAtEpochMs ?? this.sentAtEpochMs,
      type: type ?? this.type,
      mediaId: mediaId ?? this.mediaId,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      isDelivered: isDelivered ?? this.isDelivered,
      isRead: isRead ?? this.isRead,
      deliveredAtEpochMs: deliveredAtEpochMs ?? this.deliveredAtEpochMs,
      readAtEpochMs: readAtEpochMs ?? this.readAtEpochMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (sentAtEpochMs.present) {
      map['sent_at_epoch_ms'] = Variable<int>(sentAtEpochMs.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (mediaId.present) {
      map['media_id'] = Variable<String>(mediaId.value);
    }
    if (replyToMessageId.present) {
      map['reply_to_message_id'] = Variable<int>(replyToMessageId.value);
    }
    if (isDelivered.present) {
      map['is_delivered'] = Variable<bool>(isDelivered.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (deliveredAtEpochMs.present) {
      map['delivered_at_epoch_ms'] = Variable<int>(deliveredAtEpochMs.value);
    }
    if (readAtEpochMs.present) {
      map['read_at_epoch_ms'] = Variable<int>(readAtEpochMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AegisMessagesCompanion(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('senderId: $senderId, ')
          ..write('content: $content, ')
          ..write('sentAtEpochMs: $sentAtEpochMs, ')
          ..write('type: $type, ')
          ..write('mediaId: $mediaId, ')
          ..write('replyToMessageId: $replyToMessageId, ')
          ..write('isDelivered: $isDelivered, ')
          ..write('isRead: $isRead, ')
          ..write('deliveredAtEpochMs: $deliveredAtEpochMs, ')
          ..write('readAtEpochMs: $readAtEpochMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AegisProfilesTable extends AegisProfiles
    with TableInfo<$AegisProfilesTable, AegisProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AegisProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _presenceStatusMeta = const VerificationMeta(
    'presenceStatus',
  );
  @override
  late final GeneratedColumn<String> presenceStatus = GeneratedColumn<String>(
    'presence_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isOnlineMeta = const VerificationMeta(
    'isOnline',
  );
  @override
  late final GeneratedColumn<bool> isOnline = GeneratedColumn<bool>(
    'is_online',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_online" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastSeenAtEpochMsMeta = const VerificationMeta(
    'lastSeenAtEpochMs',
  );
  @override
  late final GeneratedColumn<int> lastSeenAtEpochMs = GeneratedColumn<int>(
    'last_seen_at_epoch_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    payloadJson,
    username,
    displayName,
    avatarUrl,
    presenceStatus,
    isOnline,
    lastSeenAtEpochMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'aegis_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<AegisProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('presence_status')) {
      context.handle(
        _presenceStatusMeta,
        presenceStatus.isAcceptableOrUnknown(
          data['presence_status']!,
          _presenceStatusMeta,
        ),
      );
    }
    if (data.containsKey('is_online')) {
      context.handle(
        _isOnlineMeta,
        isOnline.isAcceptableOrUnknown(data['is_online']!, _isOnlineMeta),
      );
    }
    if (data.containsKey('last_seen_at_epoch_ms')) {
      context.handle(
        _lastSeenAtEpochMsMeta,
        lastSeenAtEpochMs.isAcceptableOrUnknown(
          data['last_seen_at_epoch_ms']!,
          _lastSeenAtEpochMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  AegisProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AegisProfile(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      ),
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      presenceStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}presence_status'],
      ),
      isOnline: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_online'],
      )!,
      lastSeenAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_seen_at_epoch_ms'],
      ),
    );
  }

  @override
  $AegisProfilesTable createAlias(String alias) {
    return $AegisProfilesTable(attachedDatabase, alias);
  }
}

class AegisProfile extends DataClass implements Insertable<AegisProfile> {
  final int userId;
  final String payloadJson;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final String? presenceStatus;
  final bool isOnline;
  final int? lastSeenAtEpochMs;
  const AegisProfile({
    required this.userId,
    required this.payloadJson,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.presenceStatus,
    required this.isOnline,
    this.lastSeenAtEpochMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<int>(userId);
    map['payload_json'] = Variable<String>(payloadJson);
    if (!nullToAbsent || username != null) {
      map['username'] = Variable<String>(username);
    }
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    if (!nullToAbsent || presenceStatus != null) {
      map['presence_status'] = Variable<String>(presenceStatus);
    }
    map['is_online'] = Variable<bool>(isOnline);
    if (!nullToAbsent || lastSeenAtEpochMs != null) {
      map['last_seen_at_epoch_ms'] = Variable<int>(lastSeenAtEpochMs);
    }
    return map;
  }

  AegisProfilesCompanion toCompanion(bool nullToAbsent) {
    return AegisProfilesCompanion(
      userId: Value(userId),
      payloadJson: Value(payloadJson),
      username: username == null && nullToAbsent
          ? const Value.absent()
          : Value(username),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      presenceStatus: presenceStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(presenceStatus),
      isOnline: Value(isOnline),
      lastSeenAtEpochMs: lastSeenAtEpochMs == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenAtEpochMs),
    );
  }

  factory AegisProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AegisProfile(
      userId: serializer.fromJson<int>(json['userId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      username: serializer.fromJson<String?>(json['username']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      presenceStatus: serializer.fromJson<String?>(json['presenceStatus']),
      isOnline: serializer.fromJson<bool>(json['isOnline']),
      lastSeenAtEpochMs: serializer.fromJson<int?>(json['lastSeenAtEpochMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<int>(userId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'username': serializer.toJson<String?>(username),
      'displayName': serializer.toJson<String?>(displayName),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'presenceStatus': serializer.toJson<String?>(presenceStatus),
      'isOnline': serializer.toJson<bool>(isOnline),
      'lastSeenAtEpochMs': serializer.toJson<int?>(lastSeenAtEpochMs),
    };
  }

  AegisProfile copyWith({
    int? userId,
    String? payloadJson,
    Value<String?> username = const Value.absent(),
    Value<String?> displayName = const Value.absent(),
    Value<String?> avatarUrl = const Value.absent(),
    Value<String?> presenceStatus = const Value.absent(),
    bool? isOnline,
    Value<int?> lastSeenAtEpochMs = const Value.absent(),
  }) => AegisProfile(
    userId: userId ?? this.userId,
    payloadJson: payloadJson ?? this.payloadJson,
    username: username.present ? username.value : this.username,
    displayName: displayName.present ? displayName.value : this.displayName,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    presenceStatus: presenceStatus.present
        ? presenceStatus.value
        : this.presenceStatus,
    isOnline: isOnline ?? this.isOnline,
    lastSeenAtEpochMs: lastSeenAtEpochMs.present
        ? lastSeenAtEpochMs.value
        : this.lastSeenAtEpochMs,
  );
  AegisProfile copyWithCompanion(AegisProfilesCompanion data) {
    return AegisProfile(
      userId: data.userId.present ? data.userId.value : this.userId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      username: data.username.present ? data.username.value : this.username,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      presenceStatus: data.presenceStatus.present
          ? data.presenceStatus.value
          : this.presenceStatus,
      isOnline: data.isOnline.present ? data.isOnline.value : this.isOnline,
      lastSeenAtEpochMs: data.lastSeenAtEpochMs.present
          ? data.lastSeenAtEpochMs.value
          : this.lastSeenAtEpochMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AegisProfile(')
          ..write('userId: $userId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('presenceStatus: $presenceStatus, ')
          ..write('isOnline: $isOnline, ')
          ..write('lastSeenAtEpochMs: $lastSeenAtEpochMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    payloadJson,
    username,
    displayName,
    avatarUrl,
    presenceStatus,
    isOnline,
    lastSeenAtEpochMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AegisProfile &&
          other.userId == this.userId &&
          other.payloadJson == this.payloadJson &&
          other.username == this.username &&
          other.displayName == this.displayName &&
          other.avatarUrl == this.avatarUrl &&
          other.presenceStatus == this.presenceStatus &&
          other.isOnline == this.isOnline &&
          other.lastSeenAtEpochMs == this.lastSeenAtEpochMs);
}

class AegisProfilesCompanion extends UpdateCompanion<AegisProfile> {
  final Value<int> userId;
  final Value<String> payloadJson;
  final Value<String?> username;
  final Value<String?> displayName;
  final Value<String?> avatarUrl;
  final Value<String?> presenceStatus;
  final Value<bool> isOnline;
  final Value<int?> lastSeenAtEpochMs;
  const AegisProfilesCompanion({
    this.userId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.username = const Value.absent(),
    this.displayName = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.presenceStatus = const Value.absent(),
    this.isOnline = const Value.absent(),
    this.lastSeenAtEpochMs = const Value.absent(),
  });
  AegisProfilesCompanion.insert({
    this.userId = const Value.absent(),
    required String payloadJson,
    this.username = const Value.absent(),
    this.displayName = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.presenceStatus = const Value.absent(),
    this.isOnline = const Value.absent(),
    this.lastSeenAtEpochMs = const Value.absent(),
  }) : payloadJson = Value(payloadJson);
  static Insertable<AegisProfile> custom({
    Expression<int>? userId,
    Expression<String>? payloadJson,
    Expression<String>? username,
    Expression<String>? displayName,
    Expression<String>? avatarUrl,
    Expression<String>? presenceStatus,
    Expression<bool>? isOnline,
    Expression<int>? lastSeenAtEpochMs,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (username != null) 'username': username,
      if (displayName != null) 'display_name': displayName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (presenceStatus != null) 'presence_status': presenceStatus,
      if (isOnline != null) 'is_online': isOnline,
      if (lastSeenAtEpochMs != null) 'last_seen_at_epoch_ms': lastSeenAtEpochMs,
    });
  }

  AegisProfilesCompanion copyWith({
    Value<int>? userId,
    Value<String>? payloadJson,
    Value<String?>? username,
    Value<String?>? displayName,
    Value<String?>? avatarUrl,
    Value<String?>? presenceStatus,
    Value<bool>? isOnline,
    Value<int?>? lastSeenAtEpochMs,
  }) {
    return AegisProfilesCompanion(
      userId: userId ?? this.userId,
      payloadJson: payloadJson ?? this.payloadJson,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      presenceStatus: presenceStatus ?? this.presenceStatus,
      isOnline: isOnline ?? this.isOnline,
      lastSeenAtEpochMs: lastSeenAtEpochMs ?? this.lastSeenAtEpochMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (presenceStatus.present) {
      map['presence_status'] = Variable<String>(presenceStatus.value);
    }
    if (isOnline.present) {
      map['is_online'] = Variable<bool>(isOnline.value);
    }
    if (lastSeenAtEpochMs.present) {
      map['last_seen_at_epoch_ms'] = Variable<int>(lastSeenAtEpochMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AegisProfilesCompanion(')
          ..write('userId: $userId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('presenceStatus: $presenceStatus, ')
          ..write('isOnline: $isOnline, ')
          ..write('lastSeenAtEpochMs: $lastSeenAtEpochMs')
          ..write(')'))
        .toString();
  }
}

class $AegisMetadataTable extends AegisMetadata
    with TableInfo<$AegisMetadataTable, AegisMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AegisMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'aegis_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<AegisMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AegisMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AegisMetadataData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AegisMetadataTable createAlias(String alias) {
    return $AegisMetadataTable(attachedDatabase, alias);
  }
}

class AegisMetadataData extends DataClass
    implements Insertable<AegisMetadataData> {
  final String key;
  final String value;
  const AegisMetadataData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AegisMetadataCompanion toCompanion(bool nullToAbsent) {
    return AegisMetadataCompanion(key: Value(key), value: Value(value));
  }

  factory AegisMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AegisMetadataData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AegisMetadataData copyWith({String? key, String? value}) =>
      AegisMetadataData(key: key ?? this.key, value: value ?? this.value);
  AegisMetadataData copyWithCompanion(AegisMetadataCompanion data) {
    return AegisMetadataData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AegisMetadataData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AegisMetadataData &&
          other.key == this.key &&
          other.value == this.value);
}

class AegisMetadataCompanion extends UpdateCompanion<AegisMetadataData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AegisMetadataCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AegisMetadataCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AegisMetadataData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AegisMetadataCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AegisMetadataCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AegisMetadataCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AegisOfflineQueueTable extends AegisOfflineQueue
    with TableInfo<$AegisOfflineQueueTable, AegisOfflineQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AegisOfflineQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<String> chatId = GeneratedColumn<String>(
    'chat_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtEpochMsMeta = const VerificationMeta(
    'createdAtEpochMs',
  );
  @override
  late final GeneratedColumn<int> createdAtEpochMs = GeneratedColumn<int>(
    'created_at_epoch_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sentMeta = const VerificationMeta('sent');
  @override
  late final GeneratedColumn<bool> sent = GeneratedColumn<bool>(
    'sent',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sent" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    chatId,
    content,
    type,
    createdAtEpochMs,
    sent,
    errorMessage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'aegis_offline_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<AegisOfflineQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('chat_id')) {
      context.handle(
        _chatIdMeta,
        chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chatIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('created_at_epoch_ms')) {
      context.handle(
        _createdAtEpochMsMeta,
        createdAtEpochMs.isAcceptableOrUnknown(
          data['created_at_epoch_ms']!,
          _createdAtEpochMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtEpochMsMeta);
    }
    if (data.containsKey('sent')) {
      context.handle(
        _sentMeta,
        sent.isAcceptableOrUnknown(data['sent']!, _sentMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AegisOfflineQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AegisOfflineQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      chatId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chat_id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      createdAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_epoch_ms'],
      )!,
      sent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sent'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
    );
  }

  @override
  $AegisOfflineQueueTable createAlias(String alias) {
    return $AegisOfflineQueueTable(attachedDatabase, alias);
  }
}

class AegisOfflineQueueData extends DataClass
    implements Insertable<AegisOfflineQueueData> {
  final int id;
  final String chatId;
  final String content;
  final String type;
  final int createdAtEpochMs;
  final bool sent;
  final String? errorMessage;
  const AegisOfflineQueueData({
    required this.id,
    required this.chatId,
    required this.content,
    required this.type,
    required this.createdAtEpochMs,
    required this.sent,
    this.errorMessage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['chat_id'] = Variable<String>(chatId);
    map['content'] = Variable<String>(content);
    map['type'] = Variable<String>(type);
    map['created_at_epoch_ms'] = Variable<int>(createdAtEpochMs);
    map['sent'] = Variable<bool>(sent);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    return map;
  }

  AegisOfflineQueueCompanion toCompanion(bool nullToAbsent) {
    return AegisOfflineQueueCompanion(
      id: Value(id),
      chatId: Value(chatId),
      content: Value(content),
      type: Value(type),
      createdAtEpochMs: Value(createdAtEpochMs),
      sent: Value(sent),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
    );
  }

  factory AegisOfflineQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AegisOfflineQueueData(
      id: serializer.fromJson<int>(json['id']),
      chatId: serializer.fromJson<String>(json['chatId']),
      content: serializer.fromJson<String>(json['content']),
      type: serializer.fromJson<String>(json['type']),
      createdAtEpochMs: serializer.fromJson<int>(json['createdAtEpochMs']),
      sent: serializer.fromJson<bool>(json['sent']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'chatId': serializer.toJson<String>(chatId),
      'content': serializer.toJson<String>(content),
      'type': serializer.toJson<String>(type),
      'createdAtEpochMs': serializer.toJson<int>(createdAtEpochMs),
      'sent': serializer.toJson<bool>(sent),
      'errorMessage': serializer.toJson<String?>(errorMessage),
    };
  }

  AegisOfflineQueueData copyWith({
    int? id,
    String? chatId,
    String? content,
    String? type,
    int? createdAtEpochMs,
    bool? sent,
    Value<String?> errorMessage = const Value.absent(),
  }) => AegisOfflineQueueData(
    id: id ?? this.id,
    chatId: chatId ?? this.chatId,
    content: content ?? this.content,
    type: type ?? this.type,
    createdAtEpochMs: createdAtEpochMs ?? this.createdAtEpochMs,
    sent: sent ?? this.sent,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
  );
  AegisOfflineQueueData copyWithCompanion(AegisOfflineQueueCompanion data) {
    return AegisOfflineQueueData(
      id: data.id.present ? data.id.value : this.id,
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      content: data.content.present ? data.content.value : this.content,
      type: data.type.present ? data.type.value : this.type,
      createdAtEpochMs: data.createdAtEpochMs.present
          ? data.createdAtEpochMs.value
          : this.createdAtEpochMs,
      sent: data.sent.present ? data.sent.value : this.sent,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AegisOfflineQueueData(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('content: $content, ')
          ..write('type: $type, ')
          ..write('createdAtEpochMs: $createdAtEpochMs, ')
          ..write('sent: $sent, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    chatId,
    content,
    type,
    createdAtEpochMs,
    sent,
    errorMessage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AegisOfflineQueueData &&
          other.id == this.id &&
          other.chatId == this.chatId &&
          other.content == this.content &&
          other.type == this.type &&
          other.createdAtEpochMs == this.createdAtEpochMs &&
          other.sent == this.sent &&
          other.errorMessage == this.errorMessage);
}

class AegisOfflineQueueCompanion
    extends UpdateCompanion<AegisOfflineQueueData> {
  final Value<int> id;
  final Value<String> chatId;
  final Value<String> content;
  final Value<String> type;
  final Value<int> createdAtEpochMs;
  final Value<bool> sent;
  final Value<String?> errorMessage;
  const AegisOfflineQueueCompanion({
    this.id = const Value.absent(),
    this.chatId = const Value.absent(),
    this.content = const Value.absent(),
    this.type = const Value.absent(),
    this.createdAtEpochMs = const Value.absent(),
    this.sent = const Value.absent(),
    this.errorMessage = const Value.absent(),
  });
  AegisOfflineQueueCompanion.insert({
    this.id = const Value.absent(),
    required String chatId,
    required String content,
    required String type,
    required int createdAtEpochMs,
    this.sent = const Value.absent(),
    this.errorMessage = const Value.absent(),
  }) : chatId = Value(chatId),
       content = Value(content),
       type = Value(type),
       createdAtEpochMs = Value(createdAtEpochMs);
  static Insertable<AegisOfflineQueueData> custom({
    Expression<int>? id,
    Expression<String>? chatId,
    Expression<String>? content,
    Expression<String>? type,
    Expression<int>? createdAtEpochMs,
    Expression<bool>? sent,
    Expression<String>? errorMessage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chatId != null) 'chat_id': chatId,
      if (content != null) 'content': content,
      if (type != null) 'type': type,
      if (createdAtEpochMs != null) 'created_at_epoch_ms': createdAtEpochMs,
      if (sent != null) 'sent': sent,
      if (errorMessage != null) 'error_message': errorMessage,
    });
  }

  AegisOfflineQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? chatId,
    Value<String>? content,
    Value<String>? type,
    Value<int>? createdAtEpochMs,
    Value<bool>? sent,
    Value<String?>? errorMessage,
  }) {
    return AegisOfflineQueueCompanion(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAtEpochMs: createdAtEpochMs ?? this.createdAtEpochMs,
      sent: sent ?? this.sent,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (chatId.present) {
      map['chat_id'] = Variable<String>(chatId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (createdAtEpochMs.present) {
      map['created_at_epoch_ms'] = Variable<int>(createdAtEpochMs.value);
    }
    if (sent.present) {
      map['sent'] = Variable<bool>(sent.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AegisOfflineQueueCompanion(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('content: $content, ')
          ..write('type: $type, ')
          ..write('createdAtEpochMs: $createdAtEpochMs, ')
          ..write('sent: $sent, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }
}

class $AegisPeopleFavoritesTable extends AegisPeopleFavorites
    with TableInfo<$AegisPeopleFavoritesTable, AegisPeopleFavorite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AegisPeopleFavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [personId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'aegis_people_favorites';
  @override
  VerificationContext validateIntegrity(
    Insertable<AegisPeopleFavorite> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {personId};
  @override
  AegisPeopleFavorite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AegisPeopleFavorite(
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      )!,
    );
  }

  @override
  $AegisPeopleFavoritesTable createAlias(String alias) {
    return $AegisPeopleFavoritesTable(attachedDatabase, alias);
  }
}

class AegisPeopleFavorite extends DataClass
    implements Insertable<AegisPeopleFavorite> {
  final String personId;
  const AegisPeopleFavorite({required this.personId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['person_id'] = Variable<String>(personId);
    return map;
  }

  AegisPeopleFavoritesCompanion toCompanion(bool nullToAbsent) {
    return AegisPeopleFavoritesCompanion(personId: Value(personId));
  }

  factory AegisPeopleFavorite.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AegisPeopleFavorite(
      personId: serializer.fromJson<String>(json['personId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'personId': serializer.toJson<String>(personId)};
  }

  AegisPeopleFavorite copyWith({String? personId}) =>
      AegisPeopleFavorite(personId: personId ?? this.personId);
  AegisPeopleFavorite copyWithCompanion(AegisPeopleFavoritesCompanion data) {
    return AegisPeopleFavorite(
      personId: data.personId.present ? data.personId.value : this.personId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AegisPeopleFavorite(')
          ..write('personId: $personId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => personId.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AegisPeopleFavorite && other.personId == this.personId);
}

class AegisPeopleFavoritesCompanion
    extends UpdateCompanion<AegisPeopleFavorite> {
  final Value<String> personId;
  final Value<int> rowid;
  const AegisPeopleFavoritesCompanion({
    this.personId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AegisPeopleFavoritesCompanion.insert({
    required String personId,
    this.rowid = const Value.absent(),
  }) : personId = Value(personId);
  static Insertable<AegisPeopleFavorite> custom({
    Expression<String>? personId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (personId != null) 'person_id': personId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AegisPeopleFavoritesCompanion copyWith({
    Value<String>? personId,
    Value<int>? rowid,
  }) {
    return AegisPeopleFavoritesCompanion(
      personId: personId ?? this.personId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AegisPeopleFavoritesCompanion(')
          ..write('personId: $personId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AegisPeopleEntriesTable extends AegisPeopleEntries
    with TableInfo<$AegisPeopleEntriesTable, AegisPeopleEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AegisPeopleEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bucketMeta = const VerificationMeta('bucket');
  @override
  late final GeneratedColumn<String> bucket = GeneratedColumn<String>(
    'bucket',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remoteUserIdMeta = const VerificationMeta(
    'remoteUserId',
  );
  @override
  late final GeneratedColumn<String> remoteUserId = GeneratedColumn<String>(
    'remote_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isTwoSpaceUserMeta = const VerificationMeta(
    'isTwoSpaceUser',
  );
  @override
  late final GeneratedColumn<bool> isTwoSpaceUser = GeneratedColumn<bool>(
    'is_two_space_user',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_two_space_user" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeviceContactMeta = const VerificationMeta(
    'isDeviceContact',
  );
  @override
  late final GeneratedColumn<bool> isDeviceContact = GeneratedColumn<bool>(
    'is_device_contact',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_device_contact" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isOnlineMeta = const VerificationMeta(
    'isOnline',
  );
  @override
  late final GeneratedColumn<bool> isOnline = GeneratedColumn<bool>(
    'is_online',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_online" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _presenceStatusMeta = const VerificationMeta(
    'presenceStatus',
  );
  @override
  late final GeneratedColumn<String> presenceStatus = GeneratedColumn<String>(
    'presence_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSeenAtEpochMsMeta = const VerificationMeta(
    'lastSeenAtEpochMs',
  );
  @override
  late final GeneratedColumn<int> lastSeenAtEpochMs = GeneratedColumn<int>(
    'last_seen_at_epoch_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastInteractionAtEpochMsMeta =
      const VerificationMeta('lastInteractionAtEpochMs');
  @override
  late final GeneratedColumn<int> lastInteractionAtEpochMs =
      GeneratedColumn<int>(
        'last_interaction_at_epoch_ms',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sortEpochMsMeta = const VerificationMeta(
    'sortEpochMs',
  );
  @override
  late final GeneratedColumn<int> sortEpochMs = GeneratedColumn<int>(
    'sort_epoch_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    bucket,
    personId,
    payloadJson,
    displayName,
    username,
    remoteUserId,
    isTwoSpaceUser,
    isDeviceContact,
    isFavorite,
    isOnline,
    presenceStatus,
    lastSeenAtEpochMs,
    lastInteractionAtEpochMs,
    sortEpochMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'aegis_people_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<AegisPeopleEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('bucket')) {
      context.handle(
        _bucketMeta,
        bucket.isAcceptableOrUnknown(data['bucket']!, _bucketMeta),
      );
    } else if (isInserting) {
      context.missing(_bucketMeta);
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    }
    if (data.containsKey('remote_user_id')) {
      context.handle(
        _remoteUserIdMeta,
        remoteUserId.isAcceptableOrUnknown(
          data['remote_user_id']!,
          _remoteUserIdMeta,
        ),
      );
    }
    if (data.containsKey('is_two_space_user')) {
      context.handle(
        _isTwoSpaceUserMeta,
        isTwoSpaceUser.isAcceptableOrUnknown(
          data['is_two_space_user']!,
          _isTwoSpaceUserMeta,
        ),
      );
    }
    if (data.containsKey('is_device_contact')) {
      context.handle(
        _isDeviceContactMeta,
        isDeviceContact.isAcceptableOrUnknown(
          data['is_device_contact']!,
          _isDeviceContactMeta,
        ),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('is_online')) {
      context.handle(
        _isOnlineMeta,
        isOnline.isAcceptableOrUnknown(data['is_online']!, _isOnlineMeta),
      );
    }
    if (data.containsKey('presence_status')) {
      context.handle(
        _presenceStatusMeta,
        presenceStatus.isAcceptableOrUnknown(
          data['presence_status']!,
          _presenceStatusMeta,
        ),
      );
    }
    if (data.containsKey('last_seen_at_epoch_ms')) {
      context.handle(
        _lastSeenAtEpochMsMeta,
        lastSeenAtEpochMs.isAcceptableOrUnknown(
          data['last_seen_at_epoch_ms']!,
          _lastSeenAtEpochMsMeta,
        ),
      );
    }
    if (data.containsKey('last_interaction_at_epoch_ms')) {
      context.handle(
        _lastInteractionAtEpochMsMeta,
        lastInteractionAtEpochMs.isAcceptableOrUnknown(
          data['last_interaction_at_epoch_ms']!,
          _lastInteractionAtEpochMsMeta,
        ),
      );
    }
    if (data.containsKey('sort_epoch_ms')) {
      context.handle(
        _sortEpochMsMeta,
        sortEpochMs.isAcceptableOrUnknown(
          data['sort_epoch_ms']!,
          _sortEpochMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bucket, personId};
  @override
  AegisPeopleEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AegisPeopleEntry(
      bucket: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bucket'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      ),
      remoteUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_user_id'],
      ),
      isTwoSpaceUser: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_two_space_user'],
      )!,
      isDeviceContact: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_device_contact'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      isOnline: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_online'],
      )!,
      presenceStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}presence_status'],
      ),
      lastSeenAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_seen_at_epoch_ms'],
      ),
      lastInteractionAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_interaction_at_epoch_ms'],
      ),
      sortEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_epoch_ms'],
      )!,
    );
  }

  @override
  $AegisPeopleEntriesTable createAlias(String alias) {
    return $AegisPeopleEntriesTable(attachedDatabase, alias);
  }
}

class AegisPeopleEntry extends DataClass
    implements Insertable<AegisPeopleEntry> {
  final String bucket;
  final String personId;
  final String payloadJson;
  final String displayName;
  final String? username;
  final String? remoteUserId;
  final bool isTwoSpaceUser;
  final bool isDeviceContact;
  final bool isFavorite;
  final bool isOnline;
  final String? presenceStatus;
  final int? lastSeenAtEpochMs;
  final int? lastInteractionAtEpochMs;
  final int sortEpochMs;
  const AegisPeopleEntry({
    required this.bucket,
    required this.personId,
    required this.payloadJson,
    required this.displayName,
    this.username,
    this.remoteUserId,
    required this.isTwoSpaceUser,
    required this.isDeviceContact,
    required this.isFavorite,
    required this.isOnline,
    this.presenceStatus,
    this.lastSeenAtEpochMs,
    this.lastInteractionAtEpochMs,
    required this.sortEpochMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['bucket'] = Variable<String>(bucket);
    map['person_id'] = Variable<String>(personId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || username != null) {
      map['username'] = Variable<String>(username);
    }
    if (!nullToAbsent || remoteUserId != null) {
      map['remote_user_id'] = Variable<String>(remoteUserId);
    }
    map['is_two_space_user'] = Variable<bool>(isTwoSpaceUser);
    map['is_device_contact'] = Variable<bool>(isDeviceContact);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_online'] = Variable<bool>(isOnline);
    if (!nullToAbsent || presenceStatus != null) {
      map['presence_status'] = Variable<String>(presenceStatus);
    }
    if (!nullToAbsent || lastSeenAtEpochMs != null) {
      map['last_seen_at_epoch_ms'] = Variable<int>(lastSeenAtEpochMs);
    }
    if (!nullToAbsent || lastInteractionAtEpochMs != null) {
      map['last_interaction_at_epoch_ms'] = Variable<int>(
        lastInteractionAtEpochMs,
      );
    }
    map['sort_epoch_ms'] = Variable<int>(sortEpochMs);
    return map;
  }

  AegisPeopleEntriesCompanion toCompanion(bool nullToAbsent) {
    return AegisPeopleEntriesCompanion(
      bucket: Value(bucket),
      personId: Value(personId),
      payloadJson: Value(payloadJson),
      displayName: Value(displayName),
      username: username == null && nullToAbsent
          ? const Value.absent()
          : Value(username),
      remoteUserId: remoteUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteUserId),
      isTwoSpaceUser: Value(isTwoSpaceUser),
      isDeviceContact: Value(isDeviceContact),
      isFavorite: Value(isFavorite),
      isOnline: Value(isOnline),
      presenceStatus: presenceStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(presenceStatus),
      lastSeenAtEpochMs: lastSeenAtEpochMs == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenAtEpochMs),
      lastInteractionAtEpochMs: lastInteractionAtEpochMs == null && nullToAbsent
          ? const Value.absent()
          : Value(lastInteractionAtEpochMs),
      sortEpochMs: Value(sortEpochMs),
    );
  }

  factory AegisPeopleEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AegisPeopleEntry(
      bucket: serializer.fromJson<String>(json['bucket']),
      personId: serializer.fromJson<String>(json['personId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      displayName: serializer.fromJson<String>(json['displayName']),
      username: serializer.fromJson<String?>(json['username']),
      remoteUserId: serializer.fromJson<String?>(json['remoteUserId']),
      isTwoSpaceUser: serializer.fromJson<bool>(json['isTwoSpaceUser']),
      isDeviceContact: serializer.fromJson<bool>(json['isDeviceContact']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isOnline: serializer.fromJson<bool>(json['isOnline']),
      presenceStatus: serializer.fromJson<String?>(json['presenceStatus']),
      lastSeenAtEpochMs: serializer.fromJson<int?>(json['lastSeenAtEpochMs']),
      lastInteractionAtEpochMs: serializer.fromJson<int?>(
        json['lastInteractionAtEpochMs'],
      ),
      sortEpochMs: serializer.fromJson<int>(json['sortEpochMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bucket': serializer.toJson<String>(bucket),
      'personId': serializer.toJson<String>(personId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'displayName': serializer.toJson<String>(displayName),
      'username': serializer.toJson<String?>(username),
      'remoteUserId': serializer.toJson<String?>(remoteUserId),
      'isTwoSpaceUser': serializer.toJson<bool>(isTwoSpaceUser),
      'isDeviceContact': serializer.toJson<bool>(isDeviceContact),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isOnline': serializer.toJson<bool>(isOnline),
      'presenceStatus': serializer.toJson<String?>(presenceStatus),
      'lastSeenAtEpochMs': serializer.toJson<int?>(lastSeenAtEpochMs),
      'lastInteractionAtEpochMs': serializer.toJson<int?>(
        lastInteractionAtEpochMs,
      ),
      'sortEpochMs': serializer.toJson<int>(sortEpochMs),
    };
  }

  AegisPeopleEntry copyWith({
    String? bucket,
    String? personId,
    String? payloadJson,
    String? displayName,
    Value<String?> username = const Value.absent(),
    Value<String?> remoteUserId = const Value.absent(),
    bool? isTwoSpaceUser,
    bool? isDeviceContact,
    bool? isFavorite,
    bool? isOnline,
    Value<String?> presenceStatus = const Value.absent(),
    Value<int?> lastSeenAtEpochMs = const Value.absent(),
    Value<int?> lastInteractionAtEpochMs = const Value.absent(),
    int? sortEpochMs,
  }) => AegisPeopleEntry(
    bucket: bucket ?? this.bucket,
    personId: personId ?? this.personId,
    payloadJson: payloadJson ?? this.payloadJson,
    displayName: displayName ?? this.displayName,
    username: username.present ? username.value : this.username,
    remoteUserId: remoteUserId.present ? remoteUserId.value : this.remoteUserId,
    isTwoSpaceUser: isTwoSpaceUser ?? this.isTwoSpaceUser,
    isDeviceContact: isDeviceContact ?? this.isDeviceContact,
    isFavorite: isFavorite ?? this.isFavorite,
    isOnline: isOnline ?? this.isOnline,
    presenceStatus: presenceStatus.present
        ? presenceStatus.value
        : this.presenceStatus,
    lastSeenAtEpochMs: lastSeenAtEpochMs.present
        ? lastSeenAtEpochMs.value
        : this.lastSeenAtEpochMs,
    lastInteractionAtEpochMs: lastInteractionAtEpochMs.present
        ? lastInteractionAtEpochMs.value
        : this.lastInteractionAtEpochMs,
    sortEpochMs: sortEpochMs ?? this.sortEpochMs,
  );
  AegisPeopleEntry copyWithCompanion(AegisPeopleEntriesCompanion data) {
    return AegisPeopleEntry(
      bucket: data.bucket.present ? data.bucket.value : this.bucket,
      personId: data.personId.present ? data.personId.value : this.personId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      username: data.username.present ? data.username.value : this.username,
      remoteUserId: data.remoteUserId.present
          ? data.remoteUserId.value
          : this.remoteUserId,
      isTwoSpaceUser: data.isTwoSpaceUser.present
          ? data.isTwoSpaceUser.value
          : this.isTwoSpaceUser,
      isDeviceContact: data.isDeviceContact.present
          ? data.isDeviceContact.value
          : this.isDeviceContact,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      isOnline: data.isOnline.present ? data.isOnline.value : this.isOnline,
      presenceStatus: data.presenceStatus.present
          ? data.presenceStatus.value
          : this.presenceStatus,
      lastSeenAtEpochMs: data.lastSeenAtEpochMs.present
          ? data.lastSeenAtEpochMs.value
          : this.lastSeenAtEpochMs,
      lastInteractionAtEpochMs: data.lastInteractionAtEpochMs.present
          ? data.lastInteractionAtEpochMs.value
          : this.lastInteractionAtEpochMs,
      sortEpochMs: data.sortEpochMs.present
          ? data.sortEpochMs.value
          : this.sortEpochMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AegisPeopleEntry(')
          ..write('bucket: $bucket, ')
          ..write('personId: $personId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('displayName: $displayName, ')
          ..write('username: $username, ')
          ..write('remoteUserId: $remoteUserId, ')
          ..write('isTwoSpaceUser: $isTwoSpaceUser, ')
          ..write('isDeviceContact: $isDeviceContact, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isOnline: $isOnline, ')
          ..write('presenceStatus: $presenceStatus, ')
          ..write('lastSeenAtEpochMs: $lastSeenAtEpochMs, ')
          ..write('lastInteractionAtEpochMs: $lastInteractionAtEpochMs, ')
          ..write('sortEpochMs: $sortEpochMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    bucket,
    personId,
    payloadJson,
    displayName,
    username,
    remoteUserId,
    isTwoSpaceUser,
    isDeviceContact,
    isFavorite,
    isOnline,
    presenceStatus,
    lastSeenAtEpochMs,
    lastInteractionAtEpochMs,
    sortEpochMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AegisPeopleEntry &&
          other.bucket == this.bucket &&
          other.personId == this.personId &&
          other.payloadJson == this.payloadJson &&
          other.displayName == this.displayName &&
          other.username == this.username &&
          other.remoteUserId == this.remoteUserId &&
          other.isTwoSpaceUser == this.isTwoSpaceUser &&
          other.isDeviceContact == this.isDeviceContact &&
          other.isFavorite == this.isFavorite &&
          other.isOnline == this.isOnline &&
          other.presenceStatus == this.presenceStatus &&
          other.lastSeenAtEpochMs == this.lastSeenAtEpochMs &&
          other.lastInteractionAtEpochMs == this.lastInteractionAtEpochMs &&
          other.sortEpochMs == this.sortEpochMs);
}

class AegisPeopleEntriesCompanion extends UpdateCompanion<AegisPeopleEntry> {
  final Value<String> bucket;
  final Value<String> personId;
  final Value<String> payloadJson;
  final Value<String> displayName;
  final Value<String?> username;
  final Value<String?> remoteUserId;
  final Value<bool> isTwoSpaceUser;
  final Value<bool> isDeviceContact;
  final Value<bool> isFavorite;
  final Value<bool> isOnline;
  final Value<String?> presenceStatus;
  final Value<int?> lastSeenAtEpochMs;
  final Value<int?> lastInteractionAtEpochMs;
  final Value<int> sortEpochMs;
  final Value<int> rowid;
  const AegisPeopleEntriesCompanion({
    this.bucket = const Value.absent(),
    this.personId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.displayName = const Value.absent(),
    this.username = const Value.absent(),
    this.remoteUserId = const Value.absent(),
    this.isTwoSpaceUser = const Value.absent(),
    this.isDeviceContact = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isOnline = const Value.absent(),
    this.presenceStatus = const Value.absent(),
    this.lastSeenAtEpochMs = const Value.absent(),
    this.lastInteractionAtEpochMs = const Value.absent(),
    this.sortEpochMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AegisPeopleEntriesCompanion.insert({
    required String bucket,
    required String personId,
    required String payloadJson,
    required String displayName,
    this.username = const Value.absent(),
    this.remoteUserId = const Value.absent(),
    this.isTwoSpaceUser = const Value.absent(),
    this.isDeviceContact = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isOnline = const Value.absent(),
    this.presenceStatus = const Value.absent(),
    this.lastSeenAtEpochMs = const Value.absent(),
    this.lastInteractionAtEpochMs = const Value.absent(),
    this.sortEpochMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : bucket = Value(bucket),
       personId = Value(personId),
       payloadJson = Value(payloadJson),
       displayName = Value(displayName);
  static Insertable<AegisPeopleEntry> custom({
    Expression<String>? bucket,
    Expression<String>? personId,
    Expression<String>? payloadJson,
    Expression<String>? displayName,
    Expression<String>? username,
    Expression<String>? remoteUserId,
    Expression<bool>? isTwoSpaceUser,
    Expression<bool>? isDeviceContact,
    Expression<bool>? isFavorite,
    Expression<bool>? isOnline,
    Expression<String>? presenceStatus,
    Expression<int>? lastSeenAtEpochMs,
    Expression<int>? lastInteractionAtEpochMs,
    Expression<int>? sortEpochMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bucket != null) 'bucket': bucket,
      if (personId != null) 'person_id': personId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (displayName != null) 'display_name': displayName,
      if (username != null) 'username': username,
      if (remoteUserId != null) 'remote_user_id': remoteUserId,
      if (isTwoSpaceUser != null) 'is_two_space_user': isTwoSpaceUser,
      if (isDeviceContact != null) 'is_device_contact': isDeviceContact,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isOnline != null) 'is_online': isOnline,
      if (presenceStatus != null) 'presence_status': presenceStatus,
      if (lastSeenAtEpochMs != null) 'last_seen_at_epoch_ms': lastSeenAtEpochMs,
      if (lastInteractionAtEpochMs != null)
        'last_interaction_at_epoch_ms': lastInteractionAtEpochMs,
      if (sortEpochMs != null) 'sort_epoch_ms': sortEpochMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AegisPeopleEntriesCompanion copyWith({
    Value<String>? bucket,
    Value<String>? personId,
    Value<String>? payloadJson,
    Value<String>? displayName,
    Value<String?>? username,
    Value<String?>? remoteUserId,
    Value<bool>? isTwoSpaceUser,
    Value<bool>? isDeviceContact,
    Value<bool>? isFavorite,
    Value<bool>? isOnline,
    Value<String?>? presenceStatus,
    Value<int?>? lastSeenAtEpochMs,
    Value<int?>? lastInteractionAtEpochMs,
    Value<int>? sortEpochMs,
    Value<int>? rowid,
  }) {
    return AegisPeopleEntriesCompanion(
      bucket: bucket ?? this.bucket,
      personId: personId ?? this.personId,
      payloadJson: payloadJson ?? this.payloadJson,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      remoteUserId: remoteUserId ?? this.remoteUserId,
      isTwoSpaceUser: isTwoSpaceUser ?? this.isTwoSpaceUser,
      isDeviceContact: isDeviceContact ?? this.isDeviceContact,
      isFavorite: isFavorite ?? this.isFavorite,
      isOnline: isOnline ?? this.isOnline,
      presenceStatus: presenceStatus ?? this.presenceStatus,
      lastSeenAtEpochMs: lastSeenAtEpochMs ?? this.lastSeenAtEpochMs,
      lastInteractionAtEpochMs:
          lastInteractionAtEpochMs ?? this.lastInteractionAtEpochMs,
      sortEpochMs: sortEpochMs ?? this.sortEpochMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bucket.present) {
      map['bucket'] = Variable<String>(bucket.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (remoteUserId.present) {
      map['remote_user_id'] = Variable<String>(remoteUserId.value);
    }
    if (isTwoSpaceUser.present) {
      map['is_two_space_user'] = Variable<bool>(isTwoSpaceUser.value);
    }
    if (isDeviceContact.present) {
      map['is_device_contact'] = Variable<bool>(isDeviceContact.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isOnline.present) {
      map['is_online'] = Variable<bool>(isOnline.value);
    }
    if (presenceStatus.present) {
      map['presence_status'] = Variable<String>(presenceStatus.value);
    }
    if (lastSeenAtEpochMs.present) {
      map['last_seen_at_epoch_ms'] = Variable<int>(lastSeenAtEpochMs.value);
    }
    if (lastInteractionAtEpochMs.present) {
      map['last_interaction_at_epoch_ms'] = Variable<int>(
        lastInteractionAtEpochMs.value,
      );
    }
    if (sortEpochMs.present) {
      map['sort_epoch_ms'] = Variable<int>(sortEpochMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AegisPeopleEntriesCompanion(')
          ..write('bucket: $bucket, ')
          ..write('personId: $personId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('displayName: $displayName, ')
          ..write('username: $username, ')
          ..write('remoteUserId: $remoteUserId, ')
          ..write('isTwoSpaceUser: $isTwoSpaceUser, ')
          ..write('isDeviceContact: $isDeviceContact, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isOnline: $isOnline, ')
          ..write('presenceStatus: $presenceStatus, ')
          ..write('lastSeenAtEpochMs: $lastSeenAtEpochMs, ')
          ..write('lastInteractionAtEpochMs: $lastInteractionAtEpochMs, ')
          ..write('sortEpochMs: $sortEpochMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AegisPeopleCallHistoryTable extends AegisPeopleCallHistory
    with TableInfo<$AegisPeopleCallHistoryTable, AegisPeopleCallHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AegisPeopleCallHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtEpochMsMeta = const VerificationMeta(
    'startedAtEpochMs',
  );
  @override
  late final GeneratedColumn<int> startedAtEpochMs = GeneratedColumn<int>(
    'started_at_epoch_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isVideoMeta = const VerificationMeta(
    'isVideo',
  );
  @override
  late final GeneratedColumn<bool> isVideo = GeneratedColumn<bool>(
    'is_video',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_video" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    personId,
    payloadJson,
    startedAtEpochMs,
    durationMs,
    isVideo,
    direction,
    outcome,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'aegis_people_call_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<AegisPeopleCallHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('started_at_epoch_ms')) {
      context.handle(
        _startedAtEpochMsMeta,
        startedAtEpochMs.isAcceptableOrUnknown(
          data['started_at_epoch_ms']!,
          _startedAtEpochMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startedAtEpochMsMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('is_video')) {
      context.handle(
        _isVideoMeta,
        isVideo.isAcceptableOrUnknown(data['is_video']!, _isVideoMeta),
      );
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    } else if (isInserting) {
      context.missing(_outcomeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AegisPeopleCallHistoryData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AegisPeopleCallHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      startedAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at_epoch_ms'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      isVideo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_video'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      )!,
    );
  }

  @override
  $AegisPeopleCallHistoryTable createAlias(String alias) {
    return $AegisPeopleCallHistoryTable(attachedDatabase, alias);
  }
}

class AegisPeopleCallHistoryData extends DataClass
    implements Insertable<AegisPeopleCallHistoryData> {
  final String id;
  final String personId;
  final String payloadJson;
  final int startedAtEpochMs;
  final int durationMs;
  final bool isVideo;
  final String direction;
  final String outcome;
  const AegisPeopleCallHistoryData({
    required this.id,
    required this.personId,
    required this.payloadJson,
    required this.startedAtEpochMs,
    required this.durationMs,
    required this.isVideo,
    required this.direction,
    required this.outcome,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['person_id'] = Variable<String>(personId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['started_at_epoch_ms'] = Variable<int>(startedAtEpochMs);
    map['duration_ms'] = Variable<int>(durationMs);
    map['is_video'] = Variable<bool>(isVideo);
    map['direction'] = Variable<String>(direction);
    map['outcome'] = Variable<String>(outcome);
    return map;
  }

  AegisPeopleCallHistoryCompanion toCompanion(bool nullToAbsent) {
    return AegisPeopleCallHistoryCompanion(
      id: Value(id),
      personId: Value(personId),
      payloadJson: Value(payloadJson),
      startedAtEpochMs: Value(startedAtEpochMs),
      durationMs: Value(durationMs),
      isVideo: Value(isVideo),
      direction: Value(direction),
      outcome: Value(outcome),
    );
  }

  factory AegisPeopleCallHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AegisPeopleCallHistoryData(
      id: serializer.fromJson<String>(json['id']),
      personId: serializer.fromJson<String>(json['personId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      startedAtEpochMs: serializer.fromJson<int>(json['startedAtEpochMs']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      isVideo: serializer.fromJson<bool>(json['isVideo']),
      direction: serializer.fromJson<String>(json['direction']),
      outcome: serializer.fromJson<String>(json['outcome']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'personId': serializer.toJson<String>(personId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'startedAtEpochMs': serializer.toJson<int>(startedAtEpochMs),
      'durationMs': serializer.toJson<int>(durationMs),
      'isVideo': serializer.toJson<bool>(isVideo),
      'direction': serializer.toJson<String>(direction),
      'outcome': serializer.toJson<String>(outcome),
    };
  }

  AegisPeopleCallHistoryData copyWith({
    String? id,
    String? personId,
    String? payloadJson,
    int? startedAtEpochMs,
    int? durationMs,
    bool? isVideo,
    String? direction,
    String? outcome,
  }) => AegisPeopleCallHistoryData(
    id: id ?? this.id,
    personId: personId ?? this.personId,
    payloadJson: payloadJson ?? this.payloadJson,
    startedAtEpochMs: startedAtEpochMs ?? this.startedAtEpochMs,
    durationMs: durationMs ?? this.durationMs,
    isVideo: isVideo ?? this.isVideo,
    direction: direction ?? this.direction,
    outcome: outcome ?? this.outcome,
  );
  AegisPeopleCallHistoryData copyWithCompanion(
    AegisPeopleCallHistoryCompanion data,
  ) {
    return AegisPeopleCallHistoryData(
      id: data.id.present ? data.id.value : this.id,
      personId: data.personId.present ? data.personId.value : this.personId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      startedAtEpochMs: data.startedAtEpochMs.present
          ? data.startedAtEpochMs.value
          : this.startedAtEpochMs,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      isVideo: data.isVideo.present ? data.isVideo.value : this.isVideo,
      direction: data.direction.present ? data.direction.value : this.direction,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AegisPeopleCallHistoryData(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('startedAtEpochMs: $startedAtEpochMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('isVideo: $isVideo, ')
          ..write('direction: $direction, ')
          ..write('outcome: $outcome')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    personId,
    payloadJson,
    startedAtEpochMs,
    durationMs,
    isVideo,
    direction,
    outcome,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AegisPeopleCallHistoryData &&
          other.id == this.id &&
          other.personId == this.personId &&
          other.payloadJson == this.payloadJson &&
          other.startedAtEpochMs == this.startedAtEpochMs &&
          other.durationMs == this.durationMs &&
          other.isVideo == this.isVideo &&
          other.direction == this.direction &&
          other.outcome == this.outcome);
}

class AegisPeopleCallHistoryCompanion
    extends UpdateCompanion<AegisPeopleCallHistoryData> {
  final Value<String> id;
  final Value<String> personId;
  final Value<String> payloadJson;
  final Value<int> startedAtEpochMs;
  final Value<int> durationMs;
  final Value<bool> isVideo;
  final Value<String> direction;
  final Value<String> outcome;
  final Value<int> rowid;
  const AegisPeopleCallHistoryCompanion({
    this.id = const Value.absent(),
    this.personId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.startedAtEpochMs = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.isVideo = const Value.absent(),
    this.direction = const Value.absent(),
    this.outcome = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AegisPeopleCallHistoryCompanion.insert({
    required String id,
    required String personId,
    required String payloadJson,
    required int startedAtEpochMs,
    this.durationMs = const Value.absent(),
    this.isVideo = const Value.absent(),
    required String direction,
    required String outcome,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       personId = Value(personId),
       payloadJson = Value(payloadJson),
       startedAtEpochMs = Value(startedAtEpochMs),
       direction = Value(direction),
       outcome = Value(outcome);
  static Insertable<AegisPeopleCallHistoryData> custom({
    Expression<String>? id,
    Expression<String>? personId,
    Expression<String>? payloadJson,
    Expression<int>? startedAtEpochMs,
    Expression<int>? durationMs,
    Expression<bool>? isVideo,
    Expression<String>? direction,
    Expression<String>? outcome,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personId != null) 'person_id': personId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (startedAtEpochMs != null) 'started_at_epoch_ms': startedAtEpochMs,
      if (durationMs != null) 'duration_ms': durationMs,
      if (isVideo != null) 'is_video': isVideo,
      if (direction != null) 'direction': direction,
      if (outcome != null) 'outcome': outcome,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AegisPeopleCallHistoryCompanion copyWith({
    Value<String>? id,
    Value<String>? personId,
    Value<String>? payloadJson,
    Value<int>? startedAtEpochMs,
    Value<int>? durationMs,
    Value<bool>? isVideo,
    Value<String>? direction,
    Value<String>? outcome,
    Value<int>? rowid,
  }) {
    return AegisPeopleCallHistoryCompanion(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      payloadJson: payloadJson ?? this.payloadJson,
      startedAtEpochMs: startedAtEpochMs ?? this.startedAtEpochMs,
      durationMs: durationMs ?? this.durationMs,
      isVideo: isVideo ?? this.isVideo,
      direction: direction ?? this.direction,
      outcome: outcome ?? this.outcome,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (startedAtEpochMs.present) {
      map['started_at_epoch_ms'] = Variable<int>(startedAtEpochMs.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (isVideo.present) {
      map['is_video'] = Variable<bool>(isVideo.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AegisPeopleCallHistoryCompanion(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('startedAtEpochMs: $startedAtEpochMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('isVideo: $isVideo, ')
          ..write('direction: $direction, ')
          ..write('outcome: $outcome, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AegisChatDatabase extends GeneratedDatabase {
  _$AegisChatDatabase(QueryExecutor e) : super(e);
  $AegisChatDatabaseManager get managers => $AegisChatDatabaseManager(this);
  late final $AegisConversationsTable aegisConversations =
      $AegisConversationsTable(this);
  late final $AegisMessagesTable aegisMessages = $AegisMessagesTable(this);
  late final $AegisProfilesTable aegisProfiles = $AegisProfilesTable(this);
  late final $AegisMetadataTable aegisMetadata = $AegisMetadataTable(this);
  late final $AegisOfflineQueueTable aegisOfflineQueue =
      $AegisOfflineQueueTable(this);
  late final $AegisPeopleFavoritesTable aegisPeopleFavorites =
      $AegisPeopleFavoritesTable(this);
  late final $AegisPeopleEntriesTable aegisPeopleEntries =
      $AegisPeopleEntriesTable(this);
  late final $AegisPeopleCallHistoryTable aegisPeopleCallHistory =
      $AegisPeopleCallHistoryTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    aegisConversations,
    aegisMessages,
    aegisProfiles,
    aegisMetadata,
    aegisOfflineQueue,
    aegisPeopleFavorites,
    aegisPeopleEntries,
    aegisPeopleCallHistory,
  ];
}

typedef $$AegisConversationsTableCreateCompanionBuilder =
    AegisConversationsCompanion Function({
      required String id,
      required String title,
      required String kind,
      required int updatedAtEpochMs,
      Value<String?> lastMessage,
      Value<int> unreadCount,
      Value<String?> avatarUrl,
      Value<String?> description,
      Value<int?> peerUserId,
      Value<String?> peerUsername,
      Value<int?> channelId,
      Value<bool> isPublic,
      Value<bool> showMessageHistory,
      Value<String> memberUserIdsJson,
      Value<int> rowid,
    });
typedef $$AegisConversationsTableUpdateCompanionBuilder =
    AegisConversationsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> kind,
      Value<int> updatedAtEpochMs,
      Value<String?> lastMessage,
      Value<int> unreadCount,
      Value<String?> avatarUrl,
      Value<String?> description,
      Value<int?> peerUserId,
      Value<String?> peerUsername,
      Value<int?> channelId,
      Value<bool> isPublic,
      Value<bool> showMessageHistory,
      Value<String> memberUserIdsJson,
      Value<int> rowid,
    });

class $$AegisConversationsTableFilterComposer
    extends Composer<_$AegisChatDatabase, $AegisConversationsTable> {
  $$AegisConversationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtEpochMs => $composableBuilder(
    column: $table.updatedAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastMessage => $composableBuilder(
    column: $table.lastMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get peerUserId => $composableBuilder(
    column: $table.peerUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get peerUsername => $composableBuilder(
    column: $table.peerUsername,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPublic => $composableBuilder(
    column: $table.isPublic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showMessageHistory => $composableBuilder(
    column: $table.showMessageHistory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberUserIdsJson => $composableBuilder(
    column: $table.memberUserIdsJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AegisConversationsTableOrderingComposer
    extends Composer<_$AegisChatDatabase, $AegisConversationsTable> {
  $$AegisConversationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtEpochMs => $composableBuilder(
    column: $table.updatedAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastMessage => $composableBuilder(
    column: $table.lastMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get peerUserId => $composableBuilder(
    column: $table.peerUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get peerUsername => $composableBuilder(
    column: $table.peerUsername,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPublic => $composableBuilder(
    column: $table.isPublic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showMessageHistory => $composableBuilder(
    column: $table.showMessageHistory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberUserIdsJson => $composableBuilder(
    column: $table.memberUserIdsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AegisConversationsTableAnnotationComposer
    extends Composer<_$AegisChatDatabase, $AegisConversationsTable> {
  $$AegisConversationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get updatedAtEpochMs => $composableBuilder(
    column: $table.updatedAtEpochMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastMessage => $composableBuilder(
    column: $table.lastMessage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get peerUserId => $composableBuilder(
    column: $table.peerUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get peerUsername => $composableBuilder(
    column: $table.peerUsername,
    builder: (column) => column,
  );

  GeneratedColumn<int> get channelId =>
      $composableBuilder(column: $table.channelId, builder: (column) => column);

  GeneratedColumn<bool> get isPublic =>
      $composableBuilder(column: $table.isPublic, builder: (column) => column);

  GeneratedColumn<bool> get showMessageHistory => $composableBuilder(
    column: $table.showMessageHistory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get memberUserIdsJson => $composableBuilder(
    column: $table.memberUserIdsJson,
    builder: (column) => column,
  );
}

class $$AegisConversationsTableTableManager
    extends
        RootTableManager<
          _$AegisChatDatabase,
          $AegisConversationsTable,
          AegisConversation,
          $$AegisConversationsTableFilterComposer,
          $$AegisConversationsTableOrderingComposer,
          $$AegisConversationsTableAnnotationComposer,
          $$AegisConversationsTableCreateCompanionBuilder,
          $$AegisConversationsTableUpdateCompanionBuilder,
          (
            AegisConversation,
            BaseReferences<
              _$AegisChatDatabase,
              $AegisConversationsTable,
              AegisConversation
            >,
          ),
          AegisConversation,
          PrefetchHooks Function()
        > {
  $$AegisConversationsTableTableManager(
    _$AegisChatDatabase db,
    $AegisConversationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AegisConversationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AegisConversationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AegisConversationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> updatedAtEpochMs = const Value.absent(),
                Value<String?> lastMessage = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int?> peerUserId = const Value.absent(),
                Value<String?> peerUsername = const Value.absent(),
                Value<int?> channelId = const Value.absent(),
                Value<bool> isPublic = const Value.absent(),
                Value<bool> showMessageHistory = const Value.absent(),
                Value<String> memberUserIdsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AegisConversationsCompanion(
                id: id,
                title: title,
                kind: kind,
                updatedAtEpochMs: updatedAtEpochMs,
                lastMessage: lastMessage,
                unreadCount: unreadCount,
                avatarUrl: avatarUrl,
                description: description,
                peerUserId: peerUserId,
                peerUsername: peerUsername,
                channelId: channelId,
                isPublic: isPublic,
                showMessageHistory: showMessageHistory,
                memberUserIdsJson: memberUserIdsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String kind,
                required int updatedAtEpochMs,
                Value<String?> lastMessage = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int?> peerUserId = const Value.absent(),
                Value<String?> peerUsername = const Value.absent(),
                Value<int?> channelId = const Value.absent(),
                Value<bool> isPublic = const Value.absent(),
                Value<bool> showMessageHistory = const Value.absent(),
                Value<String> memberUserIdsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AegisConversationsCompanion.insert(
                id: id,
                title: title,
                kind: kind,
                updatedAtEpochMs: updatedAtEpochMs,
                lastMessage: lastMessage,
                unreadCount: unreadCount,
                avatarUrl: avatarUrl,
                description: description,
                peerUserId: peerUserId,
                peerUsername: peerUsername,
                channelId: channelId,
                isPublic: isPublic,
                showMessageHistory: showMessageHistory,
                memberUserIdsJson: memberUserIdsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AegisConversationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AegisChatDatabase,
      $AegisConversationsTable,
      AegisConversation,
      $$AegisConversationsTableFilterComposer,
      $$AegisConversationsTableOrderingComposer,
      $$AegisConversationsTableAnnotationComposer,
      $$AegisConversationsTableCreateCompanionBuilder,
      $$AegisConversationsTableUpdateCompanionBuilder,
      (
        AegisConversation,
        BaseReferences<
          _$AegisChatDatabase,
          $AegisConversationsTable,
          AegisConversation
        >,
      ),
      AegisConversation,
      PrefetchHooks Function()
    >;
typedef $$AegisMessagesTableCreateCompanionBuilder =
    AegisMessagesCompanion Function({
      required String id,
      required String roomId,
      required String senderId,
      required String content,
      required int sentAtEpochMs,
      Value<String> type,
      Value<String?> mediaId,
      Value<int?> replyToMessageId,
      Value<bool> isDelivered,
      Value<bool> isRead,
      Value<int?> deliveredAtEpochMs,
      Value<int?> readAtEpochMs,
      Value<int> rowid,
    });
typedef $$AegisMessagesTableUpdateCompanionBuilder =
    AegisMessagesCompanion Function({
      Value<String> id,
      Value<String> roomId,
      Value<String> senderId,
      Value<String> content,
      Value<int> sentAtEpochMs,
      Value<String> type,
      Value<String?> mediaId,
      Value<int?> replyToMessageId,
      Value<bool> isDelivered,
      Value<bool> isRead,
      Value<int?> deliveredAtEpochMs,
      Value<int?> readAtEpochMs,
      Value<int> rowid,
    });

class $$AegisMessagesTableFilterComposer
    extends Composer<_$AegisChatDatabase, $AegisMessagesTable> {
  $$AegisMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sentAtEpochMs => $composableBuilder(
    column: $table.sentAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaId => $composableBuilder(
    column: $table.mediaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get replyToMessageId => $composableBuilder(
    column: $table.replyToMessageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDelivered => $composableBuilder(
    column: $table.isDelivered,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deliveredAtEpochMs => $composableBuilder(
    column: $table.deliveredAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get readAtEpochMs => $composableBuilder(
    column: $table.readAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AegisMessagesTableOrderingComposer
    extends Composer<_$AegisChatDatabase, $AegisMessagesTable> {
  $$AegisMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sentAtEpochMs => $composableBuilder(
    column: $table.sentAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaId => $composableBuilder(
    column: $table.mediaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get replyToMessageId => $composableBuilder(
    column: $table.replyToMessageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDelivered => $composableBuilder(
    column: $table.isDelivered,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deliveredAtEpochMs => $composableBuilder(
    column: $table.deliveredAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get readAtEpochMs => $composableBuilder(
    column: $table.readAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AegisMessagesTableAnnotationComposer
    extends Composer<_$AegisChatDatabase, $AegisMessagesTable> {
  $$AegisMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get sentAtEpochMs => $composableBuilder(
    column: $table.sentAtEpochMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get mediaId =>
      $composableBuilder(column: $table.mediaId, builder: (column) => column);

  GeneratedColumn<int> get replyToMessageId => $composableBuilder(
    column: $table.replyToMessageId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDelivered => $composableBuilder(
    column: $table.isDelivered,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<int> get deliveredAtEpochMs => $composableBuilder(
    column: $table.deliveredAtEpochMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get readAtEpochMs => $composableBuilder(
    column: $table.readAtEpochMs,
    builder: (column) => column,
  );
}

class $$AegisMessagesTableTableManager
    extends
        RootTableManager<
          _$AegisChatDatabase,
          $AegisMessagesTable,
          AegisMessage,
          $$AegisMessagesTableFilterComposer,
          $$AegisMessagesTableOrderingComposer,
          $$AegisMessagesTableAnnotationComposer,
          $$AegisMessagesTableCreateCompanionBuilder,
          $$AegisMessagesTableUpdateCompanionBuilder,
          (
            AegisMessage,
            BaseReferences<
              _$AegisChatDatabase,
              $AegisMessagesTable,
              AegisMessage
            >,
          ),
          AegisMessage,
          PrefetchHooks Function()
        > {
  $$AegisMessagesTableTableManager(
    _$AegisChatDatabase db,
    $AegisMessagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AegisMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AegisMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AegisMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> roomId = const Value.absent(),
                Value<String> senderId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> sentAtEpochMs = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> mediaId = const Value.absent(),
                Value<int?> replyToMessageId = const Value.absent(),
                Value<bool> isDelivered = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<int?> deliveredAtEpochMs = const Value.absent(),
                Value<int?> readAtEpochMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AegisMessagesCompanion(
                id: id,
                roomId: roomId,
                senderId: senderId,
                content: content,
                sentAtEpochMs: sentAtEpochMs,
                type: type,
                mediaId: mediaId,
                replyToMessageId: replyToMessageId,
                isDelivered: isDelivered,
                isRead: isRead,
                deliveredAtEpochMs: deliveredAtEpochMs,
                readAtEpochMs: readAtEpochMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String roomId,
                required String senderId,
                required String content,
                required int sentAtEpochMs,
                Value<String> type = const Value.absent(),
                Value<String?> mediaId = const Value.absent(),
                Value<int?> replyToMessageId = const Value.absent(),
                Value<bool> isDelivered = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<int?> deliveredAtEpochMs = const Value.absent(),
                Value<int?> readAtEpochMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AegisMessagesCompanion.insert(
                id: id,
                roomId: roomId,
                senderId: senderId,
                content: content,
                sentAtEpochMs: sentAtEpochMs,
                type: type,
                mediaId: mediaId,
                replyToMessageId: replyToMessageId,
                isDelivered: isDelivered,
                isRead: isRead,
                deliveredAtEpochMs: deliveredAtEpochMs,
                readAtEpochMs: readAtEpochMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AegisMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AegisChatDatabase,
      $AegisMessagesTable,
      AegisMessage,
      $$AegisMessagesTableFilterComposer,
      $$AegisMessagesTableOrderingComposer,
      $$AegisMessagesTableAnnotationComposer,
      $$AegisMessagesTableCreateCompanionBuilder,
      $$AegisMessagesTableUpdateCompanionBuilder,
      (
        AegisMessage,
        BaseReferences<_$AegisChatDatabase, $AegisMessagesTable, AegisMessage>,
      ),
      AegisMessage,
      PrefetchHooks Function()
    >;
typedef $$AegisProfilesTableCreateCompanionBuilder =
    AegisProfilesCompanion Function({
      Value<int> userId,
      required String payloadJson,
      Value<String?> username,
      Value<String?> displayName,
      Value<String?> avatarUrl,
      Value<String?> presenceStatus,
      Value<bool> isOnline,
      Value<int?> lastSeenAtEpochMs,
    });
typedef $$AegisProfilesTableUpdateCompanionBuilder =
    AegisProfilesCompanion Function({
      Value<int> userId,
      Value<String> payloadJson,
      Value<String?> username,
      Value<String?> displayName,
      Value<String?> avatarUrl,
      Value<String?> presenceStatus,
      Value<bool> isOnline,
      Value<int?> lastSeenAtEpochMs,
    });

class $$AegisProfilesTableFilterComposer
    extends Composer<_$AegisChatDatabase, $AegisProfilesTable> {
  $$AegisProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get presenceStatus => $composableBuilder(
    column: $table.presenceStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOnline => $composableBuilder(
    column: $table.isOnline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSeenAtEpochMs => $composableBuilder(
    column: $table.lastSeenAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AegisProfilesTableOrderingComposer
    extends Composer<_$AegisChatDatabase, $AegisProfilesTable> {
  $$AegisProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get presenceStatus => $composableBuilder(
    column: $table.presenceStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOnline => $composableBuilder(
    column: $table.isOnline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSeenAtEpochMs => $composableBuilder(
    column: $table.lastSeenAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AegisProfilesTableAnnotationComposer
    extends Composer<_$AegisChatDatabase, $AegisProfilesTable> {
  $$AegisProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<String> get presenceStatus => $composableBuilder(
    column: $table.presenceStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isOnline =>
      $composableBuilder(column: $table.isOnline, builder: (column) => column);

  GeneratedColumn<int> get lastSeenAtEpochMs => $composableBuilder(
    column: $table.lastSeenAtEpochMs,
    builder: (column) => column,
  );
}

class $$AegisProfilesTableTableManager
    extends
        RootTableManager<
          _$AegisChatDatabase,
          $AegisProfilesTable,
          AegisProfile,
          $$AegisProfilesTableFilterComposer,
          $$AegisProfilesTableOrderingComposer,
          $$AegisProfilesTableAnnotationComposer,
          $$AegisProfilesTableCreateCompanionBuilder,
          $$AegisProfilesTableUpdateCompanionBuilder,
          (
            AegisProfile,
            BaseReferences<
              _$AegisChatDatabase,
              $AegisProfilesTable,
              AegisProfile
            >,
          ),
          AegisProfile,
          PrefetchHooks Function()
        > {
  $$AegisProfilesTableTableManager(
    _$AegisChatDatabase db,
    $AegisProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AegisProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AegisProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AegisProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> userId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String?> presenceStatus = const Value.absent(),
                Value<bool> isOnline = const Value.absent(),
                Value<int?> lastSeenAtEpochMs = const Value.absent(),
              }) => AegisProfilesCompanion(
                userId: userId,
                payloadJson: payloadJson,
                username: username,
                displayName: displayName,
                avatarUrl: avatarUrl,
                presenceStatus: presenceStatus,
                isOnline: isOnline,
                lastSeenAtEpochMs: lastSeenAtEpochMs,
              ),
          createCompanionCallback:
              ({
                Value<int> userId = const Value.absent(),
                required String payloadJson,
                Value<String?> username = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String?> presenceStatus = const Value.absent(),
                Value<bool> isOnline = const Value.absent(),
                Value<int?> lastSeenAtEpochMs = const Value.absent(),
              }) => AegisProfilesCompanion.insert(
                userId: userId,
                payloadJson: payloadJson,
                username: username,
                displayName: displayName,
                avatarUrl: avatarUrl,
                presenceStatus: presenceStatus,
                isOnline: isOnline,
                lastSeenAtEpochMs: lastSeenAtEpochMs,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AegisProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AegisChatDatabase,
      $AegisProfilesTable,
      AegisProfile,
      $$AegisProfilesTableFilterComposer,
      $$AegisProfilesTableOrderingComposer,
      $$AegisProfilesTableAnnotationComposer,
      $$AegisProfilesTableCreateCompanionBuilder,
      $$AegisProfilesTableUpdateCompanionBuilder,
      (
        AegisProfile,
        BaseReferences<_$AegisChatDatabase, $AegisProfilesTable, AegisProfile>,
      ),
      AegisProfile,
      PrefetchHooks Function()
    >;
typedef $$AegisMetadataTableCreateCompanionBuilder =
    AegisMetadataCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AegisMetadataTableUpdateCompanionBuilder =
    AegisMetadataCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AegisMetadataTableFilterComposer
    extends Composer<_$AegisChatDatabase, $AegisMetadataTable> {
  $$AegisMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AegisMetadataTableOrderingComposer
    extends Composer<_$AegisChatDatabase, $AegisMetadataTable> {
  $$AegisMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AegisMetadataTableAnnotationComposer
    extends Composer<_$AegisChatDatabase, $AegisMetadataTable> {
  $$AegisMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AegisMetadataTableTableManager
    extends
        RootTableManager<
          _$AegisChatDatabase,
          $AegisMetadataTable,
          AegisMetadataData,
          $$AegisMetadataTableFilterComposer,
          $$AegisMetadataTableOrderingComposer,
          $$AegisMetadataTableAnnotationComposer,
          $$AegisMetadataTableCreateCompanionBuilder,
          $$AegisMetadataTableUpdateCompanionBuilder,
          (
            AegisMetadataData,
            BaseReferences<
              _$AegisChatDatabase,
              $AegisMetadataTable,
              AegisMetadataData
            >,
          ),
          AegisMetadataData,
          PrefetchHooks Function()
        > {
  $$AegisMetadataTableTableManager(
    _$AegisChatDatabase db,
    $AegisMetadataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AegisMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AegisMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AegisMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  AegisMetadataCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AegisMetadataCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AegisMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AegisChatDatabase,
      $AegisMetadataTable,
      AegisMetadataData,
      $$AegisMetadataTableFilterComposer,
      $$AegisMetadataTableOrderingComposer,
      $$AegisMetadataTableAnnotationComposer,
      $$AegisMetadataTableCreateCompanionBuilder,
      $$AegisMetadataTableUpdateCompanionBuilder,
      (
        AegisMetadataData,
        BaseReferences<
          _$AegisChatDatabase,
          $AegisMetadataTable,
          AegisMetadataData
        >,
      ),
      AegisMetadataData,
      PrefetchHooks Function()
    >;
typedef $$AegisOfflineQueueTableCreateCompanionBuilder =
    AegisOfflineQueueCompanion Function({
      Value<int> id,
      required String chatId,
      required String content,
      required String type,
      required int createdAtEpochMs,
      Value<bool> sent,
      Value<String?> errorMessage,
    });
typedef $$AegisOfflineQueueTableUpdateCompanionBuilder =
    AegisOfflineQueueCompanion Function({
      Value<int> id,
      Value<String> chatId,
      Value<String> content,
      Value<String> type,
      Value<int> createdAtEpochMs,
      Value<bool> sent,
      Value<String?> errorMessage,
    });

class $$AegisOfflineQueueTableFilterComposer
    extends Composer<_$AegisChatDatabase, $AegisOfflineQueueTable> {
  $$AegisOfflineQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtEpochMs => $composableBuilder(
    column: $table.createdAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get sent => $composableBuilder(
    column: $table.sent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AegisOfflineQueueTableOrderingComposer
    extends Composer<_$AegisChatDatabase, $AegisOfflineQueueTable> {
  $$AegisOfflineQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtEpochMs => $composableBuilder(
    column: $table.createdAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get sent => $composableBuilder(
    column: $table.sent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AegisOfflineQueueTableAnnotationComposer
    extends Composer<_$AegisChatDatabase, $AegisOfflineQueueTable> {
  $$AegisOfflineQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get chatId =>
      $composableBuilder(column: $table.chatId, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get createdAtEpochMs => $composableBuilder(
    column: $table.createdAtEpochMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get sent =>
      $composableBuilder(column: $table.sent, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );
}

class $$AegisOfflineQueueTableTableManager
    extends
        RootTableManager<
          _$AegisChatDatabase,
          $AegisOfflineQueueTable,
          AegisOfflineQueueData,
          $$AegisOfflineQueueTableFilterComposer,
          $$AegisOfflineQueueTableOrderingComposer,
          $$AegisOfflineQueueTableAnnotationComposer,
          $$AegisOfflineQueueTableCreateCompanionBuilder,
          $$AegisOfflineQueueTableUpdateCompanionBuilder,
          (
            AegisOfflineQueueData,
            BaseReferences<
              _$AegisChatDatabase,
              $AegisOfflineQueueTable,
              AegisOfflineQueueData
            >,
          ),
          AegisOfflineQueueData,
          PrefetchHooks Function()
        > {
  $$AegisOfflineQueueTableTableManager(
    _$AegisChatDatabase db,
    $AegisOfflineQueueTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AegisOfflineQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AegisOfflineQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AegisOfflineQueueTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> chatId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> createdAtEpochMs = const Value.absent(),
                Value<bool> sent = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
              }) => AegisOfflineQueueCompanion(
                id: id,
                chatId: chatId,
                content: content,
                type: type,
                createdAtEpochMs: createdAtEpochMs,
                sent: sent,
                errorMessage: errorMessage,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String chatId,
                required String content,
                required String type,
                required int createdAtEpochMs,
                Value<bool> sent = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
              }) => AegisOfflineQueueCompanion.insert(
                id: id,
                chatId: chatId,
                content: content,
                type: type,
                createdAtEpochMs: createdAtEpochMs,
                sent: sent,
                errorMessage: errorMessage,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AegisOfflineQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AegisChatDatabase,
      $AegisOfflineQueueTable,
      AegisOfflineQueueData,
      $$AegisOfflineQueueTableFilterComposer,
      $$AegisOfflineQueueTableOrderingComposer,
      $$AegisOfflineQueueTableAnnotationComposer,
      $$AegisOfflineQueueTableCreateCompanionBuilder,
      $$AegisOfflineQueueTableUpdateCompanionBuilder,
      (
        AegisOfflineQueueData,
        BaseReferences<
          _$AegisChatDatabase,
          $AegisOfflineQueueTable,
          AegisOfflineQueueData
        >,
      ),
      AegisOfflineQueueData,
      PrefetchHooks Function()
    >;
typedef $$AegisPeopleFavoritesTableCreateCompanionBuilder =
    AegisPeopleFavoritesCompanion Function({
      required String personId,
      Value<int> rowid,
    });
typedef $$AegisPeopleFavoritesTableUpdateCompanionBuilder =
    AegisPeopleFavoritesCompanion Function({
      Value<String> personId,
      Value<int> rowid,
    });

class $$AegisPeopleFavoritesTableFilterComposer
    extends Composer<_$AegisChatDatabase, $AegisPeopleFavoritesTable> {
  $$AegisPeopleFavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AegisPeopleFavoritesTableOrderingComposer
    extends Composer<_$AegisChatDatabase, $AegisPeopleFavoritesTable> {
  $$AegisPeopleFavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AegisPeopleFavoritesTableAnnotationComposer
    extends Composer<_$AegisChatDatabase, $AegisPeopleFavoritesTable> {
  $$AegisPeopleFavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get personId =>
      $composableBuilder(column: $table.personId, builder: (column) => column);
}

class $$AegisPeopleFavoritesTableTableManager
    extends
        RootTableManager<
          _$AegisChatDatabase,
          $AegisPeopleFavoritesTable,
          AegisPeopleFavorite,
          $$AegisPeopleFavoritesTableFilterComposer,
          $$AegisPeopleFavoritesTableOrderingComposer,
          $$AegisPeopleFavoritesTableAnnotationComposer,
          $$AegisPeopleFavoritesTableCreateCompanionBuilder,
          $$AegisPeopleFavoritesTableUpdateCompanionBuilder,
          (
            AegisPeopleFavorite,
            BaseReferences<
              _$AegisChatDatabase,
              $AegisPeopleFavoritesTable,
              AegisPeopleFavorite
            >,
          ),
          AegisPeopleFavorite,
          PrefetchHooks Function()
        > {
  $$AegisPeopleFavoritesTableTableManager(
    _$AegisChatDatabase db,
    $AegisPeopleFavoritesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AegisPeopleFavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AegisPeopleFavoritesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AegisPeopleFavoritesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> personId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AegisPeopleFavoritesCompanion(
                personId: personId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String personId,
                Value<int> rowid = const Value.absent(),
              }) => AegisPeopleFavoritesCompanion.insert(
                personId: personId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AegisPeopleFavoritesTableProcessedTableManager =
    ProcessedTableManager<
      _$AegisChatDatabase,
      $AegisPeopleFavoritesTable,
      AegisPeopleFavorite,
      $$AegisPeopleFavoritesTableFilterComposer,
      $$AegisPeopleFavoritesTableOrderingComposer,
      $$AegisPeopleFavoritesTableAnnotationComposer,
      $$AegisPeopleFavoritesTableCreateCompanionBuilder,
      $$AegisPeopleFavoritesTableUpdateCompanionBuilder,
      (
        AegisPeopleFavorite,
        BaseReferences<
          _$AegisChatDatabase,
          $AegisPeopleFavoritesTable,
          AegisPeopleFavorite
        >,
      ),
      AegisPeopleFavorite,
      PrefetchHooks Function()
    >;
typedef $$AegisPeopleEntriesTableCreateCompanionBuilder =
    AegisPeopleEntriesCompanion Function({
      required String bucket,
      required String personId,
      required String payloadJson,
      required String displayName,
      Value<String?> username,
      Value<String?> remoteUserId,
      Value<bool> isTwoSpaceUser,
      Value<bool> isDeviceContact,
      Value<bool> isFavorite,
      Value<bool> isOnline,
      Value<String?> presenceStatus,
      Value<int?> lastSeenAtEpochMs,
      Value<int?> lastInteractionAtEpochMs,
      Value<int> sortEpochMs,
      Value<int> rowid,
    });
typedef $$AegisPeopleEntriesTableUpdateCompanionBuilder =
    AegisPeopleEntriesCompanion Function({
      Value<String> bucket,
      Value<String> personId,
      Value<String> payloadJson,
      Value<String> displayName,
      Value<String?> username,
      Value<String?> remoteUserId,
      Value<bool> isTwoSpaceUser,
      Value<bool> isDeviceContact,
      Value<bool> isFavorite,
      Value<bool> isOnline,
      Value<String?> presenceStatus,
      Value<int?> lastSeenAtEpochMs,
      Value<int?> lastInteractionAtEpochMs,
      Value<int> sortEpochMs,
      Value<int> rowid,
    });

class $$AegisPeopleEntriesTableFilterComposer
    extends Composer<_$AegisChatDatabase, $AegisPeopleEntriesTable> {
  $$AegisPeopleEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get bucket => $composableBuilder(
    column: $table.bucket,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteUserId => $composableBuilder(
    column: $table.remoteUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTwoSpaceUser => $composableBuilder(
    column: $table.isTwoSpaceUser,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeviceContact => $composableBuilder(
    column: $table.isDeviceContact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOnline => $composableBuilder(
    column: $table.isOnline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get presenceStatus => $composableBuilder(
    column: $table.presenceStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSeenAtEpochMs => $composableBuilder(
    column: $table.lastSeenAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastInteractionAtEpochMs => $composableBuilder(
    column: $table.lastInteractionAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortEpochMs => $composableBuilder(
    column: $table.sortEpochMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AegisPeopleEntriesTableOrderingComposer
    extends Composer<_$AegisChatDatabase, $AegisPeopleEntriesTable> {
  $$AegisPeopleEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get bucket => $composableBuilder(
    column: $table.bucket,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteUserId => $composableBuilder(
    column: $table.remoteUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTwoSpaceUser => $composableBuilder(
    column: $table.isTwoSpaceUser,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeviceContact => $composableBuilder(
    column: $table.isDeviceContact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOnline => $composableBuilder(
    column: $table.isOnline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get presenceStatus => $composableBuilder(
    column: $table.presenceStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSeenAtEpochMs => $composableBuilder(
    column: $table.lastSeenAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastInteractionAtEpochMs => $composableBuilder(
    column: $table.lastInteractionAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortEpochMs => $composableBuilder(
    column: $table.sortEpochMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AegisPeopleEntriesTableAnnotationComposer
    extends Composer<_$AegisChatDatabase, $AegisPeopleEntriesTable> {
  $$AegisPeopleEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bucket =>
      $composableBuilder(column: $table.bucket, builder: (column) => column);

  GeneratedColumn<String> get personId =>
      $composableBuilder(column: $table.personId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get remoteUserId => $composableBuilder(
    column: $table.remoteUserId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isTwoSpaceUser => $composableBuilder(
    column: $table.isTwoSpaceUser,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeviceContact => $composableBuilder(
    column: $table.isDeviceContact,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isOnline =>
      $composableBuilder(column: $table.isOnline, builder: (column) => column);

  GeneratedColumn<String> get presenceStatus => $composableBuilder(
    column: $table.presenceStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSeenAtEpochMs => $composableBuilder(
    column: $table.lastSeenAtEpochMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastInteractionAtEpochMs => $composableBuilder(
    column: $table.lastInteractionAtEpochMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortEpochMs => $composableBuilder(
    column: $table.sortEpochMs,
    builder: (column) => column,
  );
}

class $$AegisPeopleEntriesTableTableManager
    extends
        RootTableManager<
          _$AegisChatDatabase,
          $AegisPeopleEntriesTable,
          AegisPeopleEntry,
          $$AegisPeopleEntriesTableFilterComposer,
          $$AegisPeopleEntriesTableOrderingComposer,
          $$AegisPeopleEntriesTableAnnotationComposer,
          $$AegisPeopleEntriesTableCreateCompanionBuilder,
          $$AegisPeopleEntriesTableUpdateCompanionBuilder,
          (
            AegisPeopleEntry,
            BaseReferences<
              _$AegisChatDatabase,
              $AegisPeopleEntriesTable,
              AegisPeopleEntry
            >,
          ),
          AegisPeopleEntry,
          PrefetchHooks Function()
        > {
  $$AegisPeopleEntriesTableTableManager(
    _$AegisChatDatabase db,
    $AegisPeopleEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AegisPeopleEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AegisPeopleEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AegisPeopleEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> bucket = const Value.absent(),
                Value<String> personId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<String?> remoteUserId = const Value.absent(),
                Value<bool> isTwoSpaceUser = const Value.absent(),
                Value<bool> isDeviceContact = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isOnline = const Value.absent(),
                Value<String?> presenceStatus = const Value.absent(),
                Value<int?> lastSeenAtEpochMs = const Value.absent(),
                Value<int?> lastInteractionAtEpochMs = const Value.absent(),
                Value<int> sortEpochMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AegisPeopleEntriesCompanion(
                bucket: bucket,
                personId: personId,
                payloadJson: payloadJson,
                displayName: displayName,
                username: username,
                remoteUserId: remoteUserId,
                isTwoSpaceUser: isTwoSpaceUser,
                isDeviceContact: isDeviceContact,
                isFavorite: isFavorite,
                isOnline: isOnline,
                presenceStatus: presenceStatus,
                lastSeenAtEpochMs: lastSeenAtEpochMs,
                lastInteractionAtEpochMs: lastInteractionAtEpochMs,
                sortEpochMs: sortEpochMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bucket,
                required String personId,
                required String payloadJson,
                required String displayName,
                Value<String?> username = const Value.absent(),
                Value<String?> remoteUserId = const Value.absent(),
                Value<bool> isTwoSpaceUser = const Value.absent(),
                Value<bool> isDeviceContact = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isOnline = const Value.absent(),
                Value<String?> presenceStatus = const Value.absent(),
                Value<int?> lastSeenAtEpochMs = const Value.absent(),
                Value<int?> lastInteractionAtEpochMs = const Value.absent(),
                Value<int> sortEpochMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AegisPeopleEntriesCompanion.insert(
                bucket: bucket,
                personId: personId,
                payloadJson: payloadJson,
                displayName: displayName,
                username: username,
                remoteUserId: remoteUserId,
                isTwoSpaceUser: isTwoSpaceUser,
                isDeviceContact: isDeviceContact,
                isFavorite: isFavorite,
                isOnline: isOnline,
                presenceStatus: presenceStatus,
                lastSeenAtEpochMs: lastSeenAtEpochMs,
                lastInteractionAtEpochMs: lastInteractionAtEpochMs,
                sortEpochMs: sortEpochMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AegisPeopleEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AegisChatDatabase,
      $AegisPeopleEntriesTable,
      AegisPeopleEntry,
      $$AegisPeopleEntriesTableFilterComposer,
      $$AegisPeopleEntriesTableOrderingComposer,
      $$AegisPeopleEntriesTableAnnotationComposer,
      $$AegisPeopleEntriesTableCreateCompanionBuilder,
      $$AegisPeopleEntriesTableUpdateCompanionBuilder,
      (
        AegisPeopleEntry,
        BaseReferences<
          _$AegisChatDatabase,
          $AegisPeopleEntriesTable,
          AegisPeopleEntry
        >,
      ),
      AegisPeopleEntry,
      PrefetchHooks Function()
    >;
typedef $$AegisPeopleCallHistoryTableCreateCompanionBuilder =
    AegisPeopleCallHistoryCompanion Function({
      required String id,
      required String personId,
      required String payloadJson,
      required int startedAtEpochMs,
      Value<int> durationMs,
      Value<bool> isVideo,
      required String direction,
      required String outcome,
      Value<int> rowid,
    });
typedef $$AegisPeopleCallHistoryTableUpdateCompanionBuilder =
    AegisPeopleCallHistoryCompanion Function({
      Value<String> id,
      Value<String> personId,
      Value<String> payloadJson,
      Value<int> startedAtEpochMs,
      Value<int> durationMs,
      Value<bool> isVideo,
      Value<String> direction,
      Value<String> outcome,
      Value<int> rowid,
    });

class $$AegisPeopleCallHistoryTableFilterComposer
    extends Composer<_$AegisChatDatabase, $AegisPeopleCallHistoryTable> {
  $$AegisPeopleCallHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAtEpochMs => $composableBuilder(
    column: $table.startedAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isVideo => $composableBuilder(
    column: $table.isVideo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AegisPeopleCallHistoryTableOrderingComposer
    extends Composer<_$AegisChatDatabase, $AegisPeopleCallHistoryTable> {
  $$AegisPeopleCallHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAtEpochMs => $composableBuilder(
    column: $table.startedAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isVideo => $composableBuilder(
    column: $table.isVideo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AegisPeopleCallHistoryTableAnnotationComposer
    extends Composer<_$AegisChatDatabase, $AegisPeopleCallHistoryTable> {
  $$AegisPeopleCallHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get personId =>
      $composableBuilder(column: $table.personId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startedAtEpochMs => $composableBuilder(
    column: $table.startedAtEpochMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isVideo =>
      $composableBuilder(column: $table.isVideo, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);
}

class $$AegisPeopleCallHistoryTableTableManager
    extends
        RootTableManager<
          _$AegisChatDatabase,
          $AegisPeopleCallHistoryTable,
          AegisPeopleCallHistoryData,
          $$AegisPeopleCallHistoryTableFilterComposer,
          $$AegisPeopleCallHistoryTableOrderingComposer,
          $$AegisPeopleCallHistoryTableAnnotationComposer,
          $$AegisPeopleCallHistoryTableCreateCompanionBuilder,
          $$AegisPeopleCallHistoryTableUpdateCompanionBuilder,
          (
            AegisPeopleCallHistoryData,
            BaseReferences<
              _$AegisChatDatabase,
              $AegisPeopleCallHistoryTable,
              AegisPeopleCallHistoryData
            >,
          ),
          AegisPeopleCallHistoryData,
          PrefetchHooks Function()
        > {
  $$AegisPeopleCallHistoryTableTableManager(
    _$AegisChatDatabase db,
    $AegisPeopleCallHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AegisPeopleCallHistoryTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$AegisPeopleCallHistoryTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AegisPeopleCallHistoryTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> personId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> startedAtEpochMs = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<bool> isVideo = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<String> outcome = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AegisPeopleCallHistoryCompanion(
                id: id,
                personId: personId,
                payloadJson: payloadJson,
                startedAtEpochMs: startedAtEpochMs,
                durationMs: durationMs,
                isVideo: isVideo,
                direction: direction,
                outcome: outcome,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String personId,
                required String payloadJson,
                required int startedAtEpochMs,
                Value<int> durationMs = const Value.absent(),
                Value<bool> isVideo = const Value.absent(),
                required String direction,
                required String outcome,
                Value<int> rowid = const Value.absent(),
              }) => AegisPeopleCallHistoryCompanion.insert(
                id: id,
                personId: personId,
                payloadJson: payloadJson,
                startedAtEpochMs: startedAtEpochMs,
                durationMs: durationMs,
                isVideo: isVideo,
                direction: direction,
                outcome: outcome,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AegisPeopleCallHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AegisChatDatabase,
      $AegisPeopleCallHistoryTable,
      AegisPeopleCallHistoryData,
      $$AegisPeopleCallHistoryTableFilterComposer,
      $$AegisPeopleCallHistoryTableOrderingComposer,
      $$AegisPeopleCallHistoryTableAnnotationComposer,
      $$AegisPeopleCallHistoryTableCreateCompanionBuilder,
      $$AegisPeopleCallHistoryTableUpdateCompanionBuilder,
      (
        AegisPeopleCallHistoryData,
        BaseReferences<
          _$AegisChatDatabase,
          $AegisPeopleCallHistoryTable,
          AegisPeopleCallHistoryData
        >,
      ),
      AegisPeopleCallHistoryData,
      PrefetchHooks Function()
    >;

class $AegisChatDatabaseManager {
  final _$AegisChatDatabase _db;
  $AegisChatDatabaseManager(this._db);
  $$AegisConversationsTableTableManager get aegisConversations =>
      $$AegisConversationsTableTableManager(_db, _db.aegisConversations);
  $$AegisMessagesTableTableManager get aegisMessages =>
      $$AegisMessagesTableTableManager(_db, _db.aegisMessages);
  $$AegisProfilesTableTableManager get aegisProfiles =>
      $$AegisProfilesTableTableManager(_db, _db.aegisProfiles);
  $$AegisMetadataTableTableManager get aegisMetadata =>
      $$AegisMetadataTableTableManager(_db, _db.aegisMetadata);
  $$AegisOfflineQueueTableTableManager get aegisOfflineQueue =>
      $$AegisOfflineQueueTableTableManager(_db, _db.aegisOfflineQueue);
  $$AegisPeopleFavoritesTableTableManager get aegisPeopleFavorites =>
      $$AegisPeopleFavoritesTableTableManager(_db, _db.aegisPeopleFavorites);
  $$AegisPeopleEntriesTableTableManager get aegisPeopleEntries =>
      $$AegisPeopleEntriesTableTableManager(_db, _db.aegisPeopleEntries);
  $$AegisPeopleCallHistoryTableTableManager get aegisPeopleCallHistory =>
      $$AegisPeopleCallHistoryTableTableManager(
        _db,
        _db.aegisPeopleCallHistory,
      );
}
