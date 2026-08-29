package com.soniq.music

import android.app.Activity
import android.content.ContentUris
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResult
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.IntentSenderRequest
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

class SongDeletionBridge(
    private val activity: ComponentActivity,
    messenger: BinaryMessenger,
) {
    companion object {
        const val CHANNEL = "com.soniq.music/deletion"
        private const val TAG = "SongDeletionBridge"
    }

    private var pendingResult: MethodChannel.Result? = null

    private val deleteLauncher: ActivityResultLauncher<IntentSenderRequest> =
        activity.registerForActivityResult(
            ActivityResultContracts.StartIntentSenderForResult()
        ) { result: ActivityResult ->
            val success = result.resultCode == Activity.RESULT_OK
            Log.d(TAG, "Delete dialog result: ${result.resultCode}, success=$success")
            pendingResult?.success(success)
            pendingResult = null
        }

    private val trashLauncher: ActivityResultLauncher<IntentSenderRequest> =
        activity.registerForActivityResult(
            ActivityResultContracts.StartIntentSenderForResult()
        ) { result: ActivityResult ->
            val success = result.resultCode == Activity.RESULT_OK
            Log.d(TAG, "Trash dialog result: ${result.resultCode}, success=$success")
            pendingResult?.success(success)
            pendingResult = null
        }

    init {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "permanentDelete" -> {
                    val songId = call.argument<Int>("songId")?.toLong()
                    if (songId == null) {
                        result.error("INVALID_ARGS", "songId required", null)
                        return@setMethodCallHandler
                    }
                    permanentDelete(songId, result)
                }
                "permanentDeleteBatch" -> {
                    val songIds = call.argument<List<Int>>("songIds")?.map { it.toLong() }
                    if (songIds.isNullOrEmpty()) {
                        result.error("INVALID_ARGS", "songIds required", null)
                        return@setMethodCallHandler
                    }
                    permanentDeleteBatch(songIds, result)
                }
                "moveToTrash" -> {
                    val songId = call.argument<Int>("songId")?.toLong()
                    if (songId == null) {
                        result.error("INVALID_ARGS", "songId required", null)
                        return@setMethodCallHandler
                    }
                    moveToTrash(songId, result)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun permanentDeleteBatch(songIds: List<Long>, result: MethodChannel.Result) {
        val uris = songIds.map { id ->
            ContentUris.withAppendedId(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, id)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            // Android 11+: ONE createDeleteRequest with ALL uris triggers a single dialog
            try {
                val pendingIntent = MediaStore.createDeleteRequest(
                    activity.contentResolver,
                    uris
                )
                pendingResult = result
                deleteLauncher.launch(
                    IntentSenderRequest.Builder(pendingIntent.intentSender).build()
                )
            } catch (e: Exception) {
                Log.e(TAG, "permanentDeleteBatch failed: ${e.message}")
                result.error("DELETE_FAILED", e.message, null)
            }
        } else {
            // API 29 and below: Delete each directly, no dialog needed
            var allDeleted = true
            for (uri in uris) {
                try {
                    val deleted = activity.contentResolver.delete(uri, null, null)
                    if (deleted == 0) allDeleted = false
                } catch (e: Exception) {
                    Log.e(TAG, "Error deleting batch item $uri: ${e.message}")
                    allDeleted = false
                }
            }
            result.success(allDeleted)
        }
    }

    private fun permanentDelete(songId: Long, result: MethodChannel.Result) {
        val uri = ContentUris.withAppendedId(
            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
            songId
        )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            try {
                val pendingIntent = MediaStore.createDeleteRequest(
                    activity.contentResolver,
                    listOf(uri)
                )
                pendingResult = result
                deleteLauncher.launch(
                    IntentSenderRequest.Builder(pendingIntent.intentSender).build()
                )
            } catch (e: Exception) {
                Log.e(TAG, "permanentDelete failed: ${e.message}")
                result.error("DELETE_FAILED", e.message, null)
            }
        } else {
            try {
                val deleted = activity.contentResolver.delete(uri, null, null)
                result.success(deleted > 0)
            } catch (e: SecurityException) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    val recoverable = e as? android.app.RecoverableSecurityException
                    if (recoverable != null) {
                        pendingResult = result
                        deleteLauncher.launch(
                            IntentSenderRequest.Builder(
                                recoverable.userAction.actionIntent.intentSender
                            ).build()
                        )
                        return
                    }
                }
                result.error("PERMISSION_DENIED", e.message, null)
            }
        }
    }

    private fun moveToTrash(songId: Long, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            result.success(false)
            return
        }

        val uri = ContentUris.withAppendedId(
            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
            songId
        )

        try {
            val pendingIntent = MediaStore.createTrashRequest(
                activity.contentResolver,
                listOf(uri),
                true
            )
            pendingResult = result
            trashLauncher.launch(
                IntentSenderRequest.Builder(pendingIntent.intentSender).build()
            )
        } catch (e: Exception) {
            Log.e(TAG, "moveToTrash failed: ${e.message}")
            result.error("TRASH_FAILED", e.message, null)
        }
    }
}