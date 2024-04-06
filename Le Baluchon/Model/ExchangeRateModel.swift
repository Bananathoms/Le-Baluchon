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

/// Model for fetching exchange rates from the Fixer.io API.
class ExchangeRateModel {
    // API key used to access the Fixer.io API.
    static let apiKey = "8ab60a4a125337ce98010667e48c33c3"
    
    /// Fetches the exchange rate between two currencies from the Fixer.io API and executes a completion closure with the results.
    /// - Parameters:
    ///   - fromCurrency: The starting currency for which to obtain the exchange rate.
    ///   - toCurrency: The target currency for the conversion.
    ///   - completion: A closure that is called with the exchange rate, base currency, the date of the last update, or an error if the request fails.
    func fetchExchangeRate(fromCurrency: String, toCurrency: String, completion: @escaping (ExchangeRate?, Error?) -> Void) {
        let urlString = "http://data.fixer.io/api/latest?access_key=\(ExchangeRateModel.apiKey)&symbols=\(toCurrency)"
        
        // Checking the validity of the URL.
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "ExchangeRateModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Handling network request errors.
            if let error = error {
                completion(nil, error)
                return
            }
            
            // Checking for data in the response.
            guard let data = data else {
                completion(nil, NSError(domain: "ExchangeRateModel", code: 2, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }
            
            // Attempting to decode the JSON response into the ExchangeRateResponse structure.
            do {
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode(ExchangeRateResponse.self, from: data)
                if let rate = decodedResponse.rates[toCurrency] {
                    let exchangeRate = ExchangeRate(baseCurrency: decodedResponse.base, targetCurrency: toCurrency, rate: rate, date: decodedResponse.date)
                    completion(exchangeRate, nil)
                } else {
                    completion(nil, NSError(domain: "ExchangeRateModel", code: 3, userInfo: [NSLocalizedDescriptionKey: "Rate not found for target currency"]))
                }
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }
}
