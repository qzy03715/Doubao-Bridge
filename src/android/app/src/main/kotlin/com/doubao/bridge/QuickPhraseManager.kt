package com.doubao.bridge

import android.content.Context
import android.content.SharedPreferences
import org.json.JSONArray

class QuickPhraseManager(context: Context) {

    private val prefs: SharedPreferences =
        context.getSharedPreferences("quick_phrases", Context.MODE_PRIVATE)

    companion object {
        private const val KEY_PHRASES = "phrases"
        private val DEFAULT_PHRASES = listOf(
            "OK", "Thanks", "Got it", "Wait",
            "No problem", "Sure", "Hello"
        )
    }

    fun getPhrases(): List<String> {
        val json = prefs.getString(KEY_PHRASES, null) ?: return DEFAULT_PHRASES
        return try {
            val array = JSONArray(json)
            (0 until array.length()).map { array.getString(it) }
        } catch (e: Exception) {
            DEFAULT_PHRASES
        }
    }

    fun savePhrases(phrases: List<String>) {
        val array = JSONArray(phrases)
        prefs.edit().putString(KEY_PHRASES, array.toString()).apply()
    }

    fun addPhrase(phrase: String): Boolean {
        if (phrase.isBlank()) return false
        val current = getPhrases().toMutableList()
        if (current.contains(phrase)) return false
        current.add(phrase)
        savePhrases(current)
        return true
    }

    fun removePhrase(phrase: String) {
        val current = getPhrases().toMutableList()
        current.remove(phrase)
        savePhrases(current)
    }

    fun resetToDefault() {
        prefs.edit().remove(KEY_PHRASES).apply()
    }
}
