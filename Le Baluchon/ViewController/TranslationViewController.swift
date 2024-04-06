//
//  TranslationViewController.swift
//  Le Baluchon
//
//  Created by Thomas Carlier on 29/03/2024.
//

import UIKit

/// View controller responsible for text translation.
class TranslationViewController: UIViewController {

    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var translateButton: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    
    // Model for translation
    let translationService = TranslationService()
    
    /// Called after the controller's view is loaded. Used for initial setup.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Perform any additional setup after loading the view.
    }
    
    /// Action triggered by the translation button
    /// - Parameter sender: The button that triggered the action.
    @IBAction func translateButtonTapped(_ sender: UIButton) {
        // Checks that the text field is not empty
        guard let sourceText = inputTextField.text, !sourceText.isEmpty else {
            self.resultLabel.text = "Veuillez entrer du texte à traduire."
            return
        }
        
        // Performs the translation of the entered text from the source language to the target language.
        self.translationService.translate(text: sourceText, from: "fr", to: "en") { [weak self] translatedText, error in
            DispatchQueue.main.async {
                if let error = error {
                    // In case of an error during translation, display an error message.
                    self?.resultLabel.text = "Erreur de traduction : \(error.localizedDescription)"
                    return
                }
                
                // Display the translated text or a message if the translation is not available.
                if let translatedText = translatedText {
                    self?.resultLabel.text = translatedText.translatedText
                } else {
                    self?.resultLabel.text = "Traduction non disponible."
                }
            }
        }
    }
    
}
