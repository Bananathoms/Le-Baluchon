//
//  TitleViewController.swift
//  Le Baluchon
//
//  Created by Thomas Carlier on 29/03/2024.
//

import UIKit

/// ViewController responsible for displaying and converting exchange rates.
class ExchangeRateViewController: UIViewController {
    @IBOutlet weak var labelBase: UILabel!
    @IBOutlet weak var labelTarget: UILabel!
    @IBOutlet weak var labelRate: UILabel!
    @IBOutlet weak var labeldate: UILabel!
    @IBOutlet weak var textFieldAmount: UITextField!
    @IBOutlet weak var labelResult: UILabel!
    
    let exchangeRateService = ExchangeRateService()
    var currentExchangeRate: ExchangeRate?
    
    /// Configures the ViewController after the view has loaded.
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(currencyChanged), name: UserDefaults.didChangeNotification, object: nil)
        
        // Adds a tap gesture recognizer to hide the keyboard when the user taps elsewhere on the screen.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCurrencySettings()
    }
    
    @objc func currencyChanged() {
        updateCurrencySettings()
    }
    
    func updateCurrencySettings() {
        let toCurrency = UserDefaults.standard.string(forKey: "DestinationCurrency") ?? "USD"
        loadExchangeRate(fromCurrency: "EUR", toCurrency: toCurrency)
    }
    
    /// Method called to hide the keyboard.
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    /// Loads the exchange rate data from the API and updates the UI accordingly.
    /// - Parameters:
    ///   - fromCurrency: The source currency for fetching the exchange rate.
    ///   - toCurrency: The target currency for conversion.
    func loadExchangeRate(fromCurrency: String, toCurrency: String) {
        self.exchangeRateService.fetchExchangeRateIfNeeded(fromCurrency: fromCurrency, toCurrency: toCurrency) { [weak self] (exchangeRate, error) in
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
                
                self.currentExchangeRate = exchangeRate
                self.updateUI(with: exchangeRate)
            }
        }
    }
    
    /// Updates the UI with the fetched exchange rate.
    /// - Parameter exchangeRate: The exchange rate to display.
    func updateUI(with exchangeRate: ExchangeRate) {
        self.labelBase.text = "Base Currency: \(exchangeRate.baseCurrency)"
        self.labelTarget.text = "Target Currency: \(exchangeRate.targetCurrency)"
        self.labelRate.text = "1 \(exchangeRate.baseCurrency) = \(exchangeRate.rate) \(exchangeRate.targetCurrency)"
        self.labeldate.text = "Last Update: \(formatDateToString(exchangeRate.date))"
    }
    
    /// Performs the conversion of the entered amount to the target currency and displays the result.
    /// - Parameter sender: The button triggering the conversion action.
    @IBAction func convertTapped(_ sender: UIButton) {
        guard let amountText = textFieldAmount.text, let amount = Double(amountText), let exchangeRate = currentExchangeRate else {
            labelResult.text = "Invalid input or exchange rate not loaded"
            return
        }
        
        let convertedAmount = amount * exchangeRate.rate
        labelResult.text = "\(convertedAmount) \(exchangeRate.targetCurrency)"
    }
    
    /// Converts a Date object into a formatted string for display.
    /// - Parameter date: The date to format.
    /// - Returns: A string representation of the date.
    private func formatDateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
