package com.soniq.music

import com.ryanheise.audioservice.AudioServiceFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import com.soniq.app.FastTextClassifier
import com.soniq.app.FastTextClassifierApi
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MainActivity: AudioServiceFragmentActivity() {
    private val HEALER_CHANNEL = "com.soniq.music/healer"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // 1. Use applicationContext to prevent Kotlin 'context' keyword collision
        val fastTextClassifier = FastTextClassifier(applicationContext)
        FastTextClassifierApi.setUp(flutterEngine.dartExecutor.binaryMessenger, fastTextClassifier)

        // 2. Add the Duration Healer Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, HEALER_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "healDurations") {
                val ids = call.argument<List<Int>>("ids") ?: emptyList()
                CoroutineScope(Dispatchers.Main).launch {
                    val healer = DurationHealerApiImpl(applicationContext)
                    val healedData = healer.healDurations(ids)
                    result.success(healedData)
                }
            } else {
                result.notImplemented()
            }
        }

        // 3. Register Native Song Deletion Bridge (passes 'this' as ComponentActivity)
        SongDeletionBridge(this, flutterEngine.dartExecutor.binaryMessenger)
    }
}