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
    let date: String
}
