//
//  TranslationViewController.swift
//  Le Baluchon
//
//  Created by Thomas Carlier on 29/03/2024.
//

import UIKit

/// Contrôleur de vue responsable de la traduction de textes.
class TranslationViewController: UIViewController {

    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var translateButton: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    
    // Le modèle pour la traduction
    let translationModel = TranslationModel()
    
    /// Appelée après le chargement de la vue du contrôleur. Utilisée pour la configuration initiale.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    /// Action déclenchée par le bouton de traduction
    /// - Parameter sender: Le bouton qui a déclenché l'action.
    @IBAction func translateButtonTapped(_ sender: UIButton) {
        // Vérification que le champ de texte n'est pas vide
        guard let sourceText = inputTextField.text, !sourceText.isEmpty else {
            resultLabel.text = "Veuillez entrer du texte à traduire."
            return
        }
        
        // Effectue la traduction du texte saisi de la langue source vers la langue cible.
        translationModel.translate(text: sourceText, from: "fr", to: "en") { [weak self] translatedText, error in
            DispatchQueue.main.async {
                if let error = error {
                    // En cas d'erreur lors de la traduction, affiche un message d'erreur.
                    self?.resultLabel.text = "Erreur de traduction : \(error.localizedDescription)"
                    return
                }
                
                // Affichage du texte traduit ou d'un message si la traduction n'est pas disponible.
                if let translatedText = translatedText {
                    self?.resultLabel.text = translatedText
                } else {
                    self?.resultLabel.text = "Traduction non disponible."
                }
            }
        }
    }
    
}
