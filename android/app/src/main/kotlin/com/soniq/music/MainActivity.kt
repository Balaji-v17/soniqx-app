package com.soniq.music

// 🎯 FIXED: Import the specific Activity from the audio_service package
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import com.soniq.app.FastTextClassifier
import com.soniq.app.FastTextClassifierApi

// 🎯 FIXED: Extend AudioServiceActivity so background audio doesn't crash
class MainActivity: AudioServiceActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Initialize the ML Kit Classifier
        val fastTextClassifier = FastTextClassifier(context)
        
        // Register the Pigeon API listener
        FastTextClassifierApi.setUp(flutterEngine.dartExecutor.binaryMessenger, fastTextClassifier)
    }
}