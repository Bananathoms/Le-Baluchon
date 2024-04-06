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
    
    var exchangeRateService = ExchangeRateService()
    var currentRate: Double?
    
    /// Configures the ViewController after the view has loaded.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadExchangeRate()

        
        // Adds a tap gesture recognizer to hide the keyboard when the user taps elsewhere on the screen.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    /// Method called to hide the keyboard.
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    /// Loads the exchange rate data from the API and updates the UI accordingly.
    func loadExchangeRate() {
        self.exchangeRateService.fetchExchangeRate(fromCurrency: "EUR", toCurrency: "USD") { [weak self] (exchangeRate, error) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    self.labelRate.text = "Error: \(error.localizedDescription)"
                    return
                }
                
                guard let exchangeRate = exchangeRate else {
                    self.labelRate.text = "Exchange rate not available."
                    return
                }
                
                // Update the current exchange rate.
                self.currentRate = exchangeRate.rate
                
                self.labelBase.text = "Base currency: \(exchangeRate.baseCurrency)"
                self.labelRate.text = "1 \(exchangeRate.baseCurrency) = \(exchangeRate.rate) \(exchangeRate.targetCurrency)"
                self.labeldate.text = "Last update: \(exchangeRate.date)"
            }
        }
    }

    
    /// Performs the conversion of the entered amount to the target currency and displays the result.
    /// - Parameter sender: The button triggering the conversion action.
    @IBAction func convertTapped(_ sender: UIButton) {
        // Checks the user input and the existence of an exchange rate.
        guard let amountText = textFieldAmount.text, let amount = Double(amountText), let rate = currentRate else {
            self.labelResult.text = "Entrée invalide ou taux de change non chargé"
            return
        }

        // Performs the conversion with the current exchange rate and displays the result.
        let convertedAmount = amount * rate
        labelResult.text = String(format: "%.2f USD", convertedAmount)
    }
}
