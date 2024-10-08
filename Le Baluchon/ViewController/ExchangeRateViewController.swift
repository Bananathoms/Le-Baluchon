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
    
    /// Called before the view controller's view is about to be added to a view hierarchy and is visible to the user.
    /// - Parameter animated: A Boolean value indicating whether the appearance of the view is being animated.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Updates the currency settings whenever the view is about to appear.
        self.updateCurrencySettings()
    }
    
    /// Handles the notification when the currency is changed and triggers the update of currency settings.
    @objc func currencyChanged() {
        self.updateCurrencySettings()
    }
    
    /// Updates the currency settings based on the user's selection.
    func updateCurrencySettings() {
        let toCurrency = UserDefaults.standard.string(forKey: "DestinationCurrency") ?? "USD"
        self.loadExchangeRate(fromCurrency: "EUR", toCurrency: toCurrency)
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
                    self.showAlert(title: "Error", message: "Error fetching exchange rates: \(error.localizedDescription)")
                    return
                }
                
                guard let exchangeRate = exchangeRate else {
                    self.showAlert(title: "Error", message: "Exchange rate not available.")
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
        
        let roundedRate = exchangeRate.roundedRate(rate: exchangeRate.rate)
        
        self.labelBase.text = "Base Currency: \(exchangeRate.baseCurrency)"
        self.labelTarget.text = "Target Currency: \(exchangeRate.targetCurrency)"
        self.labelRate.text = "1 \(exchangeRate.baseCurrency) = \(roundedRate) \(exchangeRate.targetCurrency)"
        self.labeldate.text = "Last Update: \(formatDateToString(exchangeRate.date))"
    }
    
    /// Performs the conversion of the entered amount to the target currency and displays the result.
    /// - Parameter sender: The button triggering the conversion action.
    @IBAction func convertTapped(_ sender: UIButton) {
        guard let amountText = textFieldAmount.text, let amount = Double(amountText), let exchangeRate = currentExchangeRate else {
            self.showAlert(title: "Input Error", message: "Invalid input or exchange rate not loaded.")
            return
        }
        
        let convertedAmount = self.currentExchangeRate?.convert(amount: amount)
        self.labelResult.text = "\(convertedAmount ?? 0) \(exchangeRate.targetCurrency)"
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
