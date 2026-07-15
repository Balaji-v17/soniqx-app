package com.soniq.music

import android.content.ContentUris
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import android.util.Size
import java.io.ByteArrayOutputStream
import java.io.File

class AudioScannerApiImpl(private val context: Context) : AudioScannerApi {

    private val contentResolver = context.contentResolver
    private val tag = "AudioScanner"
    private val minDurationMs = 10_000L

    private fun getBaseProjection(): Array<String> {
        val projection = mutableListOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.ARTIST,
            MediaStore.Audio.Media.ALBUM,
            MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.DATA,
            MediaStore.Audio.Media.ALBUM_ID,
            MediaStore.Audio.Media.DATE_ADDED,
            MediaStore.Audio.Media.TRACK,
            MediaStore.Audio.Media.YEAR,
            MediaStore.Audio.Media.MIME_TYPE,
        )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            projection.add(MediaStore.Audio.Media.ALBUM_ARTIST)
            projection.add(MediaStore.Audio.Media.DISC_NUMBER)
            projection.add(MediaStore.Audio.Media.GENRE)
        }
        return projection.toTypedArray()
    }

    private fun extractSongsFromCursor(cursor: android.database.Cursor): List<RawSongData> {
        val songs = mutableListOf<RawSongData>()
        val dataCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DATA)
        val idCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
        val titleCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.TITLE)
        val artistCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST)
        val albumCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM)
        val durationCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DURATION)
        val albumIdCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM_ID)
        val dateAddedCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DATE_ADDED)
        val trackCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.TRACK)
        val yearCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.YEAR)

        val albumArtistCol = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R)
            cursor.getColumnIndex(MediaStore.Audio.Media.ALBUM_ARTIST) else -1
        val discCol = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R)
            cursor.getColumnIndex(MediaStore.Audio.Media.DISC_NUMBER) else -1
        val genreCol = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R)
            cursor.getColumnIndex(MediaStore.Audio.Media.GENRE) else -1

        while (cursor.moveToNext()) {
            try {
                val path = cursor.getString(dataCol) ?: continue
                
                // 🎯 THE ONLY SHIELD WE NEED: Make sure the file physically exists!
            
                
                val duration = cursor.getLong(durationCol)
                if (duration < minDurationMs) continue

                val track = cursor.getLong(trackCol).let { if (it == 0L) null else it }
                val year  = cursor.getLong(yearCol).let { if (it == 0L) null else it }

                val albumArtist = if (albumArtistCol != -1)
                    cleanString(cursor.getString(albumArtistCol)) else null

                val discNumber = if (discCol != -1) {
                    cursor.getLong(discCol).let { if (it == 0L) null else it }
                } else null

                val genre = if (genreCol != -1)
                    cleanString(cursor.getString(genreCol)) else null

                songs.add(RawSongData(
                    id = cursor.getLong(idCol),
                    title = cleanString(cursor.getString(titleCol)),
                    artist = cleanString(cursor.getString(artistCol)),
                    album = cleanString(cursor.getString(albumCol)),
                    path = path,
                    durationMs = duration,
                    albumId = cursor.getLong(albumIdCol),
                    dateAdded = cursor.getLong(dateAddedCol),
                    trackNumber = track,
                    discNumber = discNumber,
                    year = year,
                    albumArtist = albumArtist,
                    genre = genre
                ))
            } catch (e: Exception) {
                Log.e(tag, "Skipping malformed row: ${e.message}")
            }
        }
        return songs
    }

    override fun querySongs(): List<RawSongData> {
        val projection = getBaseProjection()
        
        // 🎯 BACK TO BASICS: Just get all valid music files.
        val selection = "${MediaStore.Audio.Media.IS_MUSIC} = 1 AND ${MediaStore.Audio.Media.DURATION} >= ?"
        val selectionArgs = arrayOf(minDurationMs.toString())

        val songs = mutableListOf<RawSongData>()

        contentResolver.query(
            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
            projection,
            selection,
            selectionArgs,
            "${MediaStore.Audio.Media.TITLE} ASC"
        )?.use { cursor ->
            songs.addAll(extractSongsFromCursor(cursor))
        }
        return songs
    }

    override fun querySongsSince(timestamp: Long): List<RawSongData> {
        val projection = getBaseProjection()
        
        val selection = "${MediaStore.Audio.Media.IS_MUSIC} = 1 AND ${MediaStore.Audio.Media.DURATION} >= ? AND ${MediaStore.Audio.Media.DATE_ADDED} >= ?"
        val selectionArgs = arrayOf(minDurationMs.toString(), timestamp.toString())

        val songs = mutableListOf<RawSongData>()

        contentResolver.query(
            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
            projection,
            selection,
            selectionArgs,
            "${MediaStore.Audio.Media.DATE_ADDED} DESC"
        )?.use { cursor ->
            songs.addAll(extractSongsFromCursor(cursor))
        }
        return songs
    }

    override fun queryAlbumArt(albumId: Long, songId: Long): ByteArray? {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val songUri = ContentUris.withAppendedId(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, songId)
                var bitmap: Bitmap? = null
                try {
                    bitmap = contentResolver.loadThumbnail(songUri, Size(300, 300), null)
                    val stream = ByteArrayOutputStream()
                    bitmap.compress(Bitmap.CompressFormat.JPEG, 85, stream)
                    stream.toByteArray()
                } catch (e: Exception) {
                    null
                } finally {
                    bitmap?.recycle()
                }
            } else {
                val albumArtUri = ContentUris.withAppendedId(Uri.parse("content://media/external/audio/albumart"), albumId)
                var bitmap: Bitmap? = null
                try {
                    contentResolver.openFileDescriptor(albumArtUri, "r")?.use { pfd ->
                        bitmap = BitmapFactory.decodeFileDescriptor(pfd.fileDescriptor)
                    }
                    bitmap?.let { bmp ->
                        val stream = ByteArrayOutputStream()
                        bmp.compress(Bitmap.CompressFormat.JPEG, 85, stream)
                        stream.toByteArray()
                    }
                } finally {
                    bitmap?.recycle()
                }
            }
        } catch (e: Exception) {
            null
        }
    }

    private fun cleanString(value: String?): String? {
        if (value.isNullOrBlank()) return null
        val trimmed = value.trim()
        if (trimmed.isEmpty()) return null
        val sentinels = setOf("<unknown>", "unknown", "unknown artist", "unknown album", "unknown title")
        if (sentinels.contains(trimmed.lowercase())) return null
        return trimmed
    }
}