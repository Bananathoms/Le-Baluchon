//
//  TranslationViewController.swift
//  Le Baluchon
//
//  Created by Thomas Carlier on 29/03/2024.
//

import UIKit

/// View controller responsible for text translation.
class TranslationViewController: UIViewController {
    
    @IBOutlet weak var targetLanguageLabel: UILabel!
    @IBOutlet weak var sourceLanguageLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var translateButton: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    
    // Model for translation
    let translationService = TranslationService()
    
    // Current language settings
    var sourceLanguageCode = "fr"
    var targetLanguageCode = "en"
    
    /// Called after the controller's view is loaded. Used for initial setup.
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateLanguageLabels), name: NSNotification.Name("LanguagePreferenceChanged"), object: nil)
        self.updateLanguageLabels()
        
        // Adds a tap gesture recognizer to hide the keyboard when the user taps elsewhere on the screen.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Method called to hide the keyboard.
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    /// Updates the language labels on the interface.
    @objc func updateLanguageLabels() {
        let defaultSourceLanguage = "French"
        let defaultSourceCode = "fr"
        let defaultTargetLanguage = "English"
        let defaultTargetCode = "en"
        
        let sourceLanguageName = UserDefaults.standard.string(forKey: "SelectedHomeLanguageName") ?? defaultSourceLanguage
        let sourceLanguageCode = UserDefaults.standard.string(forKey: "SelectedHomeLanguageCode") ?? defaultSourceCode
        let targetLanguageName = UserDefaults.standard.string(forKey: "SelectedDestinationLanguageName") ?? defaultTargetLanguage
        let targetLanguageCode = UserDefaults.standard.string(forKey: "SelectedDestinationLanguageCode") ?? defaultTargetCode
        
        self.sourceLanguageLabel.text = sourceLanguageName
        self.targetLanguageLabel.text = targetLanguageName
        self.sourceLanguageCode = sourceLanguageCode
        self.targetLanguageCode = targetLanguageCode
    }
    
    
    /// Action triggered by the translation button
    /// - Parameter sender: The button that triggered the action.
    @IBAction func translateButtonTapped(_ sender: UIButton) {
        // Checks that the text field is not empty
        guard let sourceText = inputTextField.text, !sourceText.isEmpty else {
            self.resultLabel.text = "Please enter text to translate."
            return
        }
        
        // Performs the translation of the entered text from the source language to the target language.
        self.translationService.translate(text: sourceText, from: sourceLanguageCode, to: targetLanguageCode) { [weak self] translatedText, error in
            DispatchQueue.main.async {
                if let error = error {
                    // In case of an error during translation, display an error message.
                    self?.resultLabel.text = "Translation error : \(error.localizedDescription)"
                    return
                }
                
                // Display the translated text or a message if the translation is not available.
                if let translatedText = translatedText {
                    self?.resultLabel.text = translatedText.translatedText
                } else {
                    self?.resultLabel.text = "Translation unavailable."
                }
            }
        }
    }
}
