//
//  TitleViewController.swift
//  Le Baluchon
//
//  Created by Thomas Carlier on 29/03/2024.
//

import UIKit

class ExchangeRateViewController: UIViewController {
    
    @IBOutlet weak var textFieldAmount: UITextField!
    @IBOutlet weak var labelResult: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Ajout d'un tap gesture recognizer pour cacher le clavier
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func convertTapped(_ sender: UIButton) {
        // Vérifier que le champ de texte n'est pas vide et que la valeur peut être convertie en Double
        guard let amountText = textFieldAmount.text, let amount = Double(amountText) else {
            labelResult.text = "Entrée invalide"
            return
        }
        
        // Appel à la fonction de conversion
        let convertAmount = convertirEnDollars(amount)
        labelResult.text = String(format: "%.2f $", convertAmount)
    }
    
    // Fonction pour simuler la conversion de devise
    func convertirEnDollars(_ montant: Double) -> Double {
        let tauxDeChange = 1.1 // Exemple de taux de change
        return montant * tauxDeChange
    }
}
