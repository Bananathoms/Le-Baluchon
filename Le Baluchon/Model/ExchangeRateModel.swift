//
//  ExchangeRateModel.swift
//  Le Baluchon
//
//  Created by Thomas Carlier on 30/03/2024.
//

import Foundation

/// Structure for decoding the response from the Fixer.io API. Conforms to the `Codable` protocol to facilitate decoding from a JSON response.
struct ExchangeRateResponse: Codable {
    let rates: [String: Double] // Dictionary of exchange rates with currency codes as keys.
    let base: String // The base currency used for the exchange rates.
    let date: String // The date of the last update of the exchange rates.
}

struct ExchangeRate {
    let baseCurrency: String
    let targetCurrency: String
    let rate: Double
    let date: Date
}

extension ExchangeRate {
    // An initializer to create an ExchangeRate object from an ExchangeRateResponse object and a target currency.
    init?(from response: ExchangeRateResponse, targetCurrency: String, dateFormatter: DateFormatter) {
        guard let rate = response.rates[targetCurrency],
              let date = dateFormatter.date(from: response.date) else {
            return nil
        }
        
        self.baseCurrency = response.base
        self.targetCurrency = targetCurrency
        self.rate = rate
        self.date = date
    }
    
    /// Converts an amount from the base currency to the target currency using the exchange rate.
    /// - Parameter amount: The amount in the base currency to be converted.
    /// - Returns: The equivalent amount in the target currency, based on the current exchange rate.
    func convert(amount: Double) -> Double {
        return amount * rate
    }
}
