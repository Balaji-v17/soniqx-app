// ============================================================
//  SONIQ — lib/database/database.dart
//  Drift 2.34+ | SQLite FTS5 | WAL Mode | July 2026
//
//  After any edit to this file run:
//  dart run build_runner build --delete-conflicting-outputs
//
//  pubspec.yaml dependencies required:
//    drift: ^2.34.0
//    drift_flutter: ^0.3.1
//    sqlite3_flutter_libs: ^0.5.0
//    path_provider: ^2.1.5
//    path: ^1.9.0
//
//  dev_dependencies required:
//    drift_dev: ^2.34.0
//    build_runner: ^2.15.0
//
//  build.yaml required (FTS5 module):
//    targets:
//      $default:
//        builders:
//          drift_dev:
//            options:
//              sql:
//                dialect: sqlite
//                options:
//                  modules: [fts5]
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

// ─── 1.1  Songs ─────────────────────────────────────────────
class Songs extends Table {
  IntColumn get id            => integer()();
  TextColumn get title        => text().nullable()();
  TextColumn get artist       => text().nullable()();
  TextColumn get album        => text().nullable()();
  TextColumn get albumArtist  => text().nullable()();
  IntColumn  get durationMs   => integer().nullable()();
  IntColumn  get trackNumber  => integer().nullable()();
  IntColumn  get discNumber   => integer().nullable()();
  IntColumn  get year         => integer().nullable()();
  TextColumn get genre        => text().nullable()();
  TextColumn get path         => text()();
  IntColumn  get albumId      => integer()();
  IntColumn  get dateAdded    => integer()();
  TextColumn get fileHash     => text().nullable()();
  BoolColumn get isAvailable  => boolean().withDefault(const Constant(true))();
  TextColumn get languageTag  => text().nullable()();
  RealColumn get classifierConfidence =>
      real().withDefault(const Constant(0.0))();
  BoolColumn get wasManuallyTagged =>
      boolean().withDefault(const Constant(false))();
  IntColumn  get dateScanned  => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── 1.2  Playlists ─────────────────────────────────────────
class Playlists extends Table {
  IntColumn      get id         => integer().autoIncrement()();
  TextColumn     get name       => text().withLength(min: 1, max: 255)();
  DateTimeColumn get createdAt  =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt  =>
      dateTime().withDefault(currentDateAndTime)();
  BoolColumn     get isSystem   =>
      boolean().withDefault(const Constant(false))();
  TextColumn     get systemType => text().nullable()();
}

// ─── 1.3  PlaylistEntries ────────────────────────────────────
class PlaylistEntries extends Table {
  IntColumn      get id         => integer().autoIncrement()();
  IntColumn      get playlistId => integer().references(
      Playlists, #id, onDelete: KeyAction.cascade)();
  IntColumn      get songId     => integer().references(
      Songs, #id, onDelete: KeyAction.cascade)();
  IntColumn      get position   => integer()();
  DateTimeColumn get addedAt    =>
      dateTime().withDefault(currentDateAndTime)();
}

// ─── 1.4  PlayHistory ────────────────────────────────────────
// ONE ROW PER PLAY EVENT — not one row per song.
class PlayHistory extends Table {
  IntColumn      get id            => integer().autoIncrement()();
  IntColumn      get songId        => integer().references(
      Songs, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get playedAt      =>
      dateTime().withDefault(currentDateAndTime)();
  IntColumn      get listenedMs    =>
      integer().withDefault(const Constant(0))();
  BoolColumn     get counted       =>
      boolean().withDefault(const Constant(false))();
  BoolColumn     get skippedEarly  =>
      boolean().withDefault(const Constant(false))();
}

// ─── 1.5  SongStats ─────────────────────────────────────────
// Aggregated stats per song — drives Top 50 screen.
class SongStats extends Table {
  IntColumn      get songId          => integer().references(
      Songs, #id, onDelete: KeyAction.cascade)();
  IntColumn      get playCount       =>
      integer().withDefault(const Constant(0))();
  IntColumn      get totalListenedMs =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPlayed      => dateTime().nullable()();
  IntColumn      get skipCount       =>
      integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {songId};
}

// ─── 1.6  LanguageTags ──────────────────────────────────────
// Artist → language seed database for Phase 6 classifier.
class LanguageTags extends Table {
  TextColumn     get artistKey          => text()();
  TextColumn     get primaryLanguage    => text()();
  TextColumn     get languageScoresJson => text()();
  TextColumn     get source             => text()();
  RealColumn     get confidence         =>
      real().withDefault(const Constant(0.70))();
  DateTimeColumn get updatedAt          =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {artistKey};
}

// ─── 1.7  UserCorrections ───────────────────────────────────
// Classifier feedback loop — 3+ corrections promote to LanguageTags.
class UserCorrections extends Table {
  IntColumn      get id                => integer().autoIncrement()();
  TextColumn     get rawArtistName     => text()();
  TextColumn     get artistKey         => text()();
  TextColumn     get predictedLanguage => text()();
  TextColumn     get correctedLanguage => text()();
  DateTimeColumn get correctedAt       =>
      dateTime().withDefault(currentDateAndTime)();
  IntColumn      get signalThatFired   =>
      integer().withDefault(const Constant(0))();
  RealColumn     get confidenceAtTime  =>
      real().withDefault(const Constant(0.0))();
  BoolColumn     get appliedToSeeds    =>
      boolean().withDefault(const Constant(false))();
}

// ─── 1.8  QueueState ────────────────────────────────────────
// Persists playback queue so it survives app kills.
class QueueState extends Table {
  IntColumn      get id           => integer()();
  TextColumn     get songIdsJson  =>
      text().withDefault(const Constant('[]'))();
  IntColumn      get currentIndex =>
      integer().withDefault(const Constant(0))();
  IntColumn      get positionMs   =>
      integer().withDefault(const Constant(0))();
  TextColumn     get repeatMode   =>
      text().withDefault(const Constant('none'))();
  BoolColumn     get shuffleMode  =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get savedAt      => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── 1.9  AppSettings ───────────────────────────────────────
// Generic key-value store for settings that survive backup/restore.
class AppSettings extends Table {
  TextColumn get key   => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}

// ============================================================
//  SECTION 2 — DATA ACCESS OBJECTS
// ============================================================

// ─── 2.1  SongsDao ──────────────────────────────────────────
@DriftAccessor(tables: [Songs, SongStats])
class SongsDao extends DatabaseAccessor<AppDatabase>
    with _$SongsDaoMixin {
  SongsDao(super.db);

  // ── Streams ──────────────────────────────────────────────

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

  // ── Queries ──────────────────────────────────────────────

  Future<Song?> getSongById(int id) =>
      (select(songs)..where((s) => s.id.equals(id)))
          .getSingleOrNull();

  Future<List<Song>> getSongsByArtist(String artist) =>
      (select(songs)
        ..where((s) =>
            s.artist.equals(artist) & s.isAvailable.equals(true))
        ..orderBy([(s) => OrderingTerm.asc(s.trackNumber)]))
          .get();

  Future<List<Song>> getSongsByAlbum(int albumId) =>
      (select(songs)
        ..where((s) =>
            s.albumId.equals(albumId) & s.isAvailable.equals(true))
        ..orderBy([
          (s) => OrderingTerm.asc(s.discNumber),
          (s) => OrderingTerm.asc(s.trackNumber),
        ]))
          .get();

  Future<List<Song>> getSongsByLanguage(String language) =>
      (select(songs)
        ..where((s) =>
            s.languageTag.equals(language) &
            s.isAvailable.equals(true)))
          .get();

  Future<List<Song>> getUnclassifiedSongs() =>
      (select(songs)
        ..where((s) =>
            s.languageTag.isNull() & s.isAvailable.equals(true)))
          .get();

  // 🎯 NEW: Added Directory Query for Strategy 4 Sibling Consensus
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
      ..where(
          songs.isAvailable.equals(true) & songs.artist.isNotNull())
      ..orderBy([OrderingTerm.asc(songs.artist)]);
    final rows = await query.get();
    return rows
        .map((r) => r.read(songs.artist))
        .whereType<String>()
        .toList();
  }

  Future<List<String>> getClassifiedLanguages() async {
    final query = selectOnly(songs, distinct: true)
      ..addColumns([songs.languageTag])
      ..where(
          songs.languageTag.isNotNull() &
          songs.isAvailable.equals(true));
    final rows = await query.get();
    return rows
        .map((r) => r.read(songs.languageTag))
        .whereType<String>()
        .toList();
  }

  Future<int> getTotalSongCount() async {
    final count = countAll(filter: songs.isAvailable.equals(true));
    final query = selectOnly(songs)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  // ── Writes ───────────────────────────────────────────────

  Future<void> upsertSongs(List<SongsCompanion> companions) =>
      batch((b) => b.insertAllOnConflictUpdate(songs, companions));

  Future<void> markUnavailable(List<int> ids) =>
      (update(songs)..where((s) => s.id.isIn(ids))).write(
        const SongsCompanion(isAvailable: Value(false)),
      );

  Future<void> autoClassify(
      int songId, String language, double confidence) async {
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
}

// ─── 2.2  PlaylistsDao ──────────────────────────────────────
@DriftAccessor(tables: [Playlists, PlaylistEntries, Songs])
class PlaylistsDao extends DatabaseAccessor<AppDatabase>
    with _$PlaylistsDaoMixin {
  PlaylistsDao(super.db);

  static const int favoritesId      = 1;
  static const int recentlyPlayedId = 2;
  static const int top50Id          = 3;

  // ── Streams ──────────────────────────────────────────────

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
    return query.watch().map(
        (rows) => rows.map((r) => r.readTable(songs)).toList());
  }

  Stream<bool> watchIsFavorite(int songId) {
    final query = select(playlistEntries)
      ..where((e) =>
          e.playlistId.equals(favoritesId) &
          e.songId.equals(songId));
    return query.watch().map((rows) => rows.isNotEmpty);
  }

  // ── Queries ──────────────────────────────────────────────

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
      ..where(
          playlistEntries.playlistId.equals(playlistId) &
          songs.isAvailable.equals(false));
    final rows = await query.get();
    return rows
        .map((r) => r.readTable(playlistEntries).id)
        .toList();
  }

  // ── Writes ───────────────────────────────────────────────

  Future<int> createPlaylist(String name) =>
      into(playlists).insert(PlaylistsCompanion.insert(name: name));

  Future<void> renamePlaylist(int id, String newName) =>
      (update(playlists)
        ..where((p) =>
            p.id.equals(id) & p.isSystem.equals(false)))
          .write(PlaylistsCompanion(name: Value(newName)));

  Future<int> deletePlaylist(int id) =>
      (delete(playlists)
        ..where((p) =>
            p.id.equals(id) & p.isSystem.equals(false)))
          .go();

  Future<void> addSongToPlaylist(int playlistId, int songId) async {
    final maxPos = await _getMaxPosition(playlistId);
    await into(playlistEntries).insert(
      PlaylistEntriesCompanion.insert(
        playlistId: playlistId,
        songId: songId,
        position: maxPos + 1,
      ),
    );
    await _touchPlaylist(playlistId);
  }

  Future<void> removeSongFromPlaylist(int entryId) async {
      await (delete(playlistEntries)
        ..where((e) => e.id.equals(entryId)))
          .go();
  }

  Future<void> reorderSong(
      int playlistId, int entryId, int newPosition) =>
      transaction(() async {
        await (update(playlistEntries)
              ..where((e) => e.id.equals(entryId)))
            .write(PlaylistEntriesCompanion(
                position: Value(newPosition)));
        await _touchPlaylist(playlistId);
      });

  Future<void> toggleFavorite(int songId) async {
    final existing = await (select(playlistEntries)
          ..where((e) =>
              e.playlistId.equals(favoritesId) &
              e.songId.equals(songId)))
        .getSingleOrNull();
    if (existing != null) {
      await (delete(playlistEntries)
            ..where((e) => e.id.equals(existing.id)))
          .go();
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

// ─── 2.3  HistoryDao ────────────────────────────────────────
@DriftAccessor(
    tables: [PlayHistory, SongStats, Songs, Playlists, PlaylistEntries])
class HistoryDao extends DatabaseAccessor<AppDatabase>
    with _$HistoryDaoMixin {
  HistoryDao(super.db);

  Future<void> recordPlay({
    required int songId,
    required int listenedMs,
    required bool counted,
    required bool skippedEarly,
  }) async {
    await transaction(() async {
      await into(playHistory).insert(
        PlayHistoryCompanion.insert(
          songId: songId,
          playedAt: Value(DateTime.now()),
          listenedMs: Value(listenedMs),
          counted: Value(counted),
          skippedEarly: Value(skippedEarly),
        ),
      );

      if (counted) {
        await customUpdate(
          '''
          INSERT INTO song_stats
            (song_id, play_count, total_listened_ms, last_played, skip_count)
          VALUES (?, 1, ?, CAST(strftime('%s','now') AS INTEGER), 0)
          ON CONFLICT(song_id) DO UPDATE SET
            play_count        = play_count + 1,
            total_listened_ms = total_listened_ms + ?,
            last_played       = CAST(strftime('%s','now') AS INTEGER)
          ''',
          variables: [
            Variable<int>(songId),
            Variable<int>(listenedMs),
            Variable<int>(listenedMs),
          ],
          updates: {songStats},
        );
        await _refreshTop50();
      }

      if (skippedEarly) {
        await customUpdate(
          '''
          INSERT INTO song_stats
            (song_id, play_count, total_listened_ms, skip_count)
          VALUES (?, 0, 0, 1)
          ON CONFLICT(song_id) DO UPDATE SET
            skip_count = skip_count + 1
          ''',
          variables: [Variable<int>(songId)],
          updates: {songStats},
        );
      }

      await _updateRecentlyPlayed(songId);
    });
  }

  Stream<List<Song>> watchTop50() {
    final query = select(songStats).join([
      innerJoin(songs, songs.id.equalsExp(songStats.songId)),
    ])
      ..where(songs.isAvailable.equals(true))
      ..orderBy([OrderingTerm.desc(songStats.playCount)])
      ..limit(50);
    return query.watch().map(
        (rows) => rows.map((r) => r.readTable(songs)).toList());
  }

  Stream<List<Song>> watchRecentlyPlayed({int limit = 30}) {
    final query = select(playlistEntries).join([
      innerJoin(songs, songs.id.equalsExp(playlistEntries.songId)),
    ])
      ..where(
          playlistEntries.playlistId
              .equals(PlaylistsDao.recentlyPlayedId) &
          songs.isAvailable.equals(true))
      ..orderBy([OrderingTerm.asc(playlistEntries.position)])
      ..limit(limit);
    return query.watch().map(
        (rows) => rows.map((r) => r.readTable(songs)).toList());
  }

  Future<SongStat?> getStatsForSong(int songId) =>
      (select(songStats)..where((s) => s.songId.equals(songId)))
          .getSingleOrNull();

  Future<Duration> getTotalListeningTime() async {
    final sum = songStats.totalListenedMs.sum();
    final query = selectOnly(songStats)..addColumns([sum]);
    final row = await query.getSingleOrNull();
    return Duration(milliseconds: row?.read(sum) ?? 0);
  }

  Future<int> pruneOldHistory() async {
    final cutoff =
        DateTime.now().subtract(const Duration(days: 90));
    final top100 = await (select(songStats)
          ..orderBy([(s) => OrderingTerm.desc(s.playCount)])
          ..limit(100))
        .get();
    final protectedIds = top100.map((s) => s.songId).toList();
    return (delete(playHistory)
          ..where((h) =>
              h.playedAt.isSmallerThanValue(cutoff) &
              h.songId.isNotIn(protectedIds)))
        .go();
  }

  Future<void> _refreshTop50() async {
    final top50Songs = await (select(songStats)
          ..where((s) => s.playCount.isBiggerThanValue(0))
          ..orderBy([(s) => OrderingTerm.desc(s.playCount)])
          ..limit(50))
        .get();
    await transaction(() async {
      await (delete(playlistEntries)
            ..where((e) =>
                e.playlistId.equals(PlaylistsDao.top50Id)))
          .go();
      for (var i = 0; i < top50Songs.length; i++) {
        await into(playlistEntries).insert(
          PlaylistEntriesCompanion.insert(
            playlistId: PlaylistsDao.top50Id,
            songId: top50Songs[i].songId,
            position: i + 1,
          ),
        );
      }
    });
  }

  Future<void> _updateRecentlyPlayed(int songId) async {
    await (delete(playlistEntries)
          ..where((e) =>
              e.playlistId.equals(PlaylistsDao.recentlyPlayedId) &
              e.songId.equals(songId)))
        .go();
    await customUpdate(
      '''
      UPDATE playlist_entries
      SET position = position + 1
      WHERE playlist_id = ?
      ''',
      variables: [Variable<int>(PlaylistsDao.recentlyPlayedId)],
      updates: {playlistEntries},
    );
    await into(playlistEntries).insert(
      PlaylistEntriesCompanion.insert(
        playlistId: PlaylistsDao.recentlyPlayedId,
        songId: songId,
        position: 1,
      ),
    );
    await customUpdate(
      '''
      DELETE FROM playlist_entries
      WHERE playlist_id = ?
        AND id NOT IN (
          SELECT id FROM playlist_entries
          WHERE playlist_id = ?
          ORDER BY position ASC
          LIMIT 100
        )
      ''',
      variables: [
        Variable<int>(PlaylistsDao.recentlyPlayedId),
        Variable<int>(PlaylistsDao.recentlyPlayedId),
      ],
      updates: {playlistEntries},
    );
  }
}

// ─── 2.4  LanguageDao ───────────────────────────────────────
@DriftAccessor(tables: [LanguageTags, UserCorrections])
class LanguageDao extends DatabaseAccessor<AppDatabase>
    with _$LanguageDaoMixin {
  LanguageDao(super.db);

  Future<LanguageTag?> lookupArtist(String artistKey) =>
      (select(languageTags)
        ..where((t) => t.artistKey.equals(artistKey)))
          .getSingleOrNull();

  Future<void> upsertArtistTag(LanguageTagsCompanion companion) =>
      into(languageTags).insertOnConflictUpdate(companion);

  Future<void> bulkUpsert(List<LanguageTagsCompanion> companions) =>
      batch((b) =>
          b.insertAllOnConflictUpdate(languageTags, companions));

  Future<void> logCorrection(
          UserCorrectionsCompanion correction) =>
      into(userCorrections).insert(correction);

  Future<void> applyPendingCorrections() async {
    final promoted = await customSelect(
      '''
      SELECT artist_key, corrected_language, COUNT(*) as cnt
      FROM user_corrections
      WHERE applied_to_seeds = 0
      GROUP BY artist_key, corrected_language
      HAVING COUNT(*) >= 3
      ''',
      readsFrom: {userCorrections},
    ).get();

    await transaction(() async {
      for (final row in promoted) {
        final key  = row.read<String>('artist_key');
        final lang = row.read<String>('corrected_language');
        await upsertArtistTag(LanguageTagsCompanion.insert(
          artistKey: key,
          primaryLanguage: lang,
          languageScoresJson: '{"$lang": 0.85}',
          source: 'user_correction',
          confidence: const Value(0.85),
          updatedAt: Value(DateTime.now()),
        ));
      }
      await customUpdate(
        '''
        UPDATE user_corrections
        SET applied_to_seeds = 1
        WHERE applied_to_seeds = 0
        ''',
        variables: [],
        updates: {userCorrections},
      );
    });
  }
}

// ─── 2.5  SettingsDao ───────────────────────────────────────
@DriftAccessor(tables: [AppSettings, QueueState])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<String?> getSetting(String key) async {
    final row = await (select(appSettings)
          ..where((s) => s.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String? value) =>
      into(appSettings).insertOnConflictUpdate(
        AppSettingsCompanion.insert(
            key: key, value: Value(value)),
      );

  Future<void> saveQueueState({
    required String songIdsJson,
    required int currentIndex,
    required int positionMs,
    required String repeatMode,
    required bool shuffleMode,
  }) =>
      into(queueState).insertOnConflictUpdate(
        QueueStateCompanion.insert(
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
      (select(queueState)..where((q) => q.id.equals(1)))
          .getSingleOrNull();
}

// ============================================================
//  SECTION 3 — DATABASE CLASS
// ============================================================

@DriftDatabase(
  tables: [
    Songs,
    Playlists,
    PlaylistEntries,
    PlayHistory,
    SongStats,
    LanguageTags,
    UserCorrections,
    QueueState,
    AppSettings,
  ],
  daos: [
    SongsDao,
    PlaylistsDao,
    HistoryDao,
    LanguageDao,
    SettingsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  late final songsDao     = SongsDao(this);
  late final playlistsDao = PlaylistsDao(this);
  late final historyDao   = HistoryDao(this);
  late final languageDao  = LanguageDao(this);
  late final settingsDao  = SettingsDao(this);

  @override
  int get schemaVersion => 1;

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
      },
    );
  });
}