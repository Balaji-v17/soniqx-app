// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
mixin _$SongsDaoMixin on DatabaseAccessor<AppDatabase> {
  $SongsTable get songs => attachedDatabase.songs;
  $SongStatsTable get songStats => attachedDatabase.songStats;
  SongsDaoManager get managers => SongsDaoManager(this);
}

class SongsDaoManager {
  final _$SongsDaoMixin _db;
  SongsDaoManager(this._db);
  $$SongsTableTableManager get songs =>
      $$SongsTableTableManager(_db.attachedDatabase, _db.songs);
  $$SongStatsTableTableManager get songStats =>
      $$SongStatsTableTableManager(_db.attachedDatabase, _db.songStats);
}

mixin _$PlaylistsDaoMixin on DatabaseAccessor<AppDatabase> {
  $PlaylistsTable get playlists => attachedDatabase.playlists;
  $SongsTable get songs => attachedDatabase.songs;
  $PlaylistEntriesTable get playlistEntries => attachedDatabase.playlistEntries;
  PlaylistsDaoManager get managers => PlaylistsDaoManager(this);
}

class PlaylistsDaoManager {
  final _$PlaylistsDaoMixin _db;
  PlaylistsDaoManager(this._db);
  $$PlaylistsTableTableManager get playlists =>
      $$PlaylistsTableTableManager(_db.attachedDatabase, _db.playlists);
  $$SongsTableTableManager get songs =>
      $$SongsTableTableManager(_db.attachedDatabase, _db.songs);
  $$PlaylistEntriesTableTableManager get playlistEntries =>
      $$PlaylistEntriesTableTableManager(
        _db.attachedDatabase,
        _db.playlistEntries,
      );
}

mixin _$HistoryDaoMixin on DatabaseAccessor<AppDatabase> {
  $SongsTable get songs => attachedDatabase.songs;
  $PlayHistoryTable get playHistory => attachedDatabase.playHistory;
  $SongStatsTable get songStats => attachedDatabase.songStats;
  $PlaylistsTable get playlists => attachedDatabase.playlists;
  $PlaylistEntriesTable get playlistEntries => attachedDatabase.playlistEntries;
  HistoryDaoManager get managers => HistoryDaoManager(this);
}

class HistoryDaoManager {
  final _$HistoryDaoMixin _db;
  HistoryDaoManager(this._db);
  $$SongsTableTableManager get songs =>
      $$SongsTableTableManager(_db.attachedDatabase, _db.songs);
  $$PlayHistoryTableTableManager get playHistory =>
      $$PlayHistoryTableTableManager(_db.attachedDatabase, _db.playHistory);
  $$SongStatsTableTableManager get songStats =>
      $$SongStatsTableTableManager(_db.attachedDatabase, _db.songStats);
  $$PlaylistsTableTableManager get playlists =>
      $$PlaylistsTableTableManager(_db.attachedDatabase, _db.playlists);
  $$PlaylistEntriesTableTableManager get playlistEntries =>
      $$PlaylistEntriesTableTableManager(
        _db.attachedDatabase,
        _db.playlistEntries,
      );
}

mixin _$LanguageDaoMixin on DatabaseAccessor<AppDatabase> {
  $LanguageTagsTable get languageTags => attachedDatabase.languageTags;
  $UserCorrectionsTable get userCorrections => attachedDatabase.userCorrections;
  LanguageDaoManager get managers => LanguageDaoManager(this);
}

class LanguageDaoManager {
  final _$LanguageDaoMixin _db;
  LanguageDaoManager(this._db);
  $$LanguageTagsTableTableManager get languageTags =>
      $$LanguageTagsTableTableManager(_db.attachedDatabase, _db.languageTags);
  $$UserCorrectionsTableTableManager get userCorrections =>
      $$UserCorrectionsTableTableManager(
        _db.attachedDatabase,
        _db.userCorrections,
      );
}

mixin _$SettingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $AppSettingsTable get appSettings => attachedDatabase.appSettings;
  $QueueStateTable get queueState => attachedDatabase.queueState;
  SettingsDaoManager get managers => SettingsDaoManager(this);
}

class SettingsDaoManager {
  final _$SettingsDaoMixin _db;
  SettingsDaoManager(this._db);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db.attachedDatabase, _db.appSettings);
  $$QueueStateTableTableManager get queueState =>
      $$QueueStateTableTableManager(_db.attachedDatabase, _db.queueState);
}

class $SongsTable extends Songs with TableInfo<$SongsTable, Song> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumArtistMeta = const VerificationMeta(
    'albumArtist',
  );
  @override
  late final GeneratedColumn<String> albumArtist = GeneratedColumn<String>(
    'album_artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trackNumberMeta = const VerificationMeta(
    'trackNumber',
  );
  @override
  late final GeneratedColumn<int> trackNumber = GeneratedColumn<int>(
    'track_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _discNumberMeta = const VerificationMeta(
    'discNumber',
  );
  @override
  late final GeneratedColumn<int> discNumber = GeneratedColumn<int>(
    'disc_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
    'genre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _albumIdMeta = const VerificationMeta(
    'albumId',
  );
  @override
  late final GeneratedColumn<int> albumId = GeneratedColumn<int>(
    'album_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateAddedMeta = const VerificationMeta(
    'dateAdded',
  );
  @override
  late final GeneratedColumn<int> dateAdded = GeneratedColumn<int>(
    'date_added',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileHashMeta = const VerificationMeta(
    'fileHash',
  );
  @override
  late final GeneratedColumn<String> fileHash = GeneratedColumn<String>(
    'file_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isAvailableMeta = const VerificationMeta(
    'isAvailable',
  );
  @override
  late final GeneratedColumn<bool> isAvailable = GeneratedColumn<bool>(
    'is_available',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_available" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _languageTagMeta = const VerificationMeta(
    'languageTag',
  );
  @override
  late final GeneratedColumn<String> languageTag = GeneratedColumn<String>(
    'language_tag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _classifierConfidenceMeta =
      const VerificationMeta('classifierConfidence');
  @override
  late final GeneratedColumn<double> classifierConfidence =
      GeneratedColumn<double>(
        'classifier_confidence',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _wasManuallyTaggedMeta = const VerificationMeta(
    'wasManuallyTagged',
  );
  @override
  late final GeneratedColumn<bool> wasManuallyTagged = GeneratedColumn<bool>(
    'was_manually_tagged',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("was_manually_tagged" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dateScannedMeta = const VerificationMeta(
    'dateScanned',
  );
  @override
  late final GeneratedColumn<int> dateScanned = GeneratedColumn<int>(
    'date_scanned',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    artist,
    album,
    albumArtist,
    durationMs,
    trackNumber,
    discNumber,
    year,
    genre,
    path,
    albumId,
    dateAdded,
    fileHash,
    isAvailable,
    languageTag,
    classifierConfidence,
    wasManuallyTagged,
    dateScanned,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'songs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Song> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    }
    if (data.containsKey('album_artist')) {
      context.handle(
        _albumArtistMeta,
        albumArtist.isAcceptableOrUnknown(
          data['album_artist']!,
          _albumArtistMeta,
        ),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('track_number')) {
      context.handle(
        _trackNumberMeta,
        trackNumber.isAcceptableOrUnknown(
          data['track_number']!,
          _trackNumberMeta,
        ),
      );
    }
    if (data.containsKey('disc_number')) {
      context.handle(
        _discNumberMeta,
        discNumber.isAcceptableOrUnknown(data['disc_number']!, _discNumberMeta),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('album_id')) {
      context.handle(
        _albumIdMeta,
        albumId.isAcceptableOrUnknown(data['album_id']!, _albumIdMeta),
      );
    } else if (isInserting) {
      context.missing(_albumIdMeta);
    }
    if (data.containsKey('date_added')) {
      context.handle(
        _dateAddedMeta,
        dateAdded.isAcceptableOrUnknown(data['date_added']!, _dateAddedMeta),
      );
    } else if (isInserting) {
      context.missing(_dateAddedMeta);
    }
    if (data.containsKey('file_hash')) {
      context.handle(
        _fileHashMeta,
        fileHash.isAcceptableOrUnknown(data['file_hash']!, _fileHashMeta),
      );
    }
    if (data.containsKey('is_available')) {
      context.handle(
        _isAvailableMeta,
        isAvailable.isAcceptableOrUnknown(
          data['is_available']!,
          _isAvailableMeta,
        ),
      );
    }
    if (data.containsKey('language_tag')) {
      context.handle(
        _languageTagMeta,
        languageTag.isAcceptableOrUnknown(
          data['language_tag']!,
          _languageTagMeta,
        ),
      );
    }
    if (data.containsKey('classifier_confidence')) {
      context.handle(
        _classifierConfidenceMeta,
        classifierConfidence.isAcceptableOrUnknown(
          data['classifier_confidence']!,
          _classifierConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('was_manually_tagged')) {
      context.handle(
        _wasManuallyTaggedMeta,
        wasManuallyTagged.isAcceptableOrUnknown(
          data['was_manually_tagged']!,
          _wasManuallyTaggedMeta,
        ),
      );
    }
    if (data.containsKey('date_scanned')) {
      context.handle(
        _dateScannedMeta,
        dateScanned.isAcceptableOrUnknown(
          data['date_scanned']!,
          _dateScannedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Song map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Song(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      ),
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      ),
      albumArtist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_artist'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      trackNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_number'],
      ),
      discNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}disc_number'],
      ),
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      ),
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      albumId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}album_id'],
      )!,
      dateAdded: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_added'],
      )!,
      fileHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_hash'],
      ),
      isAvailable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_available'],
      )!,
      languageTag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language_tag'],
      ),
      classifierConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}classifier_confidence'],
      )!,
      wasManuallyTagged: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}was_manually_tagged'],
      )!,
      dateScanned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_scanned'],
      ),
    );
  }

  @override
  $SongsTable createAlias(String alias) {
    return $SongsTable(attachedDatabase, alias);
  }
}

class Song extends DataClass implements Insertable<Song> {
  final int id;
  final String? title;
  final String? artist;
  final String? album;
  final String? albumArtist;
  final int? durationMs;
  final int? trackNumber;
  final int? discNumber;
  final int? year;
  final String? genre;
  final String path;
  final int albumId;
  final int dateAdded;
  final String? fileHash;
  final bool isAvailable;
  final String? languageTag;
  final double classifierConfidence;
  final bool wasManuallyTagged;
  final int? dateScanned;
  const Song({
    required this.id,
    this.title,
    this.artist,
    this.album,
    this.albumArtist,
    this.durationMs,
    this.trackNumber,
    this.discNumber,
    this.year,
    this.genre,
    required this.path,
    required this.albumId,
    required this.dateAdded,
    this.fileHash,
    required this.isAvailable,
    this.languageTag,
    required this.classifierConfidence,
    required this.wasManuallyTagged,
    this.dateScanned,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(artist);
    }
    if (!nullToAbsent || album != null) {
      map['album'] = Variable<String>(album);
    }
    if (!nullToAbsent || albumArtist != null) {
      map['album_artist'] = Variable<String>(albumArtist);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || trackNumber != null) {
      map['track_number'] = Variable<int>(trackNumber);
    }
    if (!nullToAbsent || discNumber != null) {
      map['disc_number'] = Variable<int>(discNumber);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || genre != null) {
      map['genre'] = Variable<String>(genre);
    }
    map['path'] = Variable<String>(path);
    map['album_id'] = Variable<int>(albumId);
    map['date_added'] = Variable<int>(dateAdded);
    if (!nullToAbsent || fileHash != null) {
      map['file_hash'] = Variable<String>(fileHash);
    }
    map['is_available'] = Variable<bool>(isAvailable);
    if (!nullToAbsent || languageTag != null) {
      map['language_tag'] = Variable<String>(languageTag);
    }
    map['classifier_confidence'] = Variable<double>(classifierConfidence);
    map['was_manually_tagged'] = Variable<bool>(wasManuallyTagged);
    if (!nullToAbsent || dateScanned != null) {
      map['date_scanned'] = Variable<int>(dateScanned);
    }
    return map;
  }

  SongsCompanion toCompanion(bool nullToAbsent) {
    return SongsCompanion(
      id: Value(id),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      artist: artist == null && nullToAbsent
          ? const Value.absent()
          : Value(artist),
      album: album == null && nullToAbsent
          ? const Value.absent()
          : Value(album),
      albumArtist: albumArtist == null && nullToAbsent
          ? const Value.absent()
          : Value(albumArtist),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      trackNumber: trackNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(trackNumber),
      discNumber: discNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(discNumber),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      genre: genre == null && nullToAbsent
          ? const Value.absent()
          : Value(genre),
      path: Value(path),
      albumId: Value(albumId),
      dateAdded: Value(dateAdded),
      fileHash: fileHash == null && nullToAbsent
          ? const Value.absent()
          : Value(fileHash),
      isAvailable: Value(isAvailable),
      languageTag: languageTag == null && nullToAbsent
          ? const Value.absent()
          : Value(languageTag),
      classifierConfidence: Value(classifierConfidence),
      wasManuallyTagged: Value(wasManuallyTagged),
      dateScanned: dateScanned == null && nullToAbsent
          ? const Value.absent()
          : Value(dateScanned),
    );
  }

  factory Song.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Song(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String?>(json['title']),
      artist: serializer.fromJson<String?>(json['artist']),
      album: serializer.fromJson<String?>(json['album']),
      albumArtist: serializer.fromJson<String?>(json['albumArtist']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      trackNumber: serializer.fromJson<int?>(json['trackNumber']),
      discNumber: serializer.fromJson<int?>(json['discNumber']),
      year: serializer.fromJson<int?>(json['year']),
      genre: serializer.fromJson<String?>(json['genre']),
      path: serializer.fromJson<String>(json['path']),
      albumId: serializer.fromJson<int>(json['albumId']),
      dateAdded: serializer.fromJson<int>(json['dateAdded']),
      fileHash: serializer.fromJson<String?>(json['fileHash']),
      isAvailable: serializer.fromJson<bool>(json['isAvailable']),
      languageTag: serializer.fromJson<String?>(json['languageTag']),
      classifierConfidence: serializer.fromJson<double>(
        json['classifierConfidence'],
      ),
      wasManuallyTagged: serializer.fromJson<bool>(json['wasManuallyTagged']),
      dateScanned: serializer.fromJson<int?>(json['dateScanned']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String?>(title),
      'artist': serializer.toJson<String?>(artist),
      'album': serializer.toJson<String?>(album),
      'albumArtist': serializer.toJson<String?>(albumArtist),
      'durationMs': serializer.toJson<int?>(durationMs),
      'trackNumber': serializer.toJson<int?>(trackNumber),
      'discNumber': serializer.toJson<int?>(discNumber),
      'year': serializer.toJson<int?>(year),
      'genre': serializer.toJson<String?>(genre),
      'path': serializer.toJson<String>(path),
      'albumId': serializer.toJson<int>(albumId),
      'dateAdded': serializer.toJson<int>(dateAdded),
      'fileHash': serializer.toJson<String?>(fileHash),
      'isAvailable': serializer.toJson<bool>(isAvailable),
      'languageTag': serializer.toJson<String?>(languageTag),
      'classifierConfidence': serializer.toJson<double>(classifierConfidence),
      'wasManuallyTagged': serializer.toJson<bool>(wasManuallyTagged),
      'dateScanned': serializer.toJson<int?>(dateScanned),
    };
  }

  Song copyWith({
    int? id,
    Value<String?> title = const Value.absent(),
    Value<String?> artist = const Value.absent(),
    Value<String?> album = const Value.absent(),
    Value<String?> albumArtist = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    Value<int?> trackNumber = const Value.absent(),
    Value<int?> discNumber = const Value.absent(),
    Value<int?> year = const Value.absent(),
    Value<String?> genre = const Value.absent(),
    String? path,
    int? albumId,
    int? dateAdded,
    Value<String?> fileHash = const Value.absent(),
    bool? isAvailable,
    Value<String?> languageTag = const Value.absent(),
    double? classifierConfidence,
    bool? wasManuallyTagged,
    Value<int?> dateScanned = const Value.absent(),
  }) => Song(
    id: id ?? this.id,
    title: title.present ? title.value : this.title,
    artist: artist.present ? artist.value : this.artist,
    album: album.present ? album.value : this.album,
    albumArtist: albumArtist.present ? albumArtist.value : this.albumArtist,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    trackNumber: trackNumber.present ? trackNumber.value : this.trackNumber,
    discNumber: discNumber.present ? discNumber.value : this.discNumber,
    year: year.present ? year.value : this.year,
    genre: genre.present ? genre.value : this.genre,
    path: path ?? this.path,
    albumId: albumId ?? this.albumId,
    dateAdded: dateAdded ?? this.dateAdded,
    fileHash: fileHash.present ? fileHash.value : this.fileHash,
    isAvailable: isAvailable ?? this.isAvailable,
    languageTag: languageTag.present ? languageTag.value : this.languageTag,
    classifierConfidence: classifierConfidence ?? this.classifierConfidence,
    wasManuallyTagged: wasManuallyTagged ?? this.wasManuallyTagged,
    dateScanned: dateScanned.present ? dateScanned.value : this.dateScanned,
  );
  Song copyWithCompanion(SongsCompanion data) {
    return Song(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      album: data.album.present ? data.album.value : this.album,
      albumArtist: data.albumArtist.present
          ? data.albumArtist.value
          : this.albumArtist,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      trackNumber: data.trackNumber.present
          ? data.trackNumber.value
          : this.trackNumber,
      discNumber: data.discNumber.present
          ? data.discNumber.value
          : this.discNumber,
      year: data.year.present ? data.year.value : this.year,
      genre: data.genre.present ? data.genre.value : this.genre,
      path: data.path.present ? data.path.value : this.path,
      albumId: data.albumId.present ? data.albumId.value : this.albumId,
      dateAdded: data.dateAdded.present ? data.dateAdded.value : this.dateAdded,
      fileHash: data.fileHash.present ? data.fileHash.value : this.fileHash,
      isAvailable: data.isAvailable.present
          ? data.isAvailable.value
          : this.isAvailable,
      languageTag: data.languageTag.present
          ? data.languageTag.value
          : this.languageTag,
      classifierConfidence: data.classifierConfidence.present
          ? data.classifierConfidence.value
          : this.classifierConfidence,
      wasManuallyTagged: data.wasManuallyTagged.present
          ? data.wasManuallyTagged.value
          : this.wasManuallyTagged,
      dateScanned: data.dateScanned.present
          ? data.dateScanned.value
          : this.dateScanned,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Song(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('albumArtist: $albumArtist, ')
          ..write('durationMs: $durationMs, ')
          ..write('trackNumber: $trackNumber, ')
          ..write('discNumber: $discNumber, ')
          ..write('year: $year, ')
          ..write('genre: $genre, ')
          ..write('path: $path, ')
          ..write('albumId: $albumId, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('fileHash: $fileHash, ')
          ..write('isAvailable: $isAvailable, ')
          ..write('languageTag: $languageTag, ')
          ..write('classifierConfidence: $classifierConfidence, ')
          ..write('wasManuallyTagged: $wasManuallyTagged, ')
          ..write('dateScanned: $dateScanned')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    artist,
    album,
    albumArtist,
    durationMs,
    trackNumber,
    discNumber,
    year,
    genre,
    path,
    albumId,
    dateAdded,
    fileHash,
    isAvailable,
    languageTag,
    classifierConfidence,
    wasManuallyTagged,
    dateScanned,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Song &&
          other.id == this.id &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.album == this.album &&
          other.albumArtist == this.albumArtist &&
          other.durationMs == this.durationMs &&
          other.trackNumber == this.trackNumber &&
          other.discNumber == this.discNumber &&
          other.year == this.year &&
          other.genre == this.genre &&
          other.path == this.path &&
          other.albumId == this.albumId &&
          other.dateAdded == this.dateAdded &&
          other.fileHash == this.fileHash &&
          other.isAvailable == this.isAvailable &&
          other.languageTag == this.languageTag &&
          other.classifierConfidence == this.classifierConfidence &&
          other.wasManuallyTagged == this.wasManuallyTagged &&
          other.dateScanned == this.dateScanned);
}

class SongsCompanion extends UpdateCompanion<Song> {
  final Value<int> id;
  final Value<String?> title;
  final Value<String?> artist;
  final Value<String?> album;
  final Value<String?> albumArtist;
  final Value<int?> durationMs;
  final Value<int?> trackNumber;
  final Value<int?> discNumber;
  final Value<int?> year;
  final Value<String?> genre;
  final Value<String> path;
  final Value<int> albumId;
  final Value<int> dateAdded;
  final Value<String?> fileHash;
  final Value<bool> isAvailable;
  final Value<String?> languageTag;
  final Value<double> classifierConfidence;
  final Value<bool> wasManuallyTagged;
  final Value<int?> dateScanned;
  const SongsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.albumArtist = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.trackNumber = const Value.absent(),
    this.discNumber = const Value.absent(),
    this.year = const Value.absent(),
    this.genre = const Value.absent(),
    this.path = const Value.absent(),
    this.albumId = const Value.absent(),
    this.dateAdded = const Value.absent(),
    this.fileHash = const Value.absent(),
    this.isAvailable = const Value.absent(),
    this.languageTag = const Value.absent(),
    this.classifierConfidence = const Value.absent(),
    this.wasManuallyTagged = const Value.absent(),
    this.dateScanned = const Value.absent(),
  });
  SongsCompanion.insert({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.albumArtist = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.trackNumber = const Value.absent(),
    this.discNumber = const Value.absent(),
    this.year = const Value.absent(),
    this.genre = const Value.absent(),
    required String path,
    required int albumId,
    required int dateAdded,
    this.fileHash = const Value.absent(),
    this.isAvailable = const Value.absent(),
    this.languageTag = const Value.absent(),
    this.classifierConfidence = const Value.absent(),
    this.wasManuallyTagged = const Value.absent(),
    this.dateScanned = const Value.absent(),
  }) : path = Value(path),
       albumId = Value(albumId),
       dateAdded = Value(dateAdded);
  static Insertable<Song> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? album,
    Expression<String>? albumArtist,
    Expression<int>? durationMs,
    Expression<int>? trackNumber,
    Expression<int>? discNumber,
    Expression<int>? year,
    Expression<String>? genre,
    Expression<String>? path,
    Expression<int>? albumId,
    Expression<int>? dateAdded,
    Expression<String>? fileHash,
    Expression<bool>? isAvailable,
    Expression<String>? languageTag,
    Expression<double>? classifierConfidence,
    Expression<bool>? wasManuallyTagged,
    Expression<int>? dateScanned,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
      if (albumArtist != null) 'album_artist': albumArtist,
      if (durationMs != null) 'duration_ms': durationMs,
      if (trackNumber != null) 'track_number': trackNumber,
      if (discNumber != null) 'disc_number': discNumber,
      if (year != null) 'year': year,
      if (genre != null) 'genre': genre,
      if (path != null) 'path': path,
      if (albumId != null) 'album_id': albumId,
      if (dateAdded != null) 'date_added': dateAdded,
      if (fileHash != null) 'file_hash': fileHash,
      if (isAvailable != null) 'is_available': isAvailable,
      if (languageTag != null) 'language_tag': languageTag,
      if (classifierConfidence != null)
        'classifier_confidence': classifierConfidence,
      if (wasManuallyTagged != null) 'was_manually_tagged': wasManuallyTagged,
      if (dateScanned != null) 'date_scanned': dateScanned,
    });
  }

  SongsCompanion copyWith({
    Value<int>? id,
    Value<String?>? title,
    Value<String?>? artist,
    Value<String?>? album,
    Value<String?>? albumArtist,
    Value<int?>? durationMs,
    Value<int?>? trackNumber,
    Value<int?>? discNumber,
    Value<int?>? year,
    Value<String?>? genre,
    Value<String>? path,
    Value<int>? albumId,
    Value<int>? dateAdded,
    Value<String?>? fileHash,
    Value<bool>? isAvailable,
    Value<String?>? languageTag,
    Value<double>? classifierConfidence,
    Value<bool>? wasManuallyTagged,
    Value<int?>? dateScanned,
  }) {
    return SongsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumArtist: albumArtist ?? this.albumArtist,
      durationMs: durationMs ?? this.durationMs,
      trackNumber: trackNumber ?? this.trackNumber,
      discNumber: discNumber ?? this.discNumber,
      year: year ?? this.year,
      genre: genre ?? this.genre,
      path: path ?? this.path,
      albumId: albumId ?? this.albumId,
      dateAdded: dateAdded ?? this.dateAdded,
      fileHash: fileHash ?? this.fileHash,
      isAvailable: isAvailable ?? this.isAvailable,
      languageTag: languageTag ?? this.languageTag,
      classifierConfidence: classifierConfidence ?? this.classifierConfidence,
      wasManuallyTagged: wasManuallyTagged ?? this.wasManuallyTagged,
      dateScanned: dateScanned ?? this.dateScanned,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (albumArtist.present) {
      map['album_artist'] = Variable<String>(albumArtist.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (trackNumber.present) {
      map['track_number'] = Variable<int>(trackNumber.value);
    }
    if (discNumber.present) {
      map['disc_number'] = Variable<int>(discNumber.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (albumId.present) {
      map['album_id'] = Variable<int>(albumId.value);
    }
    if (dateAdded.present) {
      map['date_added'] = Variable<int>(dateAdded.value);
    }
    if (fileHash.present) {
      map['file_hash'] = Variable<String>(fileHash.value);
    }
    if (isAvailable.present) {
      map['is_available'] = Variable<bool>(isAvailable.value);
    }
    if (languageTag.present) {
      map['language_tag'] = Variable<String>(languageTag.value);
    }
    if (classifierConfidence.present) {
      map['classifier_confidence'] = Variable<double>(
        classifierConfidence.value,
      );
    }
    if (wasManuallyTagged.present) {
      map['was_manually_tagged'] = Variable<bool>(wasManuallyTagged.value);
    }
    if (dateScanned.present) {
      map['date_scanned'] = Variable<int>(dateScanned.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('albumArtist: $albumArtist, ')
          ..write('durationMs: $durationMs, ')
          ..write('trackNumber: $trackNumber, ')
          ..write('discNumber: $discNumber, ')
          ..write('year: $year, ')
          ..write('genre: $genre, ')
          ..write('path: $path, ')
          ..write('albumId: $albumId, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('fileHash: $fileHash, ')
          ..write('isAvailable: $isAvailable, ')
          ..write('languageTag: $languageTag, ')
          ..write('classifierConfidence: $classifierConfidence, ')
          ..write('wasManuallyTagged: $wasManuallyTagged, ')
          ..write('dateScanned: $dateScanned')
          ..write(')'))
        .toString();
  }
}

class $PlaylistsTable extends Playlists
    with TableInfo<$PlaylistsTable, Playlist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _systemTypeMeta = const VerificationMeta(
    'systemType',
  );
  @override
  late final GeneratedColumn<String> systemType = GeneratedColumn<String>(
    'system_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    createdAt,
    updatedAt,
    isSystem,
    systemType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlists';
  @override
  VerificationContext validateIntegrity(
    Insertable<Playlist> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    if (data.containsKey('system_type')) {
      context.handle(
        _systemTypeMeta,
        systemType.isAcceptableOrUnknown(data['system_type']!, _systemTypeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Playlist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Playlist(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
      systemType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system_type'],
      ),
    );
  }

  @override
  $PlaylistsTable createAlias(String alias) {
    return $PlaylistsTable(attachedDatabase, alias);
  }
}

class Playlist extends DataClass implements Insertable<Playlist> {
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSystem;
  final String? systemType;
  const Playlist({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.isSystem,
    this.systemType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_system'] = Variable<bool>(isSystem);
    if (!nullToAbsent || systemType != null) {
      map['system_type'] = Variable<String>(systemType);
    }
    return map;
  }

  PlaylistsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isSystem: Value(isSystem),
      systemType: systemType == null && nullToAbsent
          ? const Value.absent()
          : Value(systemType),
    );
  }

  factory Playlist.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Playlist(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      systemType: serializer.fromJson<String?>(json['systemType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isSystem': serializer.toJson<bool>(isSystem),
      'systemType': serializer.toJson<String?>(systemType),
    };
  }

  Playlist copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSystem,
    Value<String?> systemType = const Value.absent(),
  }) => Playlist(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isSystem: isSystem ?? this.isSystem,
    systemType: systemType.present ? systemType.value : this.systemType,
  );
  Playlist copyWithCompanion(PlaylistsCompanion data) {
    return Playlist(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      systemType: data.systemType.present
          ? data.systemType.value
          : this.systemType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Playlist(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSystem: $isSystem, ')
          ..write('systemType: $systemType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, createdAt, updatedAt, isSystem, systemType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Playlist &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSystem == this.isSystem &&
          other.systemType == this.systemType);
}

class PlaylistsCompanion extends UpdateCompanion<Playlist> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isSystem;
  final Value<String?> systemType;
  const PlaylistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.systemType = const Value.absent(),
  });
  PlaylistsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.systemType = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Playlist> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSystem,
    Expression<String>? systemType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSystem != null) 'is_system': isSystem,
      if (systemType != null) 'system_type': systemType,
    });
  }

  PlaylistsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isSystem,
    Value<String?>? systemType,
  }) {
    return PlaylistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSystem: isSystem ?? this.isSystem,
      systemType: systemType ?? this.systemType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (systemType.present) {
      map['system_type'] = Variable<String>(systemType.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSystem: $isSystem, ')
          ..write('systemType: $systemType')
          ..write(')'))
        .toString();
  }
}

class $PlaylistEntriesTable extends PlaylistEntries
    with TableInfo<$PlaylistEntriesTable, PlaylistEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<int> playlistId = GeneratedColumn<int>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES playlists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<int> songId = GeneratedColumn<int>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES songs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    playlistId,
    songId,
    position,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}playlist_id'],
      )!,
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}song_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $PlaylistEntriesTable createAlias(String alias) {
    return $PlaylistEntriesTable(attachedDatabase, alias);
  }
}

class PlaylistEntry extends DataClass implements Insertable<PlaylistEntry> {
  final int id;
  final int playlistId;
  final int songId;
  final int position;
  final DateTime addedAt;
  const PlaylistEntry({
    required this.id,
    required this.playlistId,
    required this.songId,
    required this.position,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['playlist_id'] = Variable<int>(playlistId);
    map['song_id'] = Variable<int>(songId);
    map['position'] = Variable<int>(position);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  PlaylistEntriesCompanion toCompanion(bool nullToAbsent) {
    return PlaylistEntriesCompanion(
      id: Value(id),
      playlistId: Value(playlistId),
      songId: Value(songId),
      position: Value(position),
      addedAt: Value(addedAt),
    );
  }

  factory PlaylistEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistEntry(
      id: serializer.fromJson<int>(json['id']),
      playlistId: serializer.fromJson<int>(json['playlistId']),
      songId: serializer.fromJson<int>(json['songId']),
      position: serializer.fromJson<int>(json['position']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'playlistId': serializer.toJson<int>(playlistId),
      'songId': serializer.toJson<int>(songId),
      'position': serializer.toJson<int>(position),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  PlaylistEntry copyWith({
    int? id,
    int? playlistId,
    int? songId,
    int? position,
    DateTime? addedAt,
  }) => PlaylistEntry(
    id: id ?? this.id,
    playlistId: playlistId ?? this.playlistId,
    songId: songId ?? this.songId,
    position: position ?? this.position,
    addedAt: addedAt ?? this.addedAt,
  );
  PlaylistEntry copyWithCompanion(PlaylistEntriesCompanion data) {
    return PlaylistEntry(
      id: data.id.present ? data.id.value : this.id,
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      songId: data.songId.present ? data.songId.value : this.songId,
      position: data.position.present ? data.position.value : this.position,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistEntry(')
          ..write('id: $id, ')
          ..write('playlistId: $playlistId, ')
          ..write('songId: $songId, ')
          ..write('position: $position, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, playlistId, songId, position, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistEntry &&
          other.id == this.id &&
          other.playlistId == this.playlistId &&
          other.songId == this.songId &&
          other.position == this.position &&
          other.addedAt == this.addedAt);
}

class PlaylistEntriesCompanion extends UpdateCompanion<PlaylistEntry> {
  final Value<int> id;
  final Value<int> playlistId;
  final Value<int> songId;
  final Value<int> position;
  final Value<DateTime> addedAt;
  const PlaylistEntriesCompanion({
    this.id = const Value.absent(),
    this.playlistId = const Value.absent(),
    this.songId = const Value.absent(),
    this.position = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  PlaylistEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int playlistId,
    required int songId,
    required int position,
    this.addedAt = const Value.absent(),
  }) : playlistId = Value(playlistId),
       songId = Value(songId),
       position = Value(position);
  static Insertable<PlaylistEntry> custom({
    Expression<int>? id,
    Expression<int>? playlistId,
    Expression<int>? songId,
    Expression<int>? position,
    Expression<DateTime>? addedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (playlistId != null) 'playlist_id': playlistId,
      if (songId != null) 'song_id': songId,
      if (position != null) 'position': position,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  PlaylistEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? playlistId,
    Value<int>? songId,
    Value<int>? position,
    Value<DateTime>? addedAt,
  }) {
    return PlaylistEntriesCompanion(
      id: id ?? this.id,
      playlistId: playlistId ?? this.playlistId,
      songId: songId ?? this.songId,
      position: position ?? this.position,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (playlistId.present) {
      map['playlist_id'] = Variable<int>(playlistId.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<int>(songId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistEntriesCompanion(')
          ..write('id: $id, ')
          ..write('playlistId: $playlistId, ')
          ..write('songId: $songId, ')
          ..write('position: $position, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

class $PlayHistoryTable extends PlayHistory
    with TableInfo<$PlayHistoryTable, PlayHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayHistoryTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<int> songId = GeneratedColumn<int>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES songs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _playedAtMeta = const VerificationMeta(
    'playedAt',
  );
  @override
  late final GeneratedColumn<DateTime> playedAt = GeneratedColumn<DateTime>(
    'played_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _listenedMsMeta = const VerificationMeta(
    'listenedMs',
  );
  @override
  late final GeneratedColumn<int> listenedMs = GeneratedColumn<int>(
    'listened_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _countedMeta = const VerificationMeta(
    'counted',
  );
  @override
  late final GeneratedColumn<bool> counted = GeneratedColumn<bool>(
    'counted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("counted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _skippedEarlyMeta = const VerificationMeta(
    'skippedEarly',
  );
  @override
  late final GeneratedColumn<bool> skippedEarly = GeneratedColumn<bool>(
    'skipped_early',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("skipped_early" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    songId,
    playedAt,
    listenedMs,
    counted,
    skippedEarly,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'play_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlayHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('played_at')) {
      context.handle(
        _playedAtMeta,
        playedAt.isAcceptableOrUnknown(data['played_at']!, _playedAtMeta),
      );
    }
    if (data.containsKey('listened_ms')) {
      context.handle(
        _listenedMsMeta,
        listenedMs.isAcceptableOrUnknown(data['listened_ms']!, _listenedMsMeta),
      );
    }
    if (data.containsKey('counted')) {
      context.handle(
        _countedMeta,
        counted.isAcceptableOrUnknown(data['counted']!, _countedMeta),
      );
    }
    if (data.containsKey('skipped_early')) {
      context.handle(
        _skippedEarlyMeta,
        skippedEarly.isAcceptableOrUnknown(
          data['skipped_early']!,
          _skippedEarlyMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}song_id'],
      )!,
      playedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}played_at'],
      )!,
      listenedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}listened_ms'],
      )!,
      counted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}counted'],
      )!,
      skippedEarly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}skipped_early'],
      )!,
    );
  }

  @override
  $PlayHistoryTable createAlias(String alias) {
    return $PlayHistoryTable(attachedDatabase, alias);
  }
}

class PlayHistoryData extends DataClass implements Insertable<PlayHistoryData> {
  final int id;
  final int songId;
  final DateTime playedAt;
  final int listenedMs;
  final bool counted;
  final bool skippedEarly;
  const PlayHistoryData({
    required this.id,
    required this.songId,
    required this.playedAt,
    required this.listenedMs,
    required this.counted,
    required this.skippedEarly,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['song_id'] = Variable<int>(songId);
    map['played_at'] = Variable<DateTime>(playedAt);
    map['listened_ms'] = Variable<int>(listenedMs);
    map['counted'] = Variable<bool>(counted);
    map['skipped_early'] = Variable<bool>(skippedEarly);
    return map;
  }

  PlayHistoryCompanion toCompanion(bool nullToAbsent) {
    return PlayHistoryCompanion(
      id: Value(id),
      songId: Value(songId),
      playedAt: Value(playedAt),
      listenedMs: Value(listenedMs),
      counted: Value(counted),
      skippedEarly: Value(skippedEarly),
    );
  }

  factory PlayHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayHistoryData(
      id: serializer.fromJson<int>(json['id']),
      songId: serializer.fromJson<int>(json['songId']),
      playedAt: serializer.fromJson<DateTime>(json['playedAt']),
      listenedMs: serializer.fromJson<int>(json['listenedMs']),
      counted: serializer.fromJson<bool>(json['counted']),
      skippedEarly: serializer.fromJson<bool>(json['skippedEarly']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'songId': serializer.toJson<int>(songId),
      'playedAt': serializer.toJson<DateTime>(playedAt),
      'listenedMs': serializer.toJson<int>(listenedMs),
      'counted': serializer.toJson<bool>(counted),
      'skippedEarly': serializer.toJson<bool>(skippedEarly),
    };
  }

  PlayHistoryData copyWith({
    int? id,
    int? songId,
    DateTime? playedAt,
    int? listenedMs,
    bool? counted,
    bool? skippedEarly,
  }) => PlayHistoryData(
    id: id ?? this.id,
    songId: songId ?? this.songId,
    playedAt: playedAt ?? this.playedAt,
    listenedMs: listenedMs ?? this.listenedMs,
    counted: counted ?? this.counted,
    skippedEarly: skippedEarly ?? this.skippedEarly,
  );
  PlayHistoryData copyWithCompanion(PlayHistoryCompanion data) {
    return PlayHistoryData(
      id: data.id.present ? data.id.value : this.id,
      songId: data.songId.present ? data.songId.value : this.songId,
      playedAt: data.playedAt.present ? data.playedAt.value : this.playedAt,
      listenedMs: data.listenedMs.present
          ? data.listenedMs.value
          : this.listenedMs,
      counted: data.counted.present ? data.counted.value : this.counted,
      skippedEarly: data.skippedEarly.present
          ? data.skippedEarly.value
          : this.skippedEarly,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayHistoryData(')
          ..write('id: $id, ')
          ..write('songId: $songId, ')
          ..write('playedAt: $playedAt, ')
          ..write('listenedMs: $listenedMs, ')
          ..write('counted: $counted, ')
          ..write('skippedEarly: $skippedEarly')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, songId, playedAt, listenedMs, counted, skippedEarly);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayHistoryData &&
          other.id == this.id &&
          other.songId == this.songId &&
          other.playedAt == this.playedAt &&
          other.listenedMs == this.listenedMs &&
          other.counted == this.counted &&
          other.skippedEarly == this.skippedEarly);
}

class PlayHistoryCompanion extends UpdateCompanion<PlayHistoryData> {
  final Value<int> id;
  final Value<int> songId;
  final Value<DateTime> playedAt;
  final Value<int> listenedMs;
  final Value<bool> counted;
  final Value<bool> skippedEarly;
  const PlayHistoryCompanion({
    this.id = const Value.absent(),
    this.songId = const Value.absent(),
    this.playedAt = const Value.absent(),
    this.listenedMs = const Value.absent(),
    this.counted = const Value.absent(),
    this.skippedEarly = const Value.absent(),
  });
  PlayHistoryCompanion.insert({
    this.id = const Value.absent(),
    required int songId,
    this.playedAt = const Value.absent(),
    this.listenedMs = const Value.absent(),
    this.counted = const Value.absent(),
    this.skippedEarly = const Value.absent(),
  }) : songId = Value(songId);
  static Insertable<PlayHistoryData> custom({
    Expression<int>? id,
    Expression<int>? songId,
    Expression<DateTime>? playedAt,
    Expression<int>? listenedMs,
    Expression<bool>? counted,
    Expression<bool>? skippedEarly,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (songId != null) 'song_id': songId,
      if (playedAt != null) 'played_at': playedAt,
      if (listenedMs != null) 'listened_ms': listenedMs,
      if (counted != null) 'counted': counted,
      if (skippedEarly != null) 'skipped_early': skippedEarly,
    });
  }

  PlayHistoryCompanion copyWith({
    Value<int>? id,
    Value<int>? songId,
    Value<DateTime>? playedAt,
    Value<int>? listenedMs,
    Value<bool>? counted,
    Value<bool>? skippedEarly,
  }) {
    return PlayHistoryCompanion(
      id: id ?? this.id,
      songId: songId ?? this.songId,
      playedAt: playedAt ?? this.playedAt,
      listenedMs: listenedMs ?? this.listenedMs,
      counted: counted ?? this.counted,
      skippedEarly: skippedEarly ?? this.skippedEarly,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<int>(songId.value);
    }
    if (playedAt.present) {
      map['played_at'] = Variable<DateTime>(playedAt.value);
    }
    if (listenedMs.present) {
      map['listened_ms'] = Variable<int>(listenedMs.value);
    }
    if (counted.present) {
      map['counted'] = Variable<bool>(counted.value);
    }
    if (skippedEarly.present) {
      map['skipped_early'] = Variable<bool>(skippedEarly.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayHistoryCompanion(')
          ..write('id: $id, ')
          ..write('songId: $songId, ')
          ..write('playedAt: $playedAt, ')
          ..write('listenedMs: $listenedMs, ')
          ..write('counted: $counted, ')
          ..write('skippedEarly: $skippedEarly')
          ..write(')'))
        .toString();
  }
}

class $SongStatsTable extends SongStats
    with TableInfo<$SongStatsTable, SongStat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<int> songId = GeneratedColumn<int>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES songs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _playCountMeta = const VerificationMeta(
    'playCount',
  );
  @override
  late final GeneratedColumn<int> playCount = GeneratedColumn<int>(
    'play_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalListenedMsMeta = const VerificationMeta(
    'totalListenedMs',
  );
  @override
  late final GeneratedColumn<int> totalListenedMs = GeneratedColumn<int>(
    'total_listened_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastPlayedMeta = const VerificationMeta(
    'lastPlayed',
  );
  @override
  late final GeneratedColumn<DateTime> lastPlayed = GeneratedColumn<DateTime>(
    'last_played',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skipCountMeta = const VerificationMeta(
    'skipCount',
  );
  @override
  late final GeneratedColumn<int> skipCount = GeneratedColumn<int>(
    'skip_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    songId,
    playCount,
    totalListenedMs,
    lastPlayed,
    skipCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'song_stats';
  @override
  VerificationContext validateIntegrity(
    Insertable<SongStat> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    }
    if (data.containsKey('play_count')) {
      context.handle(
        _playCountMeta,
        playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta),
      );
    }
    if (data.containsKey('total_listened_ms')) {
      context.handle(
        _totalListenedMsMeta,
        totalListenedMs.isAcceptableOrUnknown(
          data['total_listened_ms']!,
          _totalListenedMsMeta,
        ),
      );
    }
    if (data.containsKey('last_played')) {
      context.handle(
        _lastPlayedMeta,
        lastPlayed.isAcceptableOrUnknown(data['last_played']!, _lastPlayedMeta),
      );
    }
    if (data.containsKey('skip_count')) {
      context.handle(
        _skipCountMeta,
        skipCount.isAcceptableOrUnknown(data['skip_count']!, _skipCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {songId};
  @override
  SongStat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SongStat(
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}song_id'],
      )!,
      playCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_count'],
      )!,
      totalListenedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_listened_ms'],
      )!,
      lastPlayed: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_played'],
      ),
      skipCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skip_count'],
      )!,
    );
  }

  @override
  $SongStatsTable createAlias(String alias) {
    return $SongStatsTable(attachedDatabase, alias);
  }
}

class SongStat extends DataClass implements Insertable<SongStat> {
  final int songId;
  final int playCount;
  final int totalListenedMs;
  final DateTime? lastPlayed;
  final int skipCount;
  const SongStat({
    required this.songId,
    required this.playCount,
    required this.totalListenedMs,
    this.lastPlayed,
    required this.skipCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['song_id'] = Variable<int>(songId);
    map['play_count'] = Variable<int>(playCount);
    map['total_listened_ms'] = Variable<int>(totalListenedMs);
    if (!nullToAbsent || lastPlayed != null) {
      map['last_played'] = Variable<DateTime>(lastPlayed);
    }
    map['skip_count'] = Variable<int>(skipCount);
    return map;
  }

  SongStatsCompanion toCompanion(bool nullToAbsent) {
    return SongStatsCompanion(
      songId: Value(songId),
      playCount: Value(playCount),
      totalListenedMs: Value(totalListenedMs),
      lastPlayed: lastPlayed == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayed),
      skipCount: Value(skipCount),
    );
  }

  factory SongStat.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SongStat(
      songId: serializer.fromJson<int>(json['songId']),
      playCount: serializer.fromJson<int>(json['playCount']),
      totalListenedMs: serializer.fromJson<int>(json['totalListenedMs']),
      lastPlayed: serializer.fromJson<DateTime?>(json['lastPlayed']),
      skipCount: serializer.fromJson<int>(json['skipCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'songId': serializer.toJson<int>(songId),
      'playCount': serializer.toJson<int>(playCount),
      'totalListenedMs': serializer.toJson<int>(totalListenedMs),
      'lastPlayed': serializer.toJson<DateTime?>(lastPlayed),
      'skipCount': serializer.toJson<int>(skipCount),
    };
  }

  SongStat copyWith({
    int? songId,
    int? playCount,
    int? totalListenedMs,
    Value<DateTime?> lastPlayed = const Value.absent(),
    int? skipCount,
  }) => SongStat(
    songId: songId ?? this.songId,
    playCount: playCount ?? this.playCount,
    totalListenedMs: totalListenedMs ?? this.totalListenedMs,
    lastPlayed: lastPlayed.present ? lastPlayed.value : this.lastPlayed,
    skipCount: skipCount ?? this.skipCount,
  );
  SongStat copyWithCompanion(SongStatsCompanion data) {
    return SongStat(
      songId: data.songId.present ? data.songId.value : this.songId,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
      totalListenedMs: data.totalListenedMs.present
          ? data.totalListenedMs.value
          : this.totalListenedMs,
      lastPlayed: data.lastPlayed.present
          ? data.lastPlayed.value
          : this.lastPlayed,
      skipCount: data.skipCount.present ? data.skipCount.value : this.skipCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SongStat(')
          ..write('songId: $songId, ')
          ..write('playCount: $playCount, ')
          ..write('totalListenedMs: $totalListenedMs, ')
          ..write('lastPlayed: $lastPlayed, ')
          ..write('skipCount: $skipCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(songId, playCount, totalListenedMs, lastPlayed, skipCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SongStat &&
          other.songId == this.songId &&
          other.playCount == this.playCount &&
          other.totalListenedMs == this.totalListenedMs &&
          other.lastPlayed == this.lastPlayed &&
          other.skipCount == this.skipCount);
}

class SongStatsCompanion extends UpdateCompanion<SongStat> {
  final Value<int> songId;
  final Value<int> playCount;
  final Value<int> totalListenedMs;
  final Value<DateTime?> lastPlayed;
  final Value<int> skipCount;
  const SongStatsCompanion({
    this.songId = const Value.absent(),
    this.playCount = const Value.absent(),
    this.totalListenedMs = const Value.absent(),
    this.lastPlayed = const Value.absent(),
    this.skipCount = const Value.absent(),
  });
  SongStatsCompanion.insert({
    this.songId = const Value.absent(),
    this.playCount = const Value.absent(),
    this.totalListenedMs = const Value.absent(),
    this.lastPlayed = const Value.absent(),
    this.skipCount = const Value.absent(),
  });
  static Insertable<SongStat> custom({
    Expression<int>? songId,
    Expression<int>? playCount,
    Expression<int>? totalListenedMs,
    Expression<DateTime>? lastPlayed,
    Expression<int>? skipCount,
  }) {
    return RawValuesInsertable({
      if (songId != null) 'song_id': songId,
      if (playCount != null) 'play_count': playCount,
      if (totalListenedMs != null) 'total_listened_ms': totalListenedMs,
      if (lastPlayed != null) 'last_played': lastPlayed,
      if (skipCount != null) 'skip_count': skipCount,
    });
  }

  SongStatsCompanion copyWith({
    Value<int>? songId,
    Value<int>? playCount,
    Value<int>? totalListenedMs,
    Value<DateTime?>? lastPlayed,
    Value<int>? skipCount,
  }) {
    return SongStatsCompanion(
      songId: songId ?? this.songId,
      playCount: playCount ?? this.playCount,
      totalListenedMs: totalListenedMs ?? this.totalListenedMs,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      skipCount: skipCount ?? this.skipCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (songId.present) {
      map['song_id'] = Variable<int>(songId.value);
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    if (totalListenedMs.present) {
      map['total_listened_ms'] = Variable<int>(totalListenedMs.value);
    }
    if (lastPlayed.present) {
      map['last_played'] = Variable<DateTime>(lastPlayed.value);
    }
    if (skipCount.present) {
      map['skip_count'] = Variable<int>(skipCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongStatsCompanion(')
          ..write('songId: $songId, ')
          ..write('playCount: $playCount, ')
          ..write('totalListenedMs: $totalListenedMs, ')
          ..write('lastPlayed: $lastPlayed, ')
          ..write('skipCount: $skipCount')
          ..write(')'))
        .toString();
  }
}

class $LanguageTagsTable extends LanguageTags
    with TableInfo<$LanguageTagsTable, LanguageTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LanguageTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _artistKeyMeta = const VerificationMeta(
    'artistKey',
  );
  @override
  late final GeneratedColumn<String> artistKey = GeneratedColumn<String>(
    'artist_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _primaryLanguageMeta = const VerificationMeta(
    'primaryLanguage',
  );
  @override
  late final GeneratedColumn<String> primaryLanguage = GeneratedColumn<String>(
    'primary_language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languageScoresJsonMeta =
      const VerificationMeta('languageScoresJson');
  @override
  late final GeneratedColumn<String> languageScoresJson =
      GeneratedColumn<String>(
        'language_scores_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.70),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    artistKey,
    primaryLanguage,
    languageScoresJson,
    source,
    confidence,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'language_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<LanguageTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('artist_key')) {
      context.handle(
        _artistKeyMeta,
        artistKey.isAcceptableOrUnknown(data['artist_key']!, _artistKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_artistKeyMeta);
    }
    if (data.containsKey('primary_language')) {
      context.handle(
        _primaryLanguageMeta,
        primaryLanguage.isAcceptableOrUnknown(
          data['primary_language']!,
          _primaryLanguageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_primaryLanguageMeta);
    }
    if (data.containsKey('language_scores_json')) {
      context.handle(
        _languageScoresJsonMeta,
        languageScoresJson.isAcceptableOrUnknown(
          data['language_scores_json']!,
          _languageScoresJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_languageScoresJsonMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {artistKey};
  @override
  LanguageTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LanguageTag(
      artistKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_key'],
      )!,
      primaryLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_language'],
      )!,
      languageScoresJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language_scores_json'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LanguageTagsTable createAlias(String alias) {
    return $LanguageTagsTable(attachedDatabase, alias);
  }
}

class LanguageTag extends DataClass implements Insertable<LanguageTag> {
  final String artistKey;
  final String primaryLanguage;
  final String languageScoresJson;
  final String source;
  final double confidence;
  final DateTime updatedAt;
  const LanguageTag({
    required this.artistKey,
    required this.primaryLanguage,
    required this.languageScoresJson,
    required this.source,
    required this.confidence,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['artist_key'] = Variable<String>(artistKey);
    map['primary_language'] = Variable<String>(primaryLanguage);
    map['language_scores_json'] = Variable<String>(languageScoresJson);
    map['source'] = Variable<String>(source);
    map['confidence'] = Variable<double>(confidence);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LanguageTagsCompanion toCompanion(bool nullToAbsent) {
    return LanguageTagsCompanion(
      artistKey: Value(artistKey),
      primaryLanguage: Value(primaryLanguage),
      languageScoresJson: Value(languageScoresJson),
      source: Value(source),
      confidence: Value(confidence),
      updatedAt: Value(updatedAt),
    );
  }

  factory LanguageTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LanguageTag(
      artistKey: serializer.fromJson<String>(json['artistKey']),
      primaryLanguage: serializer.fromJson<String>(json['primaryLanguage']),
      languageScoresJson: serializer.fromJson<String>(
        json['languageScoresJson'],
      ),
      source: serializer.fromJson<String>(json['source']),
      confidence: serializer.fromJson<double>(json['confidence']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'artistKey': serializer.toJson<String>(artistKey),
      'primaryLanguage': serializer.toJson<String>(primaryLanguage),
      'languageScoresJson': serializer.toJson<String>(languageScoresJson),
      'source': serializer.toJson<String>(source),
      'confidence': serializer.toJson<double>(confidence),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LanguageTag copyWith({
    String? artistKey,
    String? primaryLanguage,
    String? languageScoresJson,
    String? source,
    double? confidence,
    DateTime? updatedAt,
  }) => LanguageTag(
    artistKey: artistKey ?? this.artistKey,
    primaryLanguage: primaryLanguage ?? this.primaryLanguage,
    languageScoresJson: languageScoresJson ?? this.languageScoresJson,
    source: source ?? this.source,
    confidence: confidence ?? this.confidence,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LanguageTag copyWithCompanion(LanguageTagsCompanion data) {
    return LanguageTag(
      artistKey: data.artistKey.present ? data.artistKey.value : this.artistKey,
      primaryLanguage: data.primaryLanguage.present
          ? data.primaryLanguage.value
          : this.primaryLanguage,
      languageScoresJson: data.languageScoresJson.present
          ? data.languageScoresJson.value
          : this.languageScoresJson,
      source: data.source.present ? data.source.value : this.source,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LanguageTag(')
          ..write('artistKey: $artistKey, ')
          ..write('primaryLanguage: $primaryLanguage, ')
          ..write('languageScoresJson: $languageScoresJson, ')
          ..write('source: $source, ')
          ..write('confidence: $confidence, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    artistKey,
    primaryLanguage,
    languageScoresJson,
    source,
    confidence,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LanguageTag &&
          other.artistKey == this.artistKey &&
          other.primaryLanguage == this.primaryLanguage &&
          other.languageScoresJson == this.languageScoresJson &&
          other.source == this.source &&
          other.confidence == this.confidence &&
          other.updatedAt == this.updatedAt);
}

class LanguageTagsCompanion extends UpdateCompanion<LanguageTag> {
  final Value<String> artistKey;
  final Value<String> primaryLanguage;
  final Value<String> languageScoresJson;
  final Value<String> source;
  final Value<double> confidence;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LanguageTagsCompanion({
    this.artistKey = const Value.absent(),
    this.primaryLanguage = const Value.absent(),
    this.languageScoresJson = const Value.absent(),
    this.source = const Value.absent(),
    this.confidence = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LanguageTagsCompanion.insert({
    required String artistKey,
    required String primaryLanguage,
    required String languageScoresJson,
    required String source,
    this.confidence = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : artistKey = Value(artistKey),
       primaryLanguage = Value(primaryLanguage),
       languageScoresJson = Value(languageScoresJson),
       source = Value(source);
  static Insertable<LanguageTag> custom({
    Expression<String>? artistKey,
    Expression<String>? primaryLanguage,
    Expression<String>? languageScoresJson,
    Expression<String>? source,
    Expression<double>? confidence,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (artistKey != null) 'artist_key': artistKey,
      if (primaryLanguage != null) 'primary_language': primaryLanguage,
      if (languageScoresJson != null)
        'language_scores_json': languageScoresJson,
      if (source != null) 'source': source,
      if (confidence != null) 'confidence': confidence,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LanguageTagsCompanion copyWith({
    Value<String>? artistKey,
    Value<String>? primaryLanguage,
    Value<String>? languageScoresJson,
    Value<String>? source,
    Value<double>? confidence,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LanguageTagsCompanion(
      artistKey: artistKey ?? this.artistKey,
      primaryLanguage: primaryLanguage ?? this.primaryLanguage,
      languageScoresJson: languageScoresJson ?? this.languageScoresJson,
      source: source ?? this.source,
      confidence: confidence ?? this.confidence,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (artistKey.present) {
      map['artist_key'] = Variable<String>(artistKey.value);
    }
    if (primaryLanguage.present) {
      map['primary_language'] = Variable<String>(primaryLanguage.value);
    }
    if (languageScoresJson.present) {
      map['language_scores_json'] = Variable<String>(languageScoresJson.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LanguageTagsCompanion(')
          ..write('artistKey: $artistKey, ')
          ..write('primaryLanguage: $primaryLanguage, ')
          ..write('languageScoresJson: $languageScoresJson, ')
          ..write('source: $source, ')
          ..write('confidence: $confidence, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserCorrectionsTable extends UserCorrections
    with TableInfo<$UserCorrectionsTable, UserCorrection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserCorrectionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _rawArtistNameMeta = const VerificationMeta(
    'rawArtistName',
  );
  @override
  late final GeneratedColumn<String> rawArtistName = GeneratedColumn<String>(
    'raw_artist_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistKeyMeta = const VerificationMeta(
    'artistKey',
  );
  @override
  late final GeneratedColumn<String> artistKey = GeneratedColumn<String>(
    'artist_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _predictedLanguageMeta = const VerificationMeta(
    'predictedLanguage',
  );
  @override
  late final GeneratedColumn<String> predictedLanguage =
      GeneratedColumn<String>(
        'predicted_language',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _correctedLanguageMeta = const VerificationMeta(
    'correctedLanguage',
  );
  @override
  late final GeneratedColumn<String> correctedLanguage =
      GeneratedColumn<String>(
        'corrected_language',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _correctedAtMeta = const VerificationMeta(
    'correctedAt',
  );
  @override
  late final GeneratedColumn<DateTime> correctedAt = GeneratedColumn<DateTime>(
    'corrected_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _signalThatFiredMeta = const VerificationMeta(
    'signalThatFired',
  );
  @override
  late final GeneratedColumn<int> signalThatFired = GeneratedColumn<int>(
    'signal_that_fired',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _confidenceAtTimeMeta = const VerificationMeta(
    'confidenceAtTime',
  );
  @override
  late final GeneratedColumn<double> confidenceAtTime = GeneratedColumn<double>(
    'confidence_at_time',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _appliedToSeedsMeta = const VerificationMeta(
    'appliedToSeeds',
  );
  @override
  late final GeneratedColumn<bool> appliedToSeeds = GeneratedColumn<bool>(
    'applied_to_seeds',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("applied_to_seeds" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rawArtistName,
    artistKey,
    predictedLanguage,
    correctedLanguage,
    correctedAt,
    signalThatFired,
    confidenceAtTime,
    appliedToSeeds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_corrections';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserCorrection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('raw_artist_name')) {
      context.handle(
        _rawArtistNameMeta,
        rawArtistName.isAcceptableOrUnknown(
          data['raw_artist_name']!,
          _rawArtistNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rawArtistNameMeta);
    }
    if (data.containsKey('artist_key')) {
      context.handle(
        _artistKeyMeta,
        artistKey.isAcceptableOrUnknown(data['artist_key']!, _artistKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_artistKeyMeta);
    }
    if (data.containsKey('predicted_language')) {
      context.handle(
        _predictedLanguageMeta,
        predictedLanguage.isAcceptableOrUnknown(
          data['predicted_language']!,
          _predictedLanguageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_predictedLanguageMeta);
    }
    if (data.containsKey('corrected_language')) {
      context.handle(
        _correctedLanguageMeta,
        correctedLanguage.isAcceptableOrUnknown(
          data['corrected_language']!,
          _correctedLanguageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_correctedLanguageMeta);
    }
    if (data.containsKey('corrected_at')) {
      context.handle(
        _correctedAtMeta,
        correctedAt.isAcceptableOrUnknown(
          data['corrected_at']!,
          _correctedAtMeta,
        ),
      );
    }
    if (data.containsKey('signal_that_fired')) {
      context.handle(
        _signalThatFiredMeta,
        signalThatFired.isAcceptableOrUnknown(
          data['signal_that_fired']!,
          _signalThatFiredMeta,
        ),
      );
    }
    if (data.containsKey('confidence_at_time')) {
      context.handle(
        _confidenceAtTimeMeta,
        confidenceAtTime.isAcceptableOrUnknown(
          data['confidence_at_time']!,
          _confidenceAtTimeMeta,
        ),
      );
    }
    if (data.containsKey('applied_to_seeds')) {
      context.handle(
        _appliedToSeedsMeta,
        appliedToSeeds.isAcceptableOrUnknown(
          data['applied_to_seeds']!,
          _appliedToSeedsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserCorrection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserCorrection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rawArtistName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_artist_name'],
      )!,
      artistKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_key'],
      )!,
      predictedLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}predicted_language'],
      )!,
      correctedLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}corrected_language'],
      )!,
      correctedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}corrected_at'],
      )!,
      signalThatFired: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}signal_that_fired'],
      )!,
      confidenceAtTime: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence_at_time'],
      )!,
      appliedToSeeds: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}applied_to_seeds'],
      )!,
    );
  }

  @override
  $UserCorrectionsTable createAlias(String alias) {
    return $UserCorrectionsTable(attachedDatabase, alias);
  }
}

class UserCorrection extends DataClass implements Insertable<UserCorrection> {
  final int id;
  final String rawArtistName;
  final String artistKey;
  final String predictedLanguage;
  final String correctedLanguage;
  final DateTime correctedAt;
  final int signalThatFired;
  final double confidenceAtTime;
  final bool appliedToSeeds;
  const UserCorrection({
    required this.id,
    required this.rawArtistName,
    required this.artistKey,
    required this.predictedLanguage,
    required this.correctedLanguage,
    required this.correctedAt,
    required this.signalThatFired,
    required this.confidenceAtTime,
    required this.appliedToSeeds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['raw_artist_name'] = Variable<String>(rawArtistName);
    map['artist_key'] = Variable<String>(artistKey);
    map['predicted_language'] = Variable<String>(predictedLanguage);
    map['corrected_language'] = Variable<String>(correctedLanguage);
    map['corrected_at'] = Variable<DateTime>(correctedAt);
    map['signal_that_fired'] = Variable<int>(signalThatFired);
    map['confidence_at_time'] = Variable<double>(confidenceAtTime);
    map['applied_to_seeds'] = Variable<bool>(appliedToSeeds);
    return map;
  }

  UserCorrectionsCompanion toCompanion(bool nullToAbsent) {
    return UserCorrectionsCompanion(
      id: Value(id),
      rawArtistName: Value(rawArtistName),
      artistKey: Value(artistKey),
      predictedLanguage: Value(predictedLanguage),
      correctedLanguage: Value(correctedLanguage),
      correctedAt: Value(correctedAt),
      signalThatFired: Value(signalThatFired),
      confidenceAtTime: Value(confidenceAtTime),
      appliedToSeeds: Value(appliedToSeeds),
    );
  }

  factory UserCorrection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserCorrection(
      id: serializer.fromJson<int>(json['id']),
      rawArtistName: serializer.fromJson<String>(json['rawArtistName']),
      artistKey: serializer.fromJson<String>(json['artistKey']),
      predictedLanguage: serializer.fromJson<String>(json['predictedLanguage']),
      correctedLanguage: serializer.fromJson<String>(json['correctedLanguage']),
      correctedAt: serializer.fromJson<DateTime>(json['correctedAt']),
      signalThatFired: serializer.fromJson<int>(json['signalThatFired']),
      confidenceAtTime: serializer.fromJson<double>(json['confidenceAtTime']),
      appliedToSeeds: serializer.fromJson<bool>(json['appliedToSeeds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rawArtistName': serializer.toJson<String>(rawArtistName),
      'artistKey': serializer.toJson<String>(artistKey),
      'predictedLanguage': serializer.toJson<String>(predictedLanguage),
      'correctedLanguage': serializer.toJson<String>(correctedLanguage),
      'correctedAt': serializer.toJson<DateTime>(correctedAt),
      'signalThatFired': serializer.toJson<int>(signalThatFired),
      'confidenceAtTime': serializer.toJson<double>(confidenceAtTime),
      'appliedToSeeds': serializer.toJson<bool>(appliedToSeeds),
    };
  }

  UserCorrection copyWith({
    int? id,
    String? rawArtistName,
    String? artistKey,
    String? predictedLanguage,
    String? correctedLanguage,
    DateTime? correctedAt,
    int? signalThatFired,
    double? confidenceAtTime,
    bool? appliedToSeeds,
  }) => UserCorrection(
    id: id ?? this.id,
    rawArtistName: rawArtistName ?? this.rawArtistName,
    artistKey: artistKey ?? this.artistKey,
    predictedLanguage: predictedLanguage ?? this.predictedLanguage,
    correctedLanguage: correctedLanguage ?? this.correctedLanguage,
    correctedAt: correctedAt ?? this.correctedAt,
    signalThatFired: signalThatFired ?? this.signalThatFired,
    confidenceAtTime: confidenceAtTime ?? this.confidenceAtTime,
    appliedToSeeds: appliedToSeeds ?? this.appliedToSeeds,
  );
  UserCorrection copyWithCompanion(UserCorrectionsCompanion data) {
    return UserCorrection(
      id: data.id.present ? data.id.value : this.id,
      rawArtistName: data.rawArtistName.present
          ? data.rawArtistName.value
          : this.rawArtistName,
      artistKey: data.artistKey.present ? data.artistKey.value : this.artistKey,
      predictedLanguage: data.predictedLanguage.present
          ? data.predictedLanguage.value
          : this.predictedLanguage,
      correctedLanguage: data.correctedLanguage.present
          ? data.correctedLanguage.value
          : this.correctedLanguage,
      correctedAt: data.correctedAt.present
          ? data.correctedAt.value
          : this.correctedAt,
      signalThatFired: data.signalThatFired.present
          ? data.signalThatFired.value
          : this.signalThatFired,
      confidenceAtTime: data.confidenceAtTime.present
          ? data.confidenceAtTime.value
          : this.confidenceAtTime,
      appliedToSeeds: data.appliedToSeeds.present
          ? data.appliedToSeeds.value
          : this.appliedToSeeds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserCorrection(')
          ..write('id: $id, ')
          ..write('rawArtistName: $rawArtistName, ')
          ..write('artistKey: $artistKey, ')
          ..write('predictedLanguage: $predictedLanguage, ')
          ..write('correctedLanguage: $correctedLanguage, ')
          ..write('correctedAt: $correctedAt, ')
          ..write('signalThatFired: $signalThatFired, ')
          ..write('confidenceAtTime: $confidenceAtTime, ')
          ..write('appliedToSeeds: $appliedToSeeds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    rawArtistName,
    artistKey,
    predictedLanguage,
    correctedLanguage,
    correctedAt,
    signalThatFired,
    confidenceAtTime,
    appliedToSeeds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserCorrection &&
          other.id == this.id &&
          other.rawArtistName == this.rawArtistName &&
          other.artistKey == this.artistKey &&
          other.predictedLanguage == this.predictedLanguage &&
          other.correctedLanguage == this.correctedLanguage &&
          other.correctedAt == this.correctedAt &&
          other.signalThatFired == this.signalThatFired &&
          other.confidenceAtTime == this.confidenceAtTime &&
          other.appliedToSeeds == this.appliedToSeeds);
}

class UserCorrectionsCompanion extends UpdateCompanion<UserCorrection> {
  final Value<int> id;
  final Value<String> rawArtistName;
  final Value<String> artistKey;
  final Value<String> predictedLanguage;
  final Value<String> correctedLanguage;
  final Value<DateTime> correctedAt;
  final Value<int> signalThatFired;
  final Value<double> confidenceAtTime;
  final Value<bool> appliedToSeeds;
  const UserCorrectionsCompanion({
    this.id = const Value.absent(),
    this.rawArtistName = const Value.absent(),
    this.artistKey = const Value.absent(),
    this.predictedLanguage = const Value.absent(),
    this.correctedLanguage = const Value.absent(),
    this.correctedAt = const Value.absent(),
    this.signalThatFired = const Value.absent(),
    this.confidenceAtTime = const Value.absent(),
    this.appliedToSeeds = const Value.absent(),
  });
  UserCorrectionsCompanion.insert({
    this.id = const Value.absent(),
    required String rawArtistName,
    required String artistKey,
    required String predictedLanguage,
    required String correctedLanguage,
    this.correctedAt = const Value.absent(),
    this.signalThatFired = const Value.absent(),
    this.confidenceAtTime = const Value.absent(),
    this.appliedToSeeds = const Value.absent(),
  }) : rawArtistName = Value(rawArtistName),
       artistKey = Value(artistKey),
       predictedLanguage = Value(predictedLanguage),
       correctedLanguage = Value(correctedLanguage);
  static Insertable<UserCorrection> custom({
    Expression<int>? id,
    Expression<String>? rawArtistName,
    Expression<String>? artistKey,
    Expression<String>? predictedLanguage,
    Expression<String>? correctedLanguage,
    Expression<DateTime>? correctedAt,
    Expression<int>? signalThatFired,
    Expression<double>? confidenceAtTime,
    Expression<bool>? appliedToSeeds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rawArtistName != null) 'raw_artist_name': rawArtistName,
      if (artistKey != null) 'artist_key': artistKey,
      if (predictedLanguage != null) 'predicted_language': predictedLanguage,
      if (correctedLanguage != null) 'corrected_language': correctedLanguage,
      if (correctedAt != null) 'corrected_at': correctedAt,
      if (signalThatFired != null) 'signal_that_fired': signalThatFired,
      if (confidenceAtTime != null) 'confidence_at_time': confidenceAtTime,
      if (appliedToSeeds != null) 'applied_to_seeds': appliedToSeeds,
    });
  }

  UserCorrectionsCompanion copyWith({
    Value<int>? id,
    Value<String>? rawArtistName,
    Value<String>? artistKey,
    Value<String>? predictedLanguage,
    Value<String>? correctedLanguage,
    Value<DateTime>? correctedAt,
    Value<int>? signalThatFired,
    Value<double>? confidenceAtTime,
    Value<bool>? appliedToSeeds,
  }) {
    return UserCorrectionsCompanion(
      id: id ?? this.id,
      rawArtistName: rawArtistName ?? this.rawArtistName,
      artistKey: artistKey ?? this.artistKey,
      predictedLanguage: predictedLanguage ?? this.predictedLanguage,
      correctedLanguage: correctedLanguage ?? this.correctedLanguage,
      correctedAt: correctedAt ?? this.correctedAt,
      signalThatFired: signalThatFired ?? this.signalThatFired,
      confidenceAtTime: confidenceAtTime ?? this.confidenceAtTime,
      appliedToSeeds: appliedToSeeds ?? this.appliedToSeeds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rawArtistName.present) {
      map['raw_artist_name'] = Variable<String>(rawArtistName.value);
    }
    if (artistKey.present) {
      map['artist_key'] = Variable<String>(artistKey.value);
    }
    if (predictedLanguage.present) {
      map['predicted_language'] = Variable<String>(predictedLanguage.value);
    }
    if (correctedLanguage.present) {
      map['corrected_language'] = Variable<String>(correctedLanguage.value);
    }
    if (correctedAt.present) {
      map['corrected_at'] = Variable<DateTime>(correctedAt.value);
    }
    if (signalThatFired.present) {
      map['signal_that_fired'] = Variable<int>(signalThatFired.value);
    }
    if (confidenceAtTime.present) {
      map['confidence_at_time'] = Variable<double>(confidenceAtTime.value);
    }
    if (appliedToSeeds.present) {
      map['applied_to_seeds'] = Variable<bool>(appliedToSeeds.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserCorrectionsCompanion(')
          ..write('id: $id, ')
          ..write('rawArtistName: $rawArtistName, ')
          ..write('artistKey: $artistKey, ')
          ..write('predictedLanguage: $predictedLanguage, ')
          ..write('correctedLanguage: $correctedLanguage, ')
          ..write('correctedAt: $correctedAt, ')
          ..write('signalThatFired: $signalThatFired, ')
          ..write('confidenceAtTime: $confidenceAtTime, ')
          ..write('appliedToSeeds: $appliedToSeeds')
          ..write(')'))
        .toString();
  }
}

class $QueueStateTable extends QueueState
    with TableInfo<$QueueStateTable, QueueStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueueStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _songIdsJsonMeta = const VerificationMeta(
    'songIdsJson',
  );
  @override
  late final GeneratedColumn<String> songIdsJson = GeneratedColumn<String>(
    'song_ids_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _currentIndexMeta = const VerificationMeta(
    'currentIndex',
  );
  @override
  late final GeneratedColumn<int> currentIndex = GeneratedColumn<int>(
    'current_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _repeatModeMeta = const VerificationMeta(
    'repeatMode',
  );
  @override
  late final GeneratedColumn<String> repeatMode = GeneratedColumn<String>(
    'repeat_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _shuffleModeMeta = const VerificationMeta(
    'shuffleMode',
  );
  @override
  late final GeneratedColumn<bool> shuffleMode = GeneratedColumn<bool>(
    'shuffle_mode',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("shuffle_mode" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    songIdsJson,
    currentIndex,
    positionMs,
    repeatMode,
    shuffleMode,
    savedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'queue_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<QueueStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('song_ids_json')) {
      context.handle(
        _songIdsJsonMeta,
        songIdsJson.isAcceptableOrUnknown(
          data['song_ids_json']!,
          _songIdsJsonMeta,
        ),
      );
    }
    if (data.containsKey('current_index')) {
      context.handle(
        _currentIndexMeta,
        currentIndex.isAcceptableOrUnknown(
          data['current_index']!,
          _currentIndexMeta,
        ),
      );
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    }
    if (data.containsKey('repeat_mode')) {
      context.handle(
        _repeatModeMeta,
        repeatMode.isAcceptableOrUnknown(data['repeat_mode']!, _repeatModeMeta),
      );
    }
    if (data.containsKey('shuffle_mode')) {
      context.handle(
        _shuffleModeMeta,
        shuffleMode.isAcceptableOrUnknown(
          data['shuffle_mode']!,
          _shuffleModeMeta,
        ),
      );
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QueueStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueueStateData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      songIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_ids_json'],
      )!,
      currentIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_index'],
      )!,
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      )!,
      repeatMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_mode'],
      )!,
      shuffleMode: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}shuffle_mode'],
      )!,
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_at'],
      ),
    );
  }

  @override
  $QueueStateTable createAlias(String alias) {
    return $QueueStateTable(attachedDatabase, alias);
  }
}

class QueueStateData extends DataClass implements Insertable<QueueStateData> {
  final int id;
  final String songIdsJson;
  final int currentIndex;
  final int positionMs;
  final String repeatMode;
  final bool shuffleMode;
  final DateTime? savedAt;
  const QueueStateData({
    required this.id,
    required this.songIdsJson,
    required this.currentIndex,
    required this.positionMs,
    required this.repeatMode,
    required this.shuffleMode,
    this.savedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['song_ids_json'] = Variable<String>(songIdsJson);
    map['current_index'] = Variable<int>(currentIndex);
    map['position_ms'] = Variable<int>(positionMs);
    map['repeat_mode'] = Variable<String>(repeatMode);
    map['shuffle_mode'] = Variable<bool>(shuffleMode);
    if (!nullToAbsent || savedAt != null) {
      map['saved_at'] = Variable<DateTime>(savedAt);
    }
    return map;
  }

  QueueStateCompanion toCompanion(bool nullToAbsent) {
    return QueueStateCompanion(
      id: Value(id),
      songIdsJson: Value(songIdsJson),
      currentIndex: Value(currentIndex),
      positionMs: Value(positionMs),
      repeatMode: Value(repeatMode),
      shuffleMode: Value(shuffleMode),
      savedAt: savedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(savedAt),
    );
  }

  factory QueueStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueueStateData(
      id: serializer.fromJson<int>(json['id']),
      songIdsJson: serializer.fromJson<String>(json['songIdsJson']),
      currentIndex: serializer.fromJson<int>(json['currentIndex']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      repeatMode: serializer.fromJson<String>(json['repeatMode']),
      shuffleMode: serializer.fromJson<bool>(json['shuffleMode']),
      savedAt: serializer.fromJson<DateTime?>(json['savedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'songIdsJson': serializer.toJson<String>(songIdsJson),
      'currentIndex': serializer.toJson<int>(currentIndex),
      'positionMs': serializer.toJson<int>(positionMs),
      'repeatMode': serializer.toJson<String>(repeatMode),
      'shuffleMode': serializer.toJson<bool>(shuffleMode),
      'savedAt': serializer.toJson<DateTime?>(savedAt),
    };
  }

  QueueStateData copyWith({
    int? id,
    String? songIdsJson,
    int? currentIndex,
    int? positionMs,
    String? repeatMode,
    bool? shuffleMode,
    Value<DateTime?> savedAt = const Value.absent(),
  }) => QueueStateData(
    id: id ?? this.id,
    songIdsJson: songIdsJson ?? this.songIdsJson,
    currentIndex: currentIndex ?? this.currentIndex,
    positionMs: positionMs ?? this.positionMs,
    repeatMode: repeatMode ?? this.repeatMode,
    shuffleMode: shuffleMode ?? this.shuffleMode,
    savedAt: savedAt.present ? savedAt.value : this.savedAt,
  );
  QueueStateData copyWithCompanion(QueueStateCompanion data) {
    return QueueStateData(
      id: data.id.present ? data.id.value : this.id,
      songIdsJson: data.songIdsJson.present
          ? data.songIdsJson.value
          : this.songIdsJson,
      currentIndex: data.currentIndex.present
          ? data.currentIndex.value
          : this.currentIndex,
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      repeatMode: data.repeatMode.present
          ? data.repeatMode.value
          : this.repeatMode,
      shuffleMode: data.shuffleMode.present
          ? data.shuffleMode.value
          : this.shuffleMode,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueueStateData(')
          ..write('id: $id, ')
          ..write('songIdsJson: $songIdsJson, ')
          ..write('currentIndex: $currentIndex, ')
          ..write('positionMs: $positionMs, ')
          ..write('repeatMode: $repeatMode, ')
          ..write('shuffleMode: $shuffleMode, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    songIdsJson,
    currentIndex,
    positionMs,
    repeatMode,
    shuffleMode,
    savedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueueStateData &&
          other.id == this.id &&
          other.songIdsJson == this.songIdsJson &&
          other.currentIndex == this.currentIndex &&
          other.positionMs == this.positionMs &&
          other.repeatMode == this.repeatMode &&
          other.shuffleMode == this.shuffleMode &&
          other.savedAt == this.savedAt);
}

class QueueStateCompanion extends UpdateCompanion<QueueStateData> {
  final Value<int> id;
  final Value<String> songIdsJson;
  final Value<int> currentIndex;
  final Value<int> positionMs;
  final Value<String> repeatMode;
  final Value<bool> shuffleMode;
  final Value<DateTime?> savedAt;
  const QueueStateCompanion({
    this.id = const Value.absent(),
    this.songIdsJson = const Value.absent(),
    this.currentIndex = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.repeatMode = const Value.absent(),
    this.shuffleMode = const Value.absent(),
    this.savedAt = const Value.absent(),
  });
  QueueStateCompanion.insert({
    this.id = const Value.absent(),
    this.songIdsJson = const Value.absent(),
    this.currentIndex = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.repeatMode = const Value.absent(),
    this.shuffleMode = const Value.absent(),
    this.savedAt = const Value.absent(),
  });
  static Insertable<QueueStateData> custom({
    Expression<int>? id,
    Expression<String>? songIdsJson,
    Expression<int>? currentIndex,
    Expression<int>? positionMs,
    Expression<String>? repeatMode,
    Expression<bool>? shuffleMode,
    Expression<DateTime>? savedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (songIdsJson != null) 'song_ids_json': songIdsJson,
      if (currentIndex != null) 'current_index': currentIndex,
      if (positionMs != null) 'position_ms': positionMs,
      if (repeatMode != null) 'repeat_mode': repeatMode,
      if (shuffleMode != null) 'shuffle_mode': shuffleMode,
      if (savedAt != null) 'saved_at': savedAt,
    });
  }

  QueueStateCompanion copyWith({
    Value<int>? id,
    Value<String>? songIdsJson,
    Value<int>? currentIndex,
    Value<int>? positionMs,
    Value<String>? repeatMode,
    Value<bool>? shuffleMode,
    Value<DateTime?>? savedAt,
  }) {
    return QueueStateCompanion(
      id: id ?? this.id,
      songIdsJson: songIdsJson ?? this.songIdsJson,
      currentIndex: currentIndex ?? this.currentIndex,
      positionMs: positionMs ?? this.positionMs,
      repeatMode: repeatMode ?? this.repeatMode,
      shuffleMode: shuffleMode ?? this.shuffleMode,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (songIdsJson.present) {
      map['song_ids_json'] = Variable<String>(songIdsJson.value);
    }
    if (currentIndex.present) {
      map['current_index'] = Variable<int>(currentIndex.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (repeatMode.present) {
      map['repeat_mode'] = Variable<String>(repeatMode.value);
    }
    if (shuffleMode.present) {
      map['shuffle_mode'] = Variable<bool>(shuffleMode.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueueStateCompanion(')
          ..write('id: $id, ')
          ..write('songIdsJson: $songIdsJson, ')
          ..write('currentIndex: $currentIndex, ')
          ..write('positionMs: $positionMs, ')
          ..write('repeatMode: $repeatMode, ')
          ..write('shuffleMode: $shuffleMode, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
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
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String? value;
  const AppSetting({required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  AppSetting copyWith({
    String? key,
    Value<String?> value = const Value.absent(),
  }) => AppSetting(
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
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
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String?> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<AppSetting> custom({
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

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String?>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
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
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SongsTable songs = $SongsTable(this);
  late final $PlaylistsTable playlists = $PlaylistsTable(this);
  late final $PlaylistEntriesTable playlistEntries = $PlaylistEntriesTable(
    this,
  );
  late final $PlayHistoryTable playHistory = $PlayHistoryTable(this);
  late final $SongStatsTable songStats = $SongStatsTable(this);
  late final $LanguageTagsTable languageTags = $LanguageTagsTable(this);
  late final $UserCorrectionsTable userCorrections = $UserCorrectionsTable(
    this,
  );
  late final $QueueStateTable queueState = $QueueStateTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final SongsDao songsDao = SongsDao(this as AppDatabase);
  late final PlaylistsDao playlistsDao = PlaylistsDao(this as AppDatabase);
  late final HistoryDao historyDao = HistoryDao(this as AppDatabase);
  late final LanguageDao languageDao = LanguageDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    songs,
    playlists,
    playlistEntries,
    playHistory,
    songStats,
    languageTags,
    userCorrections,
    queueState,
    appSettings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'playlists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playlist_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'songs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playlist_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'songs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('play_history', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'songs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('song_stats', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$SongsTableCreateCompanionBuilder =
    SongsCompanion Function({
      Value<int> id,
      Value<String?> title,
      Value<String?> artist,
      Value<String?> album,
      Value<String?> albumArtist,
      Value<int?> durationMs,
      Value<int?> trackNumber,
      Value<int?> discNumber,
      Value<int?> year,
      Value<String?> genre,
      required String path,
      required int albumId,
      required int dateAdded,
      Value<String?> fileHash,
      Value<bool> isAvailable,
      Value<String?> languageTag,
      Value<double> classifierConfidence,
      Value<bool> wasManuallyTagged,
      Value<int?> dateScanned,
    });
typedef $$SongsTableUpdateCompanionBuilder =
    SongsCompanion Function({
      Value<int> id,
      Value<String?> title,
      Value<String?> artist,
      Value<String?> album,
      Value<String?> albumArtist,
      Value<int?> durationMs,
      Value<int?> trackNumber,
      Value<int?> discNumber,
      Value<int?> year,
      Value<String?> genre,
      Value<String> path,
      Value<int> albumId,
      Value<int> dateAdded,
      Value<String?> fileHash,
      Value<bool> isAvailable,
      Value<String?> languageTag,
      Value<double> classifierConfidence,
      Value<bool> wasManuallyTagged,
      Value<int?> dateScanned,
    });

final class $$SongsTableReferences
    extends BaseReferences<_$AppDatabase, $SongsTable, Song> {
  $$SongsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlaylistEntriesTable, List<PlaylistEntry>>
  _playlistEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playlistEntries,
    aliasName: 'songs__id__playlist_entries__song_id',
  );

  $$PlaylistEntriesTableProcessedTableManager get playlistEntriesRefs {
    final manager = $$PlaylistEntriesTableTableManager(
      $_db,
      $_db.playlistEntries,
    ).filter((f) => f.songId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playlistEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PlayHistoryTable, List<PlayHistoryData>>
  _playHistoryRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playHistory,
    aliasName: 'songs__id__play_history__song_id',
  );

  $$PlayHistoryTableProcessedTableManager get playHistoryRefs {
    final manager = $$PlayHistoryTableTableManager(
      $_db,
      $_db.playHistory,
    ).filter((f) => f.songId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_playHistoryRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SongStatsTable, List<SongStat>>
  _songStatsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.songStats,
    aliasName: 'songs__id__song_stats__song_id',
  );

  $$SongStatsTableProcessedTableManager get songStatsRefs {
    final manager = $$SongStatsTableTableManager(
      $_db,
      $_db.songStats,
    ).filter((f) => f.songId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_songStatsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SongsTableFilterComposer extends Composer<_$AppDatabase, $SongsTable> {
  $$SongsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get albumArtist => $composableBuilder(
    column: $table.albumArtist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discNumber => $composableBuilder(
    column: $table.discNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get albumId => $composableBuilder(
    column: $table.albumId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileHash => $composableBuilder(
    column: $table.fileHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAvailable => $composableBuilder(
    column: $table.isAvailable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get languageTag => $composableBuilder(
    column: $table.languageTag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get classifierConfidence => $composableBuilder(
    column: $table.classifierConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wasManuallyTagged => $composableBuilder(
    column: $table.wasManuallyTagged,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dateScanned => $composableBuilder(
    column: $table.dateScanned,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playlistEntriesRefs(
    Expression<bool> Function($$PlaylistEntriesTableFilterComposer f) f,
  ) {
    final $$PlaylistEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistEntries,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistEntriesTableFilterComposer(
            $db: $db,
            $table: $db.playlistEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> playHistoryRefs(
    Expression<bool> Function($$PlayHistoryTableFilterComposer f) f,
  ) {
    final $$PlayHistoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playHistory,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayHistoryTableFilterComposer(
            $db: $db,
            $table: $db.playHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> songStatsRefs(
    Expression<bool> Function($$SongStatsTableFilterComposer f) f,
  ) {
    final $$SongStatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.songStats,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongStatsTableFilterComposer(
            $db: $db,
            $table: $db.songStats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SongsTableOrderingComposer
    extends Composer<_$AppDatabase, $SongsTable> {
  $$SongsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get albumArtist => $composableBuilder(
    column: $table.albumArtist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discNumber => $composableBuilder(
    column: $table.discNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get albumId => $composableBuilder(
    column: $table.albumId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileHash => $composableBuilder(
    column: $table.fileHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAvailable => $composableBuilder(
    column: $table.isAvailable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languageTag => $composableBuilder(
    column: $table.languageTag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get classifierConfidence => $composableBuilder(
    column: $table.classifierConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wasManuallyTagged => $composableBuilder(
    column: $table.wasManuallyTagged,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateScanned => $composableBuilder(
    column: $table.dateScanned,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SongsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SongsTable> {
  $$SongsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<String> get albumArtist => $composableBuilder(
    column: $table.albumArtist,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discNumber => $composableBuilder(
    column: $table.discNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<int> get albumId =>
      $composableBuilder(column: $table.albumId, builder: (column) => column);

  GeneratedColumn<int> get dateAdded =>
      $composableBuilder(column: $table.dateAdded, builder: (column) => column);

  GeneratedColumn<String> get fileHash =>
      $composableBuilder(column: $table.fileHash, builder: (column) => column);

  GeneratedColumn<bool> get isAvailable => $composableBuilder(
    column: $table.isAvailable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get languageTag => $composableBuilder(
    column: $table.languageTag,
    builder: (column) => column,
  );

  GeneratedColumn<double> get classifierConfidence => $composableBuilder(
    column: $table.classifierConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get wasManuallyTagged => $composableBuilder(
    column: $table.wasManuallyTagged,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dateScanned => $composableBuilder(
    column: $table.dateScanned,
    builder: (column) => column,
  );

  Expression<T> playlistEntriesRefs<T extends Object>(
    Expression<T> Function($$PlaylistEntriesTableAnnotationComposer a) f,
  ) {
    final $$PlaylistEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistEntries,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.playlistEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> playHistoryRefs<T extends Object>(
    Expression<T> Function($$PlayHistoryTableAnnotationComposer a) f,
  ) {
    final $$PlayHistoryTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playHistory,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayHistoryTableAnnotationComposer(
            $db: $db,
            $table: $db.playHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> songStatsRefs<T extends Object>(
    Expression<T> Function($$SongStatsTableAnnotationComposer a) f,
  ) {
    final $$SongStatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.songStats,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongStatsTableAnnotationComposer(
            $db: $db,
            $table: $db.songStats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SongsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SongsTable,
          Song,
          $$SongsTableFilterComposer,
          $$SongsTableOrderingComposer,
          $$SongsTableAnnotationComposer,
          $$SongsTableCreateCompanionBuilder,
          $$SongsTableUpdateCompanionBuilder,
          (Song, $$SongsTableReferences),
          Song,
          PrefetchHooks Function({
            bool playlistEntriesRefs,
            bool playHistoryRefs,
            bool songStatsRefs,
          })
        > {
  $$SongsTableTableManager(_$AppDatabase db, $SongsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> albumArtist = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<int?> trackNumber = const Value.absent(),
                Value<int?> discNumber = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<int> albumId = const Value.absent(),
                Value<int> dateAdded = const Value.absent(),
                Value<String?> fileHash = const Value.absent(),
                Value<bool> isAvailable = const Value.absent(),
                Value<String?> languageTag = const Value.absent(),
                Value<double> classifierConfidence = const Value.absent(),
                Value<bool> wasManuallyTagged = const Value.absent(),
                Value<int?> dateScanned = const Value.absent(),
              }) => SongsCompanion(
                id: id,
                title: title,
                artist: artist,
                album: album,
                albumArtist: albumArtist,
                durationMs: durationMs,
                trackNumber: trackNumber,
                discNumber: discNumber,
                year: year,
                genre: genre,
                path: path,
                albumId: albumId,
                dateAdded: dateAdded,
                fileHash: fileHash,
                isAvailable: isAvailable,
                languageTag: languageTag,
                classifierConfidence: classifierConfidence,
                wasManuallyTagged: wasManuallyTagged,
                dateScanned: dateScanned,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> albumArtist = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<int?> trackNumber = const Value.absent(),
                Value<int?> discNumber = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                required String path,
                required int albumId,
                required int dateAdded,
                Value<String?> fileHash = const Value.absent(),
                Value<bool> isAvailable = const Value.absent(),
                Value<String?> languageTag = const Value.absent(),
                Value<double> classifierConfidence = const Value.absent(),
                Value<bool> wasManuallyTagged = const Value.absent(),
                Value<int?> dateScanned = const Value.absent(),
              }) => SongsCompanion.insert(
                id: id,
                title: title,
                artist: artist,
                album: album,
                albumArtist: albumArtist,
                durationMs: durationMs,
                trackNumber: trackNumber,
                discNumber: discNumber,
                year: year,
                genre: genre,
                path: path,
                albumId: albumId,
                dateAdded: dateAdded,
                fileHash: fileHash,
                isAvailable: isAvailable,
                languageTag: languageTag,
                classifierConfidence: classifierConfidence,
                wasManuallyTagged: wasManuallyTagged,
                dateScanned: dateScanned,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$SongsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                playlistEntriesRefs = false,
                playHistoryRefs = false,
                songStatsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (playlistEntriesRefs) db.playlistEntries,
                    if (playHistoryRefs) db.playHistory,
                    if (songStatsRefs) db.songStats,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (playlistEntriesRefs)
                        await $_getPrefetchedData<
                          Song,
                          $SongsTable,
                          PlaylistEntry
                        >(
                          currentTable: table,
                          referencedTable: $$SongsTableReferences
                              ._playlistEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SongsTableReferences(
                                db,
                                table,
                                p0,
                              ).playlistEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.songId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (playHistoryRefs)
                        await $_getPrefetchedData<
                          Song,
                          $SongsTable,
                          PlayHistoryData
                        >(
                          currentTable: table,
                          referencedTable: $$SongsTableReferences
                              ._playHistoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SongsTableReferences(
                                db,
                                table,
                                p0,
                              ).playHistoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.songId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (songStatsRefs)
                        await $_getPrefetchedData<Song, $SongsTable, SongStat>(
                          currentTable: table,
                          referencedTable: $$SongsTableReferences
                              ._songStatsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SongsTableReferences(
                                db,
                                table,
                                p0,
                              ).songStatsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.songId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SongsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SongsTable,
      Song,
      $$SongsTableFilterComposer,
      $$SongsTableOrderingComposer,
      $$SongsTableAnnotationComposer,
      $$SongsTableCreateCompanionBuilder,
      $$SongsTableUpdateCompanionBuilder,
      (Song, $$SongsTableReferences),
      Song,
      PrefetchHooks Function({
        bool playlistEntriesRefs,
        bool playHistoryRefs,
        bool songStatsRefs,
      })
    >;
typedef $$PlaylistsTableCreateCompanionBuilder =
    PlaylistsCompanion Function({
      Value<int> id,
      required String name,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isSystem,
      Value<String?> systemType,
    });
typedef $$PlaylistsTableUpdateCompanionBuilder =
    PlaylistsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isSystem,
      Value<String?> systemType,
    });

final class $$PlaylistsTableReferences
    extends BaseReferences<_$AppDatabase, $PlaylistsTable, Playlist> {
  $$PlaylistsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlaylistEntriesTable, List<PlaylistEntry>>
  _playlistEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playlistEntries,
    aliasName: 'playlists__id__playlist_entries__playlist_id',
  );

  $$PlaylistEntriesTableProcessedTableManager get playlistEntriesRefs {
    final manager = $$PlaylistEntriesTableTableManager(
      $_db,
      $_db.playlistEntries,
    ).filter((f) => f.playlistId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playlistEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlaylistsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get systemType => $composableBuilder(
    column: $table.systemType,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playlistEntriesRefs(
    Expression<bool> Function($$PlaylistEntriesTableFilterComposer f) f,
  ) {
    final $$PlaylistEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistEntries,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistEntriesTableFilterComposer(
            $db: $db,
            $table: $db.playlistEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaylistsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get systemType => $composableBuilder(
    column: $table.systemType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaylistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<String> get systemType => $composableBuilder(
    column: $table.systemType,
    builder: (column) => column,
  );

  Expression<T> playlistEntriesRefs<T extends Object>(
    Expression<T> Function($$PlaylistEntriesTableAnnotationComposer a) f,
  ) {
    final $$PlaylistEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistEntries,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.playlistEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaylistsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistsTable,
          Playlist,
          $$PlaylistsTableFilterComposer,
          $$PlaylistsTableOrderingComposer,
          $$PlaylistsTableAnnotationComposer,
          $$PlaylistsTableCreateCompanionBuilder,
          $$PlaylistsTableUpdateCompanionBuilder,
          (Playlist, $$PlaylistsTableReferences),
          Playlist,
          PrefetchHooks Function({bool playlistEntriesRefs})
        > {
  $$PlaylistsTableTableManager(_$AppDatabase db, $PlaylistsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<String?> systemType = const Value.absent(),
              }) => PlaylistsCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSystem: isSystem,
                systemType: systemType,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<String?> systemType = const Value.absent(),
              }) => PlaylistsCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSystem: isSystem,
                systemType: systemType,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaylistsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (playlistEntriesRefs) db.playlistEntries,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (playlistEntriesRefs)
                    await $_getPrefetchedData<
                      Playlist,
                      $PlaylistsTable,
                      PlaylistEntry
                    >(
                      currentTable: table,
                      referencedTable: $$PlaylistsTableReferences
                          ._playlistEntriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PlaylistsTableReferences(
                            db,
                            table,
                            p0,
                          ).playlistEntriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.playlistId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistsTable,
      Playlist,
      $$PlaylistsTableFilterComposer,
      $$PlaylistsTableOrderingComposer,
      $$PlaylistsTableAnnotationComposer,
      $$PlaylistsTableCreateCompanionBuilder,
      $$PlaylistsTableUpdateCompanionBuilder,
      (Playlist, $$PlaylistsTableReferences),
      Playlist,
      PrefetchHooks Function({bool playlistEntriesRefs})
    >;
typedef $$PlaylistEntriesTableCreateCompanionBuilder =
    PlaylistEntriesCompanion Function({
      Value<int> id,
      required int playlistId,
      required int songId,
      required int position,
      Value<DateTime> addedAt,
    });
typedef $$PlaylistEntriesTableUpdateCompanionBuilder =
    PlaylistEntriesCompanion Function({
      Value<int> id,
      Value<int> playlistId,
      Value<int> songId,
      Value<int> position,
      Value<DateTime> addedAt,
    });

final class $$PlaylistEntriesTableReferences
    extends
        BaseReferences<_$AppDatabase, $PlaylistEntriesTable, PlaylistEntry> {
  $$PlaylistEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlaylistsTable _playlistIdTable(_$AppDatabase db) =>
      db.playlists.createAlias('playlist_entries__playlist_id__playlists__id');

  $$PlaylistsTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<int>('playlist_id')!;

    final manager = $$PlaylistsTableTableManager(
      $_db,
      $_db.playlists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SongsTable _songIdTable(_$AppDatabase db) =>
      db.songs.createAlias('playlist_entries__song_id__songs__id');

  $$SongsTableProcessedTableManager get songId {
    final $_column = $_itemColumn<int>('song_id')!;

    final manager = $$SongsTableTableManager(
      $_db,
      $_db.songs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_songIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlaylistEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistEntriesTable> {
  $$PlaylistEntriesTableFilterComposer({
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

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PlaylistsTableFilterComposer get playlistId {
    final $$PlaylistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableFilterComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SongsTableFilterComposer get songId {
    final $$SongsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableFilterComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistEntriesTable> {
  $$PlaylistEntriesTableOrderingComposer({
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

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlaylistsTableOrderingComposer get playlistId {
    final $$PlaylistsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableOrderingComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SongsTableOrderingComposer get songId {
    final $$SongsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableOrderingComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistEntriesTable> {
  $$PlaylistEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$PlaylistsTableAnnotationComposer get playlistId {
    final $$PlaylistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableAnnotationComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SongsTableAnnotationComposer get songId {
    final $$SongsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableAnnotationComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistEntriesTable,
          PlaylistEntry,
          $$PlaylistEntriesTableFilterComposer,
          $$PlaylistEntriesTableOrderingComposer,
          $$PlaylistEntriesTableAnnotationComposer,
          $$PlaylistEntriesTableCreateCompanionBuilder,
          $$PlaylistEntriesTableUpdateCompanionBuilder,
          (PlaylistEntry, $$PlaylistEntriesTableReferences),
          PlaylistEntry,
          PrefetchHooks Function({bool playlistId, bool songId})
        > {
  $$PlaylistEntriesTableTableManager(
    _$AppDatabase db,
    $PlaylistEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> playlistId = const Value.absent(),
                Value<int> songId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => PlaylistEntriesCompanion(
                id: id,
                playlistId: playlistId,
                songId: songId,
                position: position,
                addedAt: addedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int playlistId,
                required int songId,
                required int position,
                Value<DateTime> addedAt = const Value.absent(),
              }) => PlaylistEntriesCompanion.insert(
                id: id,
                playlistId: playlistId,
                songId: songId,
                position: position,
                addedAt: addedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaylistEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistId = false, songId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (playlistId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.playlistId,
                                referencedTable:
                                    $$PlaylistEntriesTableReferences
                                        ._playlistIdTable(db),
                                referencedColumn:
                                    $$PlaylistEntriesTableReferences
                                        ._playlistIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (songId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.songId,
                                referencedTable:
                                    $$PlaylistEntriesTableReferences
                                        ._songIdTable(db),
                                referencedColumn:
                                    $$PlaylistEntriesTableReferences
                                        ._songIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistEntriesTable,
      PlaylistEntry,
      $$PlaylistEntriesTableFilterComposer,
      $$PlaylistEntriesTableOrderingComposer,
      $$PlaylistEntriesTableAnnotationComposer,
      $$PlaylistEntriesTableCreateCompanionBuilder,
      $$PlaylistEntriesTableUpdateCompanionBuilder,
      (PlaylistEntry, $$PlaylistEntriesTableReferences),
      PlaylistEntry,
      PrefetchHooks Function({bool playlistId, bool songId})
    >;
typedef $$PlayHistoryTableCreateCompanionBuilder =
    PlayHistoryCompanion Function({
      Value<int> id,
      required int songId,
      Value<DateTime> playedAt,
      Value<int> listenedMs,
      Value<bool> counted,
      Value<bool> skippedEarly,
    });
typedef $$PlayHistoryTableUpdateCompanionBuilder =
    PlayHistoryCompanion Function({
      Value<int> id,
      Value<int> songId,
      Value<DateTime> playedAt,
      Value<int> listenedMs,
      Value<bool> counted,
      Value<bool> skippedEarly,
    });

final class $$PlayHistoryTableReferences
    extends BaseReferences<_$AppDatabase, $PlayHistoryTable, PlayHistoryData> {
  $$PlayHistoryTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SongsTable _songIdTable(_$AppDatabase db) =>
      db.songs.createAlias('play_history__song_id__songs__id');

  $$SongsTableProcessedTableManager get songId {
    final $_column = $_itemColumn<int>('song_id')!;

    final manager = $$SongsTableTableManager(
      $_db,
      $_db.songs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_songIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlayHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $PlayHistoryTable> {
  $$PlayHistoryTableFilterComposer({
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

  ColumnFilters<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get listenedMs => $composableBuilder(
    column: $table.listenedMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get counted => $composableBuilder(
    column: $table.counted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get skippedEarly => $composableBuilder(
    column: $table.skippedEarly,
    builder: (column) => ColumnFilters(column),
  );

  $$SongsTableFilterComposer get songId {
    final $$SongsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableFilterComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlayHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayHistoryTable> {
  $$PlayHistoryTableOrderingComposer({
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

  ColumnOrderings<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get listenedMs => $composableBuilder(
    column: $table.listenedMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get counted => $composableBuilder(
    column: $table.counted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get skippedEarly => $composableBuilder(
    column: $table.skippedEarly,
    builder: (column) => ColumnOrderings(column),
  );

  $$SongsTableOrderingComposer get songId {
    final $$SongsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableOrderingComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlayHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayHistoryTable> {
  $$PlayHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get playedAt =>
      $composableBuilder(column: $table.playedAt, builder: (column) => column);

  GeneratedColumn<int> get listenedMs => $composableBuilder(
    column: $table.listenedMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get counted =>
      $composableBuilder(column: $table.counted, builder: (column) => column);

  GeneratedColumn<bool> get skippedEarly => $composableBuilder(
    column: $table.skippedEarly,
    builder: (column) => column,
  );

  $$SongsTableAnnotationComposer get songId {
    final $$SongsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableAnnotationComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlayHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayHistoryTable,
          PlayHistoryData,
          $$PlayHistoryTableFilterComposer,
          $$PlayHistoryTableOrderingComposer,
          $$PlayHistoryTableAnnotationComposer,
          $$PlayHistoryTableCreateCompanionBuilder,
          $$PlayHistoryTableUpdateCompanionBuilder,
          (PlayHistoryData, $$PlayHistoryTableReferences),
          PlayHistoryData,
          PrefetchHooks Function({bool songId})
        > {
  $$PlayHistoryTableTableManager(_$AppDatabase db, $PlayHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> songId = const Value.absent(),
                Value<DateTime> playedAt = const Value.absent(),
                Value<int> listenedMs = const Value.absent(),
                Value<bool> counted = const Value.absent(),
                Value<bool> skippedEarly = const Value.absent(),
              }) => PlayHistoryCompanion(
                id: id,
                songId: songId,
                playedAt: playedAt,
                listenedMs: listenedMs,
                counted: counted,
                skippedEarly: skippedEarly,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int songId,
                Value<DateTime> playedAt = const Value.absent(),
                Value<int> listenedMs = const Value.absent(),
                Value<bool> counted = const Value.absent(),
                Value<bool> skippedEarly = const Value.absent(),
              }) => PlayHistoryCompanion.insert(
                id: id,
                songId: songId,
                playedAt: playedAt,
                listenedMs: listenedMs,
                counted: counted,
                skippedEarly: skippedEarly,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlayHistoryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({songId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (songId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.songId,
                                referencedTable: $$PlayHistoryTableReferences
                                    ._songIdTable(db),
                                referencedColumn: $$PlayHistoryTableReferences
                                    ._songIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlayHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayHistoryTable,
      PlayHistoryData,
      $$PlayHistoryTableFilterComposer,
      $$PlayHistoryTableOrderingComposer,
      $$PlayHistoryTableAnnotationComposer,
      $$PlayHistoryTableCreateCompanionBuilder,
      $$PlayHistoryTableUpdateCompanionBuilder,
      (PlayHistoryData, $$PlayHistoryTableReferences),
      PlayHistoryData,
      PrefetchHooks Function({bool songId})
    >;
typedef $$SongStatsTableCreateCompanionBuilder =
    SongStatsCompanion Function({
      Value<int> songId,
      Value<int> playCount,
      Value<int> totalListenedMs,
      Value<DateTime?> lastPlayed,
      Value<int> skipCount,
    });
typedef $$SongStatsTableUpdateCompanionBuilder =
    SongStatsCompanion Function({
      Value<int> songId,
      Value<int> playCount,
      Value<int> totalListenedMs,
      Value<DateTime?> lastPlayed,
      Value<int> skipCount,
    });

final class $$SongStatsTableReferences
    extends BaseReferences<_$AppDatabase, $SongStatsTable, SongStat> {
  $$SongStatsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SongsTable _songIdTable(_$AppDatabase db) =>
      db.songs.createAlias('song_stats__song_id__songs__id');

  $$SongsTableProcessedTableManager get songId {
    final $_column = $_itemColumn<int>('song_id')!;

    final manager = $$SongsTableTableManager(
      $_db,
      $_db.songs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_songIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SongStatsTableFilterComposer
    extends Composer<_$AppDatabase, $SongStatsTable> {
  $$SongStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalListenedMs => $composableBuilder(
    column: $table.totalListenedMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPlayed => $composableBuilder(
    column: $table.lastPlayed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skipCount => $composableBuilder(
    column: $table.skipCount,
    builder: (column) => ColumnFilters(column),
  );

  $$SongsTableFilterComposer get songId {
    final $$SongsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableFilterComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SongStatsTableOrderingComposer
    extends Composer<_$AppDatabase, $SongStatsTable> {
  $$SongStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalListenedMs => $composableBuilder(
    column: $table.totalListenedMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPlayed => $composableBuilder(
    column: $table.lastPlayed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skipCount => $composableBuilder(
    column: $table.skipCount,
    builder: (column) => ColumnOrderings(column),
  );

  $$SongsTableOrderingComposer get songId {
    final $$SongsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableOrderingComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SongStatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SongStatsTable> {
  $$SongStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get playCount =>
      $composableBuilder(column: $table.playCount, builder: (column) => column);

  GeneratedColumn<int> get totalListenedMs => $composableBuilder(
    column: $table.totalListenedMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPlayed => $composableBuilder(
    column: $table.lastPlayed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get skipCount =>
      $composableBuilder(column: $table.skipCount, builder: (column) => column);

  $$SongsTableAnnotationComposer get songId {
    final $$SongsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableAnnotationComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SongStatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SongStatsTable,
          SongStat,
          $$SongStatsTableFilterComposer,
          $$SongStatsTableOrderingComposer,
          $$SongStatsTableAnnotationComposer,
          $$SongStatsTableCreateCompanionBuilder,
          $$SongStatsTableUpdateCompanionBuilder,
          (SongStat, $$SongStatsTableReferences),
          SongStat,
          PrefetchHooks Function({bool songId})
        > {
  $$SongStatsTableTableManager(_$AppDatabase db, $SongStatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongStatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> songId = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<int> totalListenedMs = const Value.absent(),
                Value<DateTime?> lastPlayed = const Value.absent(),
                Value<int> skipCount = const Value.absent(),
              }) => SongStatsCompanion(
                songId: songId,
                playCount: playCount,
                totalListenedMs: totalListenedMs,
                lastPlayed: lastPlayed,
                skipCount: skipCount,
              ),
          createCompanionCallback:
              ({
                Value<int> songId = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<int> totalListenedMs = const Value.absent(),
                Value<DateTime?> lastPlayed = const Value.absent(),
                Value<int> skipCount = const Value.absent(),
              }) => SongStatsCompanion.insert(
                songId: songId,
                playCount: playCount,
                totalListenedMs: totalListenedMs,
                lastPlayed: lastPlayed,
                skipCount: skipCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SongStatsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({songId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (songId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.songId,
                                referencedTable: $$SongStatsTableReferences
                                    ._songIdTable(db),
                                referencedColumn: $$SongStatsTableReferences
                                    ._songIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SongStatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SongStatsTable,
      SongStat,
      $$SongStatsTableFilterComposer,
      $$SongStatsTableOrderingComposer,
      $$SongStatsTableAnnotationComposer,
      $$SongStatsTableCreateCompanionBuilder,
      $$SongStatsTableUpdateCompanionBuilder,
      (SongStat, $$SongStatsTableReferences),
      SongStat,
      PrefetchHooks Function({bool songId})
    >;
typedef $$LanguageTagsTableCreateCompanionBuilder =
    LanguageTagsCompanion Function({
      required String artistKey,
      required String primaryLanguage,
      required String languageScoresJson,
      required String source,
      Value<double> confidence,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$LanguageTagsTableUpdateCompanionBuilder =
    LanguageTagsCompanion Function({
      Value<String> artistKey,
      Value<String> primaryLanguage,
      Value<String> languageScoresJson,
      Value<String> source,
      Value<double> confidence,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LanguageTagsTableFilterComposer
    extends Composer<_$AppDatabase, $LanguageTagsTable> {
  $$LanguageTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get artistKey => $composableBuilder(
    column: $table.artistKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryLanguage => $composableBuilder(
    column: $table.primaryLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get languageScoresJson => $composableBuilder(
    column: $table.languageScoresJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LanguageTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $LanguageTagsTable> {
  $$LanguageTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get artistKey => $composableBuilder(
    column: $table.artistKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryLanguage => $composableBuilder(
    column: $table.primaryLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languageScoresJson => $composableBuilder(
    column: $table.languageScoresJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LanguageTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LanguageTagsTable> {
  $$LanguageTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get artistKey =>
      $composableBuilder(column: $table.artistKey, builder: (column) => column);

  GeneratedColumn<String> get primaryLanguage => $composableBuilder(
    column: $table.primaryLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get languageScoresJson => $composableBuilder(
    column: $table.languageScoresJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LanguageTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LanguageTagsTable,
          LanguageTag,
          $$LanguageTagsTableFilterComposer,
          $$LanguageTagsTableOrderingComposer,
          $$LanguageTagsTableAnnotationComposer,
          $$LanguageTagsTableCreateCompanionBuilder,
          $$LanguageTagsTableUpdateCompanionBuilder,
          (
            LanguageTag,
            BaseReferences<_$AppDatabase, $LanguageTagsTable, LanguageTag>,
          ),
          LanguageTag,
          PrefetchHooks Function()
        > {
  $$LanguageTagsTableTableManager(_$AppDatabase db, $LanguageTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LanguageTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LanguageTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LanguageTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> artistKey = const Value.absent(),
                Value<String> primaryLanguage = const Value.absent(),
                Value<String> languageScoresJson = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LanguageTagsCompanion(
                artistKey: artistKey,
                primaryLanguage: primaryLanguage,
                languageScoresJson: languageScoresJson,
                source: source,
                confidence: confidence,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String artistKey,
                required String primaryLanguage,
                required String languageScoresJson,
                required String source,
                Value<double> confidence = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LanguageTagsCompanion.insert(
                artistKey: artistKey,
                primaryLanguage: primaryLanguage,
                languageScoresJson: languageScoresJson,
                source: source,
                confidence: confidence,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LanguageTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LanguageTagsTable,
      LanguageTag,
      $$LanguageTagsTableFilterComposer,
      $$LanguageTagsTableOrderingComposer,
      $$LanguageTagsTableAnnotationComposer,
      $$LanguageTagsTableCreateCompanionBuilder,
      $$LanguageTagsTableUpdateCompanionBuilder,
      (
        LanguageTag,
        BaseReferences<_$AppDatabase, $LanguageTagsTable, LanguageTag>,
      ),
      LanguageTag,
      PrefetchHooks Function()
    >;
typedef $$UserCorrectionsTableCreateCompanionBuilder =
    UserCorrectionsCompanion Function({
      Value<int> id,
      required String rawArtistName,
      required String artistKey,
      required String predictedLanguage,
      required String correctedLanguage,
      Value<DateTime> correctedAt,
      Value<int> signalThatFired,
      Value<double> confidenceAtTime,
      Value<bool> appliedToSeeds,
    });
typedef $$UserCorrectionsTableUpdateCompanionBuilder =
    UserCorrectionsCompanion Function({
      Value<int> id,
      Value<String> rawArtistName,
      Value<String> artistKey,
      Value<String> predictedLanguage,
      Value<String> correctedLanguage,
      Value<DateTime> correctedAt,
      Value<int> signalThatFired,
      Value<double> confidenceAtTime,
      Value<bool> appliedToSeeds,
    });

class $$UserCorrectionsTableFilterComposer
    extends Composer<_$AppDatabase, $UserCorrectionsTable> {
  $$UserCorrectionsTableFilterComposer({
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

  ColumnFilters<String> get rawArtistName => $composableBuilder(
    column: $table.rawArtistName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistKey => $composableBuilder(
    column: $table.artistKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get predictedLanguage => $composableBuilder(
    column: $table.predictedLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get correctedLanguage => $composableBuilder(
    column: $table.correctedLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get correctedAt => $composableBuilder(
    column: $table.correctedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get signalThatFired => $composableBuilder(
    column: $table.signalThatFired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidenceAtTime => $composableBuilder(
    column: $table.confidenceAtTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get appliedToSeeds => $composableBuilder(
    column: $table.appliedToSeeds,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserCorrectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserCorrectionsTable> {
  $$UserCorrectionsTableOrderingComposer({
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

  ColumnOrderings<String> get rawArtistName => $composableBuilder(
    column: $table.rawArtistName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistKey => $composableBuilder(
    column: $table.artistKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get predictedLanguage => $composableBuilder(
    column: $table.predictedLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get correctedLanguage => $composableBuilder(
    column: $table.correctedLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get correctedAt => $composableBuilder(
    column: $table.correctedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get signalThatFired => $composableBuilder(
    column: $table.signalThatFired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidenceAtTime => $composableBuilder(
    column: $table.confidenceAtTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get appliedToSeeds => $composableBuilder(
    column: $table.appliedToSeeds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserCorrectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserCorrectionsTable> {
  $$UserCorrectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rawArtistName => $composableBuilder(
    column: $table.rawArtistName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get artistKey =>
      $composableBuilder(column: $table.artistKey, builder: (column) => column);

  GeneratedColumn<String> get predictedLanguage => $composableBuilder(
    column: $table.predictedLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get correctedLanguage => $composableBuilder(
    column: $table.correctedLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get correctedAt => $composableBuilder(
    column: $table.correctedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get signalThatFired => $composableBuilder(
    column: $table.signalThatFired,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidenceAtTime => $composableBuilder(
    column: $table.confidenceAtTime,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get appliedToSeeds => $composableBuilder(
    column: $table.appliedToSeeds,
    builder: (column) => column,
  );
}

class $$UserCorrectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserCorrectionsTable,
          UserCorrection,
          $$UserCorrectionsTableFilterComposer,
          $$UserCorrectionsTableOrderingComposer,
          $$UserCorrectionsTableAnnotationComposer,
          $$UserCorrectionsTableCreateCompanionBuilder,
          $$UserCorrectionsTableUpdateCompanionBuilder,
          (
            UserCorrection,
            BaseReferences<
              _$AppDatabase,
              $UserCorrectionsTable,
              UserCorrection
            >,
          ),
          UserCorrection,
          PrefetchHooks Function()
        > {
  $$UserCorrectionsTableTableManager(
    _$AppDatabase db,
    $UserCorrectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserCorrectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserCorrectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserCorrectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> rawArtistName = const Value.absent(),
                Value<String> artistKey = const Value.absent(),
                Value<String> predictedLanguage = const Value.absent(),
                Value<String> correctedLanguage = const Value.absent(),
                Value<DateTime> correctedAt = const Value.absent(),
                Value<int> signalThatFired = const Value.absent(),
                Value<double> confidenceAtTime = const Value.absent(),
                Value<bool> appliedToSeeds = const Value.absent(),
              }) => UserCorrectionsCompanion(
                id: id,
                rawArtistName: rawArtistName,
                artistKey: artistKey,
                predictedLanguage: predictedLanguage,
                correctedLanguage: correctedLanguage,
                correctedAt: correctedAt,
                signalThatFired: signalThatFired,
                confidenceAtTime: confidenceAtTime,
                appliedToSeeds: appliedToSeeds,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String rawArtistName,
                required String artistKey,
                required String predictedLanguage,
                required String correctedLanguage,
                Value<DateTime> correctedAt = const Value.absent(),
                Value<int> signalThatFired = const Value.absent(),
                Value<double> confidenceAtTime = const Value.absent(),
                Value<bool> appliedToSeeds = const Value.absent(),
              }) => UserCorrectionsCompanion.insert(
                id: id,
                rawArtistName: rawArtistName,
                artistKey: artistKey,
                predictedLanguage: predictedLanguage,
                correctedLanguage: correctedLanguage,
                correctedAt: correctedAt,
                signalThatFired: signalThatFired,
                confidenceAtTime: confidenceAtTime,
                appliedToSeeds: appliedToSeeds,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserCorrectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserCorrectionsTable,
      UserCorrection,
      $$UserCorrectionsTableFilterComposer,
      $$UserCorrectionsTableOrderingComposer,
      $$UserCorrectionsTableAnnotationComposer,
      $$UserCorrectionsTableCreateCompanionBuilder,
      $$UserCorrectionsTableUpdateCompanionBuilder,
      (
        UserCorrection,
        BaseReferences<_$AppDatabase, $UserCorrectionsTable, UserCorrection>,
      ),
      UserCorrection,
      PrefetchHooks Function()
    >;
typedef $$QueueStateTableCreateCompanionBuilder =
    QueueStateCompanion Function({
      Value<int> id,
      Value<String> songIdsJson,
      Value<int> currentIndex,
      Value<int> positionMs,
      Value<String> repeatMode,
      Value<bool> shuffleMode,
      Value<DateTime?> savedAt,
    });
typedef $$QueueStateTableUpdateCompanionBuilder =
    QueueStateCompanion Function({
      Value<int> id,
      Value<String> songIdsJson,
      Value<int> currentIndex,
      Value<int> positionMs,
      Value<String> repeatMode,
      Value<bool> shuffleMode,
      Value<DateTime?> savedAt,
    });

class $$QueueStateTableFilterComposer
    extends Composer<_$AppDatabase, $QueueStateTable> {
  $$QueueStateTableFilterComposer({
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

  ColumnFilters<String> get songIdsJson => $composableBuilder(
    column: $table.songIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get shuffleMode => $composableBuilder(
    column: $table.shuffleMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QueueStateTableOrderingComposer
    extends Composer<_$AppDatabase, $QueueStateTable> {
  $$QueueStateTableOrderingComposer({
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

  ColumnOrderings<String> get songIdsJson => $composableBuilder(
    column: $table.songIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get shuffleMode => $composableBuilder(
    column: $table.shuffleMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QueueStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $QueueStateTable> {
  $$QueueStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get songIdsJson => $composableBuilder(
    column: $table.songIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get shuffleMode => $composableBuilder(
    column: $table.shuffleMode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);
}

class $$QueueStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QueueStateTable,
          QueueStateData,
          $$QueueStateTableFilterComposer,
          $$QueueStateTableOrderingComposer,
          $$QueueStateTableAnnotationComposer,
          $$QueueStateTableCreateCompanionBuilder,
          $$QueueStateTableUpdateCompanionBuilder,
          (
            QueueStateData,
            BaseReferences<_$AppDatabase, $QueueStateTable, QueueStateData>,
          ),
          QueueStateData,
          PrefetchHooks Function()
        > {
  $$QueueStateTableTableManager(_$AppDatabase db, $QueueStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QueueStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QueueStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QueueStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> songIdsJson = const Value.absent(),
                Value<int> currentIndex = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<String> repeatMode = const Value.absent(),
                Value<bool> shuffleMode = const Value.absent(),
                Value<DateTime?> savedAt = const Value.absent(),
              }) => QueueStateCompanion(
                id: id,
                songIdsJson: songIdsJson,
                currentIndex: currentIndex,
                positionMs: positionMs,
                repeatMode: repeatMode,
                shuffleMode: shuffleMode,
                savedAt: savedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> songIdsJson = const Value.absent(),
                Value<int> currentIndex = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<String> repeatMode = const Value.absent(),
                Value<bool> shuffleMode = const Value.absent(),
                Value<DateTime?> savedAt = const Value.absent(),
              }) => QueueStateCompanion.insert(
                id: id,
                songIdsJson: songIdsJson,
                currentIndex: currentIndex,
                positionMs: positionMs,
                repeatMode: repeatMode,
                shuffleMode: shuffleMode,
                savedAt: savedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QueueStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QueueStateTable,
      QueueStateData,
      $$QueueStateTableFilterComposer,
      $$QueueStateTableOrderingComposer,
      $$QueueStateTableAnnotationComposer,
      $$QueueStateTableCreateCompanionBuilder,
      $$QueueStateTableUpdateCompanionBuilder,
      (
        QueueStateData,
        BaseReferences<_$AppDatabase, $QueueStateTable, QueueStateData>,
      ),
      QueueStateData,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      Value<String?> value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String?> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
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

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
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

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
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

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
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

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SongsTableTableManager get songs =>
      $$SongsTableTableManager(_db, _db.songs);
  $$PlaylistsTableTableManager get playlists =>
      $$PlaylistsTableTableManager(_db, _db.playlists);
  $$PlaylistEntriesTableTableManager get playlistEntries =>
      $$PlaylistEntriesTableTableManager(_db, _db.playlistEntries);
  $$PlayHistoryTableTableManager get playHistory =>
      $$PlayHistoryTableTableManager(_db, _db.playHistory);
  $$SongStatsTableTableManager get songStats =>
      $$SongStatsTableTableManager(_db, _db.songStats);
  $$LanguageTagsTableTableManager get languageTags =>
      $$LanguageTagsTableTableManager(_db, _db.languageTags);
  $$UserCorrectionsTableTableManager get userCorrections =>
      $$UserCorrectionsTableTableManager(_db, _db.userCorrections);
  $$QueueStateTableTableManager get queueState =>
      $$QueueStateTableTableManager(_db, _db.queueState);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
