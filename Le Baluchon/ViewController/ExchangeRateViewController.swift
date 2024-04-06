//
//  TitleViewController.swift
//  Le Baluchon
//
//  Created by Thomas Carlier on 29/03/2024.
//

import UIKit

/// ViewController managing the display and conversion of exchange rates.
class ExchangeRateViewController: UIViewController {
    
    @IBOutlet weak var labelBase: UILabel!
    @IBOutlet weak var labelRate: UILabel!
    @IBOutlet weak var labeldate: UILabel!
    @IBOutlet weak var textFieldAmount: UITextField!
    @IBOutlet weak var labelResult: UILabel!
    
    let exchangeRateService = ExchangeRateService()
    var currentRate: Double?
    
    /// Configures the ViewController after the view has loaded.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadExchangeRate(fromCurrency: "EUR", toCurrency: "USD")
        
        // Adds a tap gesture recognizer to hide the keyboard when the user taps elsewhere on the screen.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    /// Method called to hide the keyboard.
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    /// Loads the exchange rate data from the API and updates the UI accordingly.
    func loadExchangeRate(fromCurrency: String, toCurrency: String) {
        exchangeRateService.fetchExchangeRateIfNeeded(fromCurrency: fromCurrency, toCurrency: toCurrency) { [weak self] (exchangeRate, error) in
            DispatchQueue.main.async {
                guard let self = self, let exchangeRate = exchangeRate else {
                    self?.labelRate.text = "Error: \(error?.localizedDescription ?? "Unknown error")"
                    return
                }
                
                // Update the UI with the fetched exchange rate
                self.labelBase.text = "Devise de base: \(exchangeRate.baseCurrency)"
                self.labelRate.text = "1 \(exchangeRate.baseCurrency) = \(exchangeRate.rate) \(exchangeRate.targetCurrency)"
                // Here, assume you have a method to format the date into a string
                self.labeldate.text = "Dernière mise à jour: \(self.formatDateToString(exchangeRate.date))"
            }
        }
    }
    
    /// Performs the conversion of the entered amount to the target currency and displays the result.
    /// - Parameter sender: The button triggering the conversion action.
    @IBAction func convertTapped(_ sender: UIButton) {
        // Checks the user input and the existence of an exchange rate.
        guard let amountText = textFieldAmount.text,
              let amount = Double(amountText),
              let exchangeRate = exchangeRateService.lastExchangeRate else {
            labelResult.text = "Entrée invalide ou taux de change non chargé"
            return
        }
        
        // Performs the conversion with the current exchange rate and displays the result.
        let convertedAmount = exchangeRate.convert(amount: amount)
        labelResult.text = String(format: "%.2f USD", convertedAmount)
    }
    
    /// Helper method to format the Date object into a string for display.
    private func formatDateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
