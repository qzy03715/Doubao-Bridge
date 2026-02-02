package com.doubao.bridge

import android.app.Activity
import android.app.AlertDialog
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.os.Bundle
import android.view.Gravity
import android.view.inputmethod.InputMethodManager
import android.widget.Button
import android.widget.EditText
import android.widget.GridLayout
import android.widget.LinearLayout
import android.widget.Toast

class MainActivity : Activity() {

    private lateinit var editTextInput: EditText
    private lateinit var buttonSend: Button
    private lateinit var buttonClear: Button
    private lateinit var gridQuickPhrases: GridLayout
    private lateinit var phraseManager: QuickPhraseManager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        initViews()
        setupListeners()
        loadQuickPhrases()
        showKeyboard()
    }

    private fun initViews() {
        editTextInput = findViewById(R.id.editTextInput)
        buttonSend = findViewById(R.id.buttonSend)
        buttonClear = findViewById(R.id.buttonClear)
        gridQuickPhrases = findViewById(R.id.gridQuickPhrases)
        phraseManager = QuickPhraseManager(this)
    }

    private fun setupListeners() {
        buttonSend.setOnClickListener {
            val text = editTextInput.text.toString()
            if (text.isNotEmpty()) {
                copyToClipboard(text)
            }
        }

        buttonClear.setOnClickListener {
            editTextInput.text.clear()
            editTextInput.requestFocus()
        }
    }

    private fun copyToClipboard(text: String) {
        val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = ClipData.newPlainText("doubao_input", text)
        clipboard.setPrimaryClip(clip)
        Toast.makeText(this, R.string.toast_copied, Toast.LENGTH_SHORT).show()
    }

    private fun showKeyboard() {
        editTextInput.postDelayed({
            editTextInput.requestFocus()
            val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
            imm.showSoftInput(editTextInput, InputMethodManager.SHOW_IMPLICIT)
        }, 200)
    }

    private fun loadQuickPhrases() {
        val phrases = phraseManager.getPhrases()
        gridQuickPhrases.removeAllViews()
        gridQuickPhrases.columnCount = 4

        phrases.forEach { phrase ->
            addPhraseButton(phrase)
        }
        addEditButton()
    }

    private fun addPhraseButton(phrase: String) {
        val button = Button(this).apply {
            text = phrase
            textSize = 12f
            setBackgroundResource(R.drawable.button_phrase)
            setPadding(16, 8, 16, 8)
            setOnClickListener {
                val start = editTextInput.selectionStart.coerceAtLeast(0)
                editTextInput.text.insert(start, phrase)
            }
            setOnLongClickListener {
                showDeletePhraseDialog(phrase)
                true
            }
        }

        val params = GridLayout.LayoutParams().apply {
            width = 0
            height = GridLayout.LayoutParams.WRAP_CONTENT
            columnSpec = GridLayout.spec(GridLayout.UNDEFINED, 1f)
            setMargins(4, 4, 4, 4)
        }
        gridQuickPhrases.addView(button, params)
    }

    private fun addEditButton() {
        val button = Button(this).apply {
            text = getString(R.string.button_edit)
            textSize = 12f
            setBackgroundResource(R.drawable.button_phrase)
            setPadding(16, 8, 16, 8)
            setOnClickListener { showAddPhraseDialog() }
        }

        val params = GridLayout.LayoutParams().apply {
            width = 0
            height = GridLayout.LayoutParams.WRAP_CONTENT
            columnSpec = GridLayout.spec(GridLayout.UNDEFINED, 1f)
            setMargins(4, 4, 4, 4)
        }
        gridQuickPhrases.addView(button, params)
    }

    private fun showAddPhraseDialog() {
        val input = EditText(this).apply {
            hint = getString(R.string.dialog_add_hint)
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply { setMargins(48, 16, 48, 16) }
        }

        val container = LinearLayout(this).apply {
            addView(input)
        }

        AlertDialog.Builder(this)
            .setTitle(R.string.dialog_edit_title)
            .setView(container)
            .setPositiveButton("Add") { _, _ ->
                val phrase = input.text.toString().trim()
                if (phraseManager.addPhrase(phrase)) {
                    loadQuickPhrases()
                }
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    private fun showDeletePhraseDialog(phrase: String) {
        AlertDialog.Builder(this)
            .setTitle("Delete phrase?")
            .setMessage("Remove \"$phrase\" from quick phrases?")
            .setPositiveButton("Delete") { _, _ ->
                phraseManager.removePhrase(phrase)
                loadQuickPhrases()
            }
            .setNegativeButton("Cancel", null)
            .show()
    }
}
