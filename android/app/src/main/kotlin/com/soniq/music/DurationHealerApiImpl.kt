package com.soniq.music

import android.content.ContentUris
import android.content.Context
import android.media.MediaMetadataRetriever
import android.provider.MediaStore
import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class DurationHealerApiImpl(private val context: Context) {
    // 🎯 Accept IDs instead of Paths to bypass Scoped Storage security
    suspend fun healDurations(ids: List<Int>): Map<Int, Long> =
        withContext(Dispatchers.IO) {
            val results = mutableMapOf<Int, Long>()
            val retriever = MediaMetadataRetriever()
            try {
                for (id in ids) {
                    try {
                        // 🎯 Generate a secure Android Content URI
                        val uri = ContentUris.withAppendedId(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, id.toLong())
                        retriever.setDataSource(context, uri)
                        val durationMs = retriever
                            .extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
                            ?.toLongOrNull() ?: 0L

                        if (durationMs > 0L) {
                            results[id] = durationMs
                        }
                    } catch (e: Exception) {
                        Log.w("DurationHealer", "Failed to heal ID $id: ${e.message}")
                    }
                }
            } finally {
                try { retriever.release() } catch(e: Exception) {}
            }
            results
        }
}