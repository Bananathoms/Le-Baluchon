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

/// Represents an exchange rate between two currencies, including the rate and the date of the rate.
struct ExchangeRate: Codable {
    let baseCurrency: String // The currency from which the conversion starts.
    let targetCurrency: String // The currency to which the conversion is done.
    let rate: Double // The conversion rate from the base currency to the target currency.
    let date: Date // The date when this exchange rate was last updated.
}

struct CurrencyList: Codable {
    let symbols: [String: String]
}

struct Currency: Codable {
    let code: String
    let name: String
}

extension ExchangeRate {
    /// Creates an `ExchangeRate` instance from an `ExchangeRateResponse` object and a specified target currency.
    /// - Parameters:
    ///   - response: The `ExchangeRateResponse` containing the data to create the `ExchangeRate`.
    ///   - targetCurrency: The target currency for which the rate is needed.
    ///   - dateFormatter: A `DateFormatter` to convert the date string to a `Date` object.
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
    
    /// Rounds the given exchange rate to two decimal places.
    /// - Parameter rate: The exchange rate to be rounded.
    /// - Returns: The rounded exchange rate.
    func roundedRate(rate:Double) -> Double {
        return (rate * 100).rounded() / 100
    }
    
    /// Converts an amount from the base currency to the target currency using the exchange rate.
    /// - Parameter amount: The amount in the base currency to be converted.
    /// - Returns: The equivalent amount in the target currency, based on the current exchange rate.
    func convert(amount: Double) -> Double {
        return (amount * rate * 100).rounded() / 100
    }
}
