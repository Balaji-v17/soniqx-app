package com.soniq.app

import android.content.Context
import com.google.mlkit.nl.languageid.LanguageIdentification
import com.google.mlkit.nl.languageid.LanguageIdentificationOptions

class FastTextClassifier(private val context: Context) : FastTextClassifierApi {
    
    // Configure ML Kit to return results even if confidence is low, 
    // so your Dart cascade can make the final threshold decisions.
    private val languageIdentifier = LanguageIdentification.getClient(
        LanguageIdentificationOptions.Builder()
            .setConfidenceThreshold(0.1f)
            .build()
    )

    override fun classifyText(text: String, callback: (Result<ClassificationResult>) -> Unit) {
        val cleanText = text.lowercase().trim().replace("\n", " ")
        
        languageIdentifier.identifyPossibleLanguages(cleanText)
            .addOnSuccessListener { identifiedLanguages ->
                if (identifiedLanguages.isNotEmpty()) {
                    // ML Kit returns a list sorted by confidence. We take the top result.
                    val bestMatch = identifiedLanguages[0]
                    val result = ClassificationResult(
                        languageTag = bestMatch.languageTag, // e.g., "hi", "kn", "en"
                        confidence = bestMatch.confidence.toDouble()
                    )
                    callback(Result.success(result))
                } else {
                    val result = ClassificationResult(languageTag = "und", confidence = 0.0)
                    callback(Result.success(result))
                }
            }
            .addOnFailureListener { e ->
                callback(Result.failure(e))
            }
    }
}