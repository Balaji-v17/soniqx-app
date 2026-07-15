package com.soniq.music

import io.flutter.embedding.engine.FlutterEngine
// 1. Import the AudioService framework instead of the default Flutter one
import com.ryanheise.audioservice.AudioServiceActivity

// 2. Extend AudioServiceActivity instead of FlutterActivity
class MainActivity: AudioServiceActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        AudioScannerApi.setUp(
            flutterEngine.dartExecutor.binaryMessenger, 
            AudioScannerApiImpl(context)
        )
    }
}