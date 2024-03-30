//
//  TitleViewController.swift
//  Le Baluchon
//
//  Created by Thomas Carlier on 29/03/2024.
//

import UIKit

/// ViewController gérant l'affichage et la conversion des taux de change.
class ExchangeRateViewController: UIViewController {
   
    
    @IBOutlet weak var labelBase: UILabel!
    @IBOutlet weak var labelRate: UILabel!
    @IBOutlet weak var labeldate: UILabel!
    @IBOutlet weak var textFieldAmount: UITextField!
    @IBOutlet weak var labelResult: UILabel!
    
    var exchangeRateModel = ExchangeRateModel()
    var currentRate: Double?
    
    /// Configure le ViewController après le chargement de la vue.
    override func viewDidLoad() {
        super.viewDidLoad()
        loadExchangeRate()

        
        // Ajout d'un tap gesture recognizer pour cacher le clavier lorsque l'utilisateur tape ailleur sur l'écran
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    /// Méthode appelée pour cacher le clavier.
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    /// Charge les données des taux de change depuis l'API et met à jour l'interface utilisateur en conséquence.
    func loadExchangeRate() {
        exchangeRateModel.fetchExchangeRate(fromCurrency: "EUR", toCurrency: "USD") { [weak self] (rate, base, date, error) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    // Affiche une erreur si la récupération échoue.
                    self.labelRate.text = "Erreur : \(error.localizedDescription)"
                    return
                }
                
                guard let rate = rate, let base = base, let date = date else {
                    self.labelRate.text = "Taux de change non disponible."
                    return
                }
                
                // Mise à jour des labels avec les données récupérées.
                self.labelBase.text = "Devise de base : \(base)"
                self.labelRate.text = "1 \(base) = \(rate) USD"
                self.labeldate.text = "Dernière mise à jour : \(date)"
            }
        }
    }
    
    /// Réalise la conversion du montant entré à la devise cible et affiche le résultat.
    /// - Parameter sender: Le bouton déclenchant l'action de conversion.
    @IBAction func convertTapped(_ sender: UIButton) {
        // Vérifie l'entrée de l'utilisateur et l'existence d'un taux de change.
        guard let amountText = textFieldAmount.text, let amount = Double(amountText), let rate = currentRate else {
            labelResult.text = "Entrée invalide ou taux de change non chargé"
            return
        }

        // Effectue la conversion avec le taux de change actuel et affiche le résultat.
        let convertedAmount = amount * rate
        labelResult.text = String(format: "%.2f USD", convertedAmount)
    }
}
