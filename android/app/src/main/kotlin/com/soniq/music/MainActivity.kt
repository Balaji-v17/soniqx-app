package com.soniq.music

import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import com.soniq.app.FastTextClassifier
import com.soniq.app.FastTextClassifierApi
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

// 🎯 FIXED: Extends AudioServiceActivity to prevent background crashes
class MainActivity: AudioServiceActivity() {
    private val HEALER_CHANNEL = "com.soniq.music/healer"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // 1. Restore the ML Kit Classifier
        val fastTextClassifier = FastTextClassifier(context)
        FastTextClassifierApi.setUp(flutterEngine.dartExecutor.binaryMessenger, fastTextClassifier)

        // 2. Add the new Duration Healer Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, HEALER_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "healDurations") {
                val ids = call.argument<List<Int>>("ids") ?: emptyList()
                CoroutineScope(Dispatchers.Main).launch {
                    val healer = DurationHealerApiImpl(context)
                    val healedData = healer.healDurations(ids)
                    result.success(healedData)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}