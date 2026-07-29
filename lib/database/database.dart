// ============================================================
//  SONIQ — lib/database/database.dart
//  Drift 2.34+ | SQLite FTS5 | WAL Mode
// ============================================================

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// ============================================================
//  SECTION 1 — TABLE DEFINITIONS
// ============================================================

class Songs extends Table {
  IntColumn get id => integer()();
  TextColumn get path => text()();
  TextColumn get canonicalPath => text().withDefault(const Constant(''))();
  
  TextColumn get title => text().nullable()();
  TextColumn get artist => text().nullable()();
  TextColumn get album => text().nullable()();
  TextColumn get albumArtist => text().nullable()();
  
  IntColumn get trackNumber => integer().nullable()();
  IntColumn get discNumber => integer().nullable()();
  IntColumn get year => integer().nullable()();
  TextColumn get genre => text().nullable()();
  IntColumn get albumId => integer().nullable()();
  
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  IntColumn get size => integer().withDefault(const Constant(0))();
  IntColumn get dateAdded => integer().nullable()();
  
  // 🎯 THE FIX: High-precision nanosecond POSIX ctime (renamed to ctimeNs and made nullable)
  IntColumn get ctimeNs => integer().nullable()();
  IntColumn get firstSeen => integer().withDefault(const Constant(0))();

  BoolColumn get isAvailable => boolean().withDefault(const Constant(true))();
  TextColumn get languageTag => text().nullable()();
  RealColumn get classifierConfidence => real().withDefault(const Constant(0.0))();
  BoolColumn get wasManuallyTagged => boolean().withDefault(const Constant(false))();
  
  TextColumn get fileHash => text().nullable()();
  IntColumn get dateScanned => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Playlists extends Table {
  IntColumn      get id         => integer().autoIncrement()();
  TextColumn     get name       => text().withLength(min: 1, max: 255)();
  DateTimeColumn get createdAt  => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt  => dateTime().withDefault(currentDateAndTime)();
  BoolColumn     get isSystem   => boolean().withDefault(const Constant(false))();
  TextColumn     get systemType => text().nullable()();
}

class PlaylistEntries extends Table {
  IntColumn      get id         => integer().autoIncrement()();
  IntColumn      get playlistId => integer().references(Playlists, #id, onDelete: KeyAction.cascade)();
  IntColumn      get songId     => integer().references(Songs, #id, onDelete: KeyAction.cascade)();
  IntColumn      get position   => integer()();
  DateTimeColumn get addedAt    => dateTime().withDefault(currentDateAndTime)();
}

class PlayHistory extends Table {
  IntColumn      get id           => integer().autoIncrement()();
  IntColumn      get songId       => integer().references(Songs, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get playedAt     => dateTime().withDefault(currentDateAndTime)();
  IntColumn      get listenedMs   => integer().withDefault(const Constant(0))();
  BoolColumn     get counted      => boolean().withDefault(const Constant(false))();
  BoolColumn     get skippedEarly => boolean().withDefault(const Constant(false))();
}

class SongStats extends Table {
  IntColumn      get songId          => integer().references(Songs, #id, onDelete: KeyAction.cascade)();
  IntColumn      get playCount       => integer().withDefault(const Constant(0))();
  IntColumn      get totalListenedMs => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPlayed      => dateTime().nullable()();
  IntColumn      get skipCount       => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {songId};
}

class LanguageTags extends Table {
  TextColumn     get artistKey          => text()();
  TextColumn     get primaryLanguage    => text()();
  TextColumn     get languageScoresJson => text()();
  TextColumn     get source             => text()();
  RealColumn     get confidence         => real().withDefault(const Constant(0.70))();
  DateTimeColumn get updatedAt          => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {artistKey};
}

class UserCorrections extends Table {
  IntColumn      get id                => integer().autoIncrement()();
  TextColumn     get rawArtistName     => text()();
  TextColumn     get artistKey         => text()();
  TextColumn     get predictedLanguage => text()();
  TextColumn     get correctedLanguage => text()();
  DateTimeColumn get correctedAt       => dateTime().withDefault(currentDateAndTime)();
  IntColumn      get signalThatFired   => integer().withDefault(const Constant(0))();
  RealColumn     get confidenceAtTime  => real().withDefault(const Constant(0.0))();
  BoolColumn     get appliedToSeeds    => boolean().withDefault(const Constant(false))();
}

class QueueState extends Table {
  IntColumn      get id           => integer()();
  TextColumn     get songIdsJson  => text().withDefault(const Constant('[]'))();
  IntColumn      get currentIndex => integer().withDefault(const Constant(0))();
  IntColumn      get positionMs   => integer().withDefault(const Constant(0))();
  TextColumn     get repeatMode   => text().withDefault(const Constant('none'))();
  BoolColumn     get shuffleMode  => boolean().withDefault(const Constant(false))();
  DateTimeColumn get savedAt      => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class AppSettings extends Table {
  TextColumn get key   => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}

// ============================================================
//  SECTION 2 — DATA ACCESS OBJECTS
// ============================================================

class LibraryStats {
  final int trackCount;
  final int albumCount;
  final int artistCount;
  final int totalDurationMs;

  const LibraryStats({
    this.trackCount = 0,
    this.albumCount = 0,
    this.artistCount = 0,
    this.totalDurationMs = 0,
  });
}

@DriftAccessor(tables: [Songs, SongStats])
class SongsDao extends DatabaseAccessor<AppDatabase> with _$SongsDaoMixin {
  SongsDao(super.db);

  Stream<List<Song>> watchAllAvailable() =>
      (select(songs)
        ..where((s) => s.isAvailable.equals(true))
        ..orderBy([(s) => OrderingTerm.asc(s.title)]))
          .watch();

  Stream<int> getTotalSongsCount() =>
      (select(songs)..where((s) => s.isAvailable.equals(true)))
      .watch()
      .map((list) => list.length);

  Stream<int> getTotalAlbumsCount() =>
      (selectOnly(songs, distinct: true)
        ..addColumns([songs.album])
        ..where(songs.isAvailable.equals(true) & songs.album.isNotNull()))
      .watch()
      .map((list) => list.length);

  Stream<int> getTotalArtistsCount() =>
      (selectOnly(songs, distinct: true)
        ..addColumns([songs.artist])
        ..where(songs.isAvailable.equals(true) & songs.artist.isNotNull()))
      .watch()
      .map((list) => list.length);

  Stream<LibraryStats> watchLibraryStats() {
    final trackCount = songs.id.count();
    final albumCount = songs.album.count(distinct: true);
    final artistCount = songs.artist.count(distinct: true);
    final totalDuration = songs.durationMs.sum();

    final query = selectOnly(songs)
      ..addColumns([trackCount, albumCount, artistCount, totalDuration])
      ..where(songs.isAvailable.equals(true));

    return query.watchSingle().map((row) {
      return LibraryStats(
        trackCount: row.read(trackCount) ?? 0,
        albumCount: row.read(albumCount) ?? 0,
        artistCount: row.read(artistCount) ?? 0,
        totalDurationMs: row.read(totalDuration) ?? 0,
      );
    });
  }

  Future<Song?> getSongById(int id) =>
      (select(songs)..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<List<Song>> getSongsByArtist(String artist) =>
      (select(songs)
        ..where((s) => s.artist.equals(artist) & s.isAvailable.equals(true))
        ..orderBy([(s) => OrderingTerm.asc(s.trackNumber)]))
          .get();

  Future<List<Song>> getSongsByAlbum(int albumId) =>
      (select(songs)
        ..where((s) => s.albumId.equals(albumId) & s.isAvailable.equals(true))
        ..orderBy([
          (s) => OrderingTerm.asc(s.discNumber),
          (s) => OrderingTerm.asc(s.trackNumber),
        ]))
          .get();

  Future<List<Song>> getSongsByLanguage(String language) =>
      (select(songs)
        ..where((s) => s.languageTag.equals(language) & s.isAvailable.equals(true)))
          .get();

  Future<List<Song>> getUnclassifiedSongs() =>
      (select(songs)
        ..where((s) =>
            (s.languageTag.isNull() | 
             s.languageTag.equals('und') | 
             s.languageTag.equals('unclassified') | 
             s.languageTag.equals('UNCLASSIFIED')) & 
            s.isAvailable.equals(true)))
          .get();

  Future<List<Song>> getSongsInDirectory(String directoryPath) =>
      (select(songs)..where((s) => s.path.like('$directoryPath/%'))).get();

  Future<List<Song>> searchSongs(String query) async {
    if (query.trim().isEmpty) return [];

    final sanitized = query
        .trim()
        .replaceAll('"', '')
        .replaceAll("'", '')
        .replaceAll('*', '')
        .replaceAll('-', ' ');
    final prefixQuery = '$sanitized*';

    final rows = await customSelect(
      '''
      SELECT s.* FROM songs s
      INNER JOIN song_search ss ON s.id = ss.rowid
      WHERE ss.song_search MATCH ?
        AND s.is_available = 1
      ORDER BY ss.rank
      LIMIT 200
      ''',
      variables: [Variable<String>(prefixQuery)],
      readsFrom: {songs},
    ).get();

    List<Song> results = [];
    for (final row in rows) {
      results.add(await songs.mapFromRow(row));
    }
    return results;
  }
  
  Future<List<String>> getAllArtists() async {
    final query = selectOnly(songs, distinct: true)
      ..addColumns([songs.artist])
      ..where(songs.isAvailable.equals(true) & songs.artist.isNotNull())
      ..orderBy([OrderingTerm.asc(songs.artist)]);
    final rows = await query.get();
    return rows.map((r) => r.read(songs.artist)).whereType<String>().toList();
  }

  Future<List<String>> getClassifiedLanguages() async {
    final query = selectOnly(songs, distinct: true)
      ..addColumns([songs.languageTag])
      ..where(songs.languageTag.isNotNull() & songs.isAvailable.equals(true));
    final rows = await query.get();
    return rows.map((r) => r.read(songs.languageTag)).whereType<String>().toList();
  }

  Future<int> getTotalSongCount() async {
    final count = countAll(filter: songs.isAvailable.equals(true));
    final query = selectOnly(songs)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<void> upsertSongs(List<SongsCompanion> companions) =>
      batch((b) => b.insertAllOnConflictUpdate(songs, companions));

  Future<void> markUnavailable(List<int> ids) =>
      (update(songs)..where((s) => s.id.isIn(ids))).write(
        const SongsCompanion(isAvailable: Value(false)),
      );

  Future<void> autoClassify(int songId, String language, double confidence) async {
    final song = await getSongById(songId);
    if (song == null || song.wasManuallyTagged) return;
    await (update(songs)..where((s) => s.id.equals(songId))).write(
      SongsCompanion(
        languageTag: Value(language),
        classifierConfidence: Value(confidence),
        wasManuallyTagged: const Value(false),
      ),
    );
  }

  Future<void> manuallyTag(int songId, String language) =>
      (update(songs)..where((s) => s.id.equals(songId))).write(
        SongsCompanion(
          languageTag: Value(language),
          classifierConfidence: const Value(1.0),
          wasManuallyTagged: const Value(true),
        ),
      );

  Future<void> healMissingDuration(int songId, int trueDurationMs) async {
    if (trueDurationMs <= 0) return;
    final song = await getSongById(songId);
    if (song != null && (song.durationMs == null || song.durationMs == 0)) {
      await (update(songs)..where((s) => s.id.equals(songId))).write(
        SongsCompanion(durationMs: Value(trueDurationMs)),
      );
    }
  }
}

@DriftAccessor(tables: [Playlists, PlaylistEntries, Songs])
class PlaylistsDao extends DatabaseAccessor<AppDatabase> with _$PlaylistsDaoMixin {
  PlaylistsDao(super.db);

  static const int favoritesId      = 1;
  static const int recentlyPlayedId = 2;
  static const int top50Id          = 3;

  Stream<List<Playlist>> watchAllUserPlaylists() =>
      (select(playlists)
        ..where((p) => p.isSystem.equals(false))
        ..orderBy([(p) => OrderingTerm.asc(p.name)]))
          .watch();

  Stream<List<Song>> watchSongsForPlaylist(int playlistId) {
    final query = select(playlistEntries).join([
      innerJoin(songs, songs.id.equalsExp(playlistEntries.songId)),
    ])
      ..where(playlistEntries.playlistId.equals(playlistId))
      ..orderBy([OrderingTerm.asc(playlistEntries.position)]);
    return query.watch().map((rows) => rows.map((r) => r.readTable(songs)).toList());
  }

  Stream<bool> watchIsFavorite(int songId) {
    final query = select(playlistEntries)
      ..where((e) => e.playlistId.equals(favoritesId) & e.songId.equals(songId));
    return query.watch().map((rows) => rows.isNotEmpty);
  }

  Future<List<Song>> getSongsForPlaylist(int playlistId) async {
    final query = select(playlistEntries).join([
      innerJoin(songs, songs.id.equalsExp(playlistEntries.songId)),
    ])
      ..where(playlistEntries.playlistId.equals(playlistId))
      ..orderBy([OrderingTerm.asc(playlistEntries.position)]);
    final rows = await query.get();
    return rows.map((r) => r.readTable(songs)).toList();
  }

  Future<List<int>> getUnavailableEntryIds(int playlistId) async {
    final query = select(playlistEntries).join([
      innerJoin(songs, songs.id.equalsExp(playlistEntries.songId)),
    ])
      ..where(playlistEntries.playlistId.equals(playlistId) & songs.isAvailable.equals(false));
    final rows = await query.get();
    return rows.map((r) => r.readTable(playlistEntries).id).toList();
  }

  Future<int> createPlaylist(String name) =>
      into(playlists).insert(PlaylistsCompanion(name: Value(name)));

  Future<void> renamePlaylist(int id, String newName) =>
      (update(playlists)..where((p) => p.id.equals(id) & p.isSystem.equals(false)))
          .write(PlaylistsCompanion(name: Value(newName)));

  Future<int> deletePlaylist(int id) =>
      (delete(playlists)..where((p) => p.id.equals(id) & p.isSystem.equals(false))).go();

  Future<void> addSongToPlaylist(int playlistId, int songId) async {
    final maxPos = await _getMaxPosition(playlistId);
    await into(playlistEntries).insert(
      PlaylistEntriesCompanion(
        playlistId: Value(playlistId),
        songId: Value(songId),
        position: Value(maxPos + 1),
      ),
    );
    await _touchPlaylist(playlistId);
  }

  Future<void> removeSongFromPlaylist(int entryId) async {
      await (delete(playlistEntries)..where((e) => e.id.equals(entryId))).go();
  }

  Future<void> reorderSong(int playlistId, int entryId, int newPosition) =>
      transaction(() async {
        await (update(playlistEntries)..where((e) => e.id.equals(entryId)))
            .write(PlaylistEntriesCompanion(position: Value(newPosition)));
        await _touchPlaylist(playlistId);
      });

  Future<void> toggleFavorite(int songId) async {
    final existing = await (select(playlistEntries)
          ..where((e) => e.playlistId.equals(favoritesId) & e.songId.equals(songId)))
        .getSingleOrNull();
    if (existing != null) {
      await (delete(playlistEntries)..where((e) => e.id.equals(existing.id))).go();
    } else {
      await addSongToPlaylist(favoritesId, songId);
    }
  }

  Future<int> _getMaxPosition(int playlistId) async {
    final maxExpr = playlistEntries.position.max();
    final query = selectOnly(playlistEntries)
      ..addColumns([maxExpr])
      ..where(playlistEntries.playlistId.equals(playlistId));
    final row = await query.getSingleOrNull();
    return row?.read(maxExpr) ?? 0;
  }

  Future<void> _touchPlaylist(int id) =>
      (update(playlists)..where((p) => p.id.equals(id))).write(
        PlaylistsCompanion(updatedAt: Value(DateTime.now())),
      );
}

@DriftAccessor(tables: [PlayHistory, SongStats, Songs, Playlists, PlaylistEntries])
class HistoryDao extends DatabaseAccessor<AppDatabase> with _$HistoryDaoMixin {
  HistoryDao(super.db);

  Future<int> _getSystemPlaylistId(String systemType, String defaultName) async {
    final playlist = await (select(playlists)..where((p) => p.systemType.equals(systemType))).getSingleOrNull();
    if (playlist != null) return playlist.id;

    return await into(playlists).insert(
      PlaylistsCompanion(
        name: Value(defaultName),
        isSystem: const Value(true),
        systemType: Value(systemType),
      ),
    );
  }

  Future<void> recordPlay({
    required int songId,
    required int listenedMs,
    required bool counted,
    required bool skippedEarly,
  }) async {
    final recentlyPlayedId = await _getSystemPlaylistId('recently_played', 'Recently Played');
    final top50Id = await _getSystemPlaylistId('top50', 'Top 50');

    await transaction(() async {
      await into(playHistory).insert(
        PlayHistoryCompanion(
          songId: Value(songId),
          playedAt: Value(DateTime.now()),
          listenedMs: Value(listenedMs),
          counted: Value(counted),
          skippedEarly: Value(skippedEarly),
        ),
      );

      if (counted) {
        final existingStat = await (select(songStats)..where((s) => s.songId.equals(songId))).getSingleOrNull();
        if (existingStat == null) {
          await into(songStats).insert(
            SongStatsCompanion(
              songId: Value(songId),
              playCount: const Value(1),
              totalListenedMs: Value(listenedMs),
              lastPlayed: Value(DateTime.now()),
            ),
          );
        } else {
          await (update(songStats)..where((s) => s.songId.equals(songId))).write(
            SongStatsCompanion(
              playCount: Value(existingStat.playCount + 1),
              totalListenedMs: Value(existingStat.totalListenedMs + listenedMs),
              lastPlayed: Value(DateTime.now()),
            ),
          );
        }
      }
    });

    if (counted) {
      _refreshTop50(top50Id).ignore();
    }
    _updateRecentlyPlayed(recentlyPlayedId, songId).ignore();
  }

  Stream<List<Song>> watchTop50() {
    final query = select(songStats).join([
      innerJoin(songs, songs.id.equalsExp(songStats.songId)),
    ])
      ..where(songs.isAvailable.equals(true))
      ..orderBy([OrderingTerm.desc(songStats.playCount)])
      ..limit(50);
    return query.watch().map((rows) => rows.map((r) => r.readTable(songs)).toList());
  }

  Stream<List<Song>> watchRecentlyPlayed({int limit = 30}) {
    final query = select(playlistEntries).join([
      innerJoin(songs, songs.id.equalsExp(playlistEntries.songId)),
      innerJoin(playlists, playlists.id.equalsExp(playlistEntries.playlistId)),
    ])
      ..where(playlists.systemType.equals('recently_played') & songs.isAvailable.equals(true))
      ..orderBy([OrderingTerm.asc(playlistEntries.position)])
      ..limit(limit);
    return query.watch().map((rows) => rows.map((r) => r.readTable(songs)).toList());
  }

  Future<SongStat?> getStatsForSong(int songId) =>
      (select(songStats)..where((s) => s.songId.equals(songId))).getSingleOrNull();

  Future<Duration> getTotalListeningTime() async {
    final sum = songStats.totalListenedMs.sum();
    final query = selectOnly(songStats)..addColumns([sum]);
    final row = await query.getSingleOrNull();
    return Duration(milliseconds: row?.read(sum) ?? 0);
  }

  Future<void> _refreshTop50(int top50Id) async {
    final top50Songs = await (select(songStats)
          ..where((s) => s.playCount.isBiggerThanValue(0))
          ..orderBy([(s) => OrderingTerm.desc(s.playCount)])
          ..limit(50))
        .get();
    
    await (delete(playlistEntries)..where((e) => e.playlistId.equals(top50Id))).go();
        
    final newEntries = <PlaylistEntriesCompanion>[];
    for (var i = 0; i < top50Songs.length; i++) {
      newEntries.add(
        PlaylistEntriesCompanion(
          playlistId: Value(top50Id),
          songId: Value(top50Songs[i].songId),
          position: Value(i + 1),
        ),
      );
    }
    if (newEntries.isNotEmpty) {
      await batch((batch) => batch.insertAll(playlistEntries, newEntries));
    }
  }

  Future<void> _updateRecentlyPlayed(int recentlyPlayedId, int songId) async {
    await (delete(playlistEntries)
          ..where((e) => e.playlistId.equals(recentlyPlayedId) & e.songId.equals(songId)))
        .go();
    
    final entries = await (select(playlistEntries)
      ..where((e) => e.playlistId.equals(recentlyPlayedId))
      ..orderBy([(e) => OrderingTerm.asc(e.position)])).get();

    for (var e in entries) {
      await (update(playlistEntries)..where((tbl) => tbl.id.equals(e.id))).write(
        PlaylistEntriesCompanion(position: Value(e.position + 1)),
      );
    }

    await into(playlistEntries).insert(
      PlaylistEntriesCompanion(
        playlistId: Value(recentlyPlayedId),
        songId: Value(songId),
        position: const Value(1),
      ),
    );

    if (entries.length >= 100) {
      final toDelete = await (select(playlistEntries)
        ..where((e) => e.playlistId.equals(recentlyPlayedId))
        ..orderBy([(e) => OrderingTerm.asc(e.position)])
        ..limit(1000, offset: 100)).get();

      for (var e in toDelete) {
        await (delete(playlistEntries)..where((tbl) => tbl.id.equals(e.id))).go();
      }
    }
  }
}

class _VoteEntry {
  final String language;
  final int votes;
  final int totalVotes;
  const _VoteEntry(this.language, this.votes, this.totalVotes);
}

@DriftAccessor(tables: [LanguageTags, UserCorrections])
class LanguageDao extends DatabaseAccessor<AppDatabase> with _$LanguageDaoMixin {
  LanguageDao(super.db);

  Future<void> logCorrection(Insertable<UserCorrection> correction) async {
    await into(userCorrections).insert(correction);
  }

  Future<LanguageTag?> lookupArtist(String artistKey) async {
    return await (select(languageTags)..where((t) => t.artistKey.equals(artistKey))).getSingleOrNull();
  }

  Future<void> applyPendingCorrections() async {
    final allVotes = await customSelect(
      '''
      SELECT 
        artist_key,
        corrected_language,
        COUNT(*) as vote_count,
        SUM(COUNT(*) OVER (PARTITION BY artist_key)) as total_votes
      FROM user_corrections
      WHERE applied_to_seeds = 0
      GROUP BY artist_key, corrected_language
      '''
      ,
      readsFrom: {userCorrections},
    ).get();

    if (allVotes.isEmpty) return;

    final byArtist = <String, List<_VoteEntry>>{};
    for (final row in allVotes) {
      final artist = row.read<String>('artist_key');
      final lang   = row.read<String>('corrected_language');
      final votes  = row.read<int>('vote_count');
      final total  = row.read<int>('total_votes');
      (byArtist[artist] ??= []).add(_VoteEntry(lang, votes, total));
    }

    final promotedArtistKeys = <String>[];

    await transaction(() async {
      for (final entry in byArtist.entries) {
        final artistKey = entry.key;
        final votes = entry.value..sort((a, b) => b.votes.compareTo(a.votes));

        final top = votes.first;
        final ratio = top.votes / top.totalVotes;

        if (top.votes < 3 || ratio < 0.60) continue;

        await into(languageTags).insertOnConflictUpdate(
          LanguageTagsCompanion.insert(
            artistKey:          artistKey,
            primaryLanguage:    top.language,
            languageScoresJson: '{"${top.language}": 0.85}', 
            source:             'user_correction',           
            confidence:         const Value(0.85),
            updatedAt:          Value(DateTime.now()),
          ),
        );

        promotedArtistKeys.add(artistKey);
      }

      if (promotedArtistKeys.isNotEmpty) {
        final placeholders = promotedArtistKeys.map((_) => '?').join(', ');
        await customUpdate(
          '''
          UPDATE user_corrections
          SET applied_to_seeds = 1
          WHERE applied_to_seeds = 0
            AND artist_key IN ($placeholders)
          ''',
          variables: promotedArtistKeys.map((k) => Variable<String>(k)).toList(),
          updates: {userCorrections},
        );
      }
    });

    if (promotedArtistKeys.isNotEmpty) {
      print('applyPendingCorrections: promoted ${promotedArtistKeys.length} artists: $promotedArtistKeys');
    }
  }
}

@DriftAccessor(tables: [AppSettings, QueueState])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<String?> getSetting(String key) async {
    final row = await (select(appSettings)..where((s) => s.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String? value) =>
      into(appSettings).insertOnConflictUpdate(
        AppSettingsCompanion(key: Value(key), value: Value(value)),
      );

  Future<void> saveQueueState({
    required String songIdsJson,
    required int currentIndex,
    required int positionMs,
    required String repeatMode,
    required bool shuffleMode,
  }) =>
      into(queueState).insertOnConflictUpdate(
        QueueStateCompanion(
          id: const Value(1),
          songIdsJson: Value(songIdsJson),
          currentIndex: Value(currentIndex),
          positionMs: Value(positionMs),
          repeatMode: Value(repeatMode),
          shuffleMode: Value(shuffleMode),
          savedAt: Value(DateTime.now()),
        ),
      );

  Future<QueueStateData?> loadQueueState() =>
      (select(queueState)..where((q) => q.id.equals(1))).getSingleOrNull();
}

// ============================================================
//  SECTION 3 — DATABASE CLASS
// ============================================================

@DriftDatabase(
  tables: [
    Songs, Playlists, PlaylistEntries, PlayHistory,
    SongStats, LanguageTags, UserCorrections, QueueState, AppSettings,
  ],
  daos: [
    SongsDao, PlaylistsDao, HistoryDao, LanguageDao, SettingsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

Future<void> insertSongsBatch(dynamic rawInput) async {
    final existingDurations = <int, int>{};
    final currentSongs = await select(songs).get();
    for (final s in currentSongs) {
      existingDurations[s.id] = s.durationMs;
    }

    await batch((b) {
      if (rawInput is List<SongsCompanion>) {
        b.insertAllOnConflictUpdate(songs, rawInput);
      } else if (rawInput is List<Map<String, dynamic>>) {
        final companions = rawInput.map((raw) {
          final rawId = int.tryParse(raw['id']?.toString() ?? '0') ?? 0;
          final rawTitle = raw['title']?.toString();
          final safeTitle = (rawTitle != null && rawTitle.isNotEmpty) ? rawTitle : 'Unknown Track';
          
          String? parsedAlbum = raw['album']?.toString();
          if (parsedAlbum == null || parsedAlbum.trim().isEmpty || parsedAlbum.toLowerCase() == '<unknown>') {
             parsedAlbum = '$safeTitle (Single)';
          }

          int finalAlbumId = int.tryParse(raw['album_id']?.toString() ?? '0') ?? 0;
          if (finalAlbumId == 0) {
             finalAlbumId = parsedAlbum.hashCode;
          }

          int finalDuration = 0;
          final rawVal = int.tryParse(raw['duration']?.toString() ?? '') ?? 0;
          if (rawVal > 0) {
            finalDuration = rawVal < 10000 ? rawVal * 1000 : rawVal;
          } else if (existingDurations.containsKey(rawId) && existingDurations[rawId]! > 0) {
            finalDuration = existingDurations[rawId]!; 
          }

          return SongsCompanion(
            id: Value(rawId),
            title: Value(safeTitle),
            artist: Value(raw['artist']?.toString() ?? 'Unknown Artist'),
            album: Value(parsedAlbum), 
            path: Value(raw['data_uri']?.toString() ?? raw['path']?.toString() ?? ''), 
            albumId: Value(finalAlbumId), 
            durationMs: Value(finalDuration),
            dateAdded: Value(int.tryParse(raw['dateAddedSec']?.toString() ?? '') ?? DateTime.now().millisecondsSinceEpoch),
            // 🎯 THE FIX: Correctly map the nanosecond property from Map payloads
            ctimeNs: Value(int.tryParse(raw['ctimeNs']?.toString() ?? '')),
          );
        }).toList();

        b.insertAllOnConflictUpdate(songs, companions);
      }
    });
  }
  
  // 🎯 THE FIX: Bumped schema version to 4 to trigger the column addition
  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();

      await customStatement('''
        CREATE VIRTUAL TABLE IF NOT EXISTS song_search
        USING fts5(
          title,
          artist,
          album,
          content="songs",
          content_rowid="id",
          tokenize="unicode61 remove_diacritics 2"
        );
      ''');

      await customStatement('''
        CREATE TRIGGER IF NOT EXISTS songs_ai
        AFTER INSERT ON songs BEGIN
          INSERT INTO song_search(rowid, title, artist, album)
          VALUES (new.id, new.title, new.artist, new.album);
        END;
      ''');

      await customStatement('''
        CREATE TRIGGER IF NOT EXISTS songs_ad
        AFTER DELETE ON songs BEGIN
          INSERT INTO song_search(song_search, rowid, title, artist, album)
          VALUES ('delete', old.id, old.title, old.artist, old.album);
        END;
      ''');

      await customStatement('''
        CREATE TRIGGER IF NOT EXISTS songs_au
        AFTER UPDATE OF title, artist, album ON songs BEGIN
          INSERT INTO song_search(song_search, rowid, title, artist, album)
          VALUES ('delete', old.id, old.title, old.artist, old.album);
          INSERT INTO song_search(rowid, title, artist, album)
          VALUES (new.id, new.title, new.artist, new.album);
        END;
      ''');

      await customStatement('''
        CREATE INDEX IF NOT EXISTS idx_songs_language
        ON songs(language_tag)
        WHERE language_tag IS NOT NULL;
      ''');
      await customStatement('''
        CREATE INDEX IF NOT EXISTS idx_songs_date_added
        ON songs(date_added DESC);
      ''');
      await customStatement('''
        CREATE INDEX IF NOT EXISTS idx_songs_path
        ON songs(path);
      ''');
      await customStatement('''
        CREATE INDEX IF NOT EXISTS idx_songs_artist
        ON songs(artist)
        WHERE artist IS NOT NULL;
      ''');
      await customStatement('''
        CREATE INDEX IF NOT EXISTS idx_playlist_entries_position
        ON playlist_entries(playlist_id, position);
      ''');
      await customStatement('''
        CREATE INDEX IF NOT EXISTS idx_play_history_played_at
        ON play_history(song_id, played_at DESC);
      ''');
      await customStatement('''
        CREATE INDEX IF NOT EXISTS idx_song_stats_play_count
        ON song_stats(play_count DESC);
      ''');

      await customStatement('''
        INSERT OR IGNORE INTO playlists
          (id, name, is_system, system_type, created_at, updated_at)
        VALUES
          (1, 'Favorites',       1, 'favorites',
           strftime('%s','now'), strftime('%s','now')),
          (2, 'Recently Played', 1, 'recently_played',
           strftime('%s','now'), strftime('%s','now')),
          (3, 'Top 50',          1, 'top50',
           strftime('%s','now'), strftime('%s','now'));
      ''');
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.addColumn(songs, songs.size);
        await m.addColumn(songs, songs.canonicalPath);
        await m.addColumn(songs, songs.firstSeen);
      }
      if (from < 4) {
        // 🎯 THE FIX: Safely add the new column to existing databases
        await m.addColumn(songs, songs.ctimeNs);
      }
    },
  );
}

// ============================================================
//  SECTION 4 — CONNECTION FACTORY
// ============================================================

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'soniq_db.sqlite'));

    return NativeDatabase.createInBackground(
      file,
      setup: (rawDb) {
        rawDb.execute('PRAGMA journal_mode=WAL;');
        rawDb.execute('PRAGMA foreign_keys=ON;');
        rawDb.execute('PRAGMA synchronous=NORMAL;');
        rawDb.execute('PRAGMA cache_size=-20000;');
        rawDb.execute('PRAGMA temp_store=MEMORY;');
        rawDb.execute('PRAGMA mmap_size=268435456;');
        rawDb.execute('PRAGMA wal_autocheckpoint=100;');
      },
    );
  });
}