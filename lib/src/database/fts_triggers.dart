class FtsTriggers {
  static const String createTable = '''
    CREATE VIRTUAL TABLE IF NOT EXISTS songs_fts USING fts5(
      title,
      artist,
      album,
      content='songs',
      content_rowid='id'
    );
  ''';

  static const String insertTrigger = '''
    CREATE TRIGGER songs_ai AFTER INSERT ON songs BEGIN
      INSERT INTO songs_fts(rowid, title, artist, album) 
      VALUES (new.id, new.title, new.artist, new.album);
    END;
  ''';

  static const String updateTrigger = '''
    CREATE TRIGGER songs_au AFTER UPDATE ON songs BEGIN
      INSERT INTO songs_fts(songs_fts, rowid, title, artist, album) VALUES('delete', old.id, old.title, old.artist, old.album);
      INSERT INTO songs_fts(rowid, title, artist, album) VALUES(new.id, new.title, new.artist, new.album);
    END;
  ''';

  static const String deleteTrigger = '''
    CREATE TRIGGER songs_ad AFTER DELETE ON songs BEGIN
      INSERT INTO songs_fts(songs_fts, rowid, title, artist, album) VALUES('delete', old.id, old.title, old.artist, old.album);
    END;
  ''';
}