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

/// Model for fetching exchange rates from the Fixer.io API.
class ExchangeRateModel {
    // API key used to access the Fixer.io API.
    static let apiKey = "8ab60a4a125337ce98010667e48c33c3"
    
    /// Fetches the exchange rate between two currencies from the Fixer.io API and executes a completion closure with the results.
    /// - Parameters:
    ///   - fromCurrency: The starting currency for which to obtain the exchange rate.
    ///   - toCurrency: The target currency for the conversion.
    ///   - completion: A closure that is called with the exchange rate, base currency, the date of the last update, or an error if the request fails.
    func fetchExchangeRate(fromCurrency: String, toCurrency: String, completion: @escaping (Double?, String?, String?, Error?) -> Void) {
        // Constructing the URL for the API request using the API key and the specified currencies.
        let urlString = "http://data.fixer.io/api/latest?access_key=\(ExchangeRateModel.apiKey)&symbols=\(toCurrency)"
        
        // Checking the validity of the URL.
        guard let url = URL(string: urlString) else {
            completion(nil, nil, nil, NSError(domain: "ExchangeRateModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        // Creating and starting a network session task to perform the HTTP request.
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Handling network request errors.
            if let error = error {
                completion(nil, nil, nil, error)
                return
            }
            
            // Checking for data in the response.
            guard let data = data else {
                completion(nil, nil, nil, NSError(domain: "ExchangeRateModel", code: 2, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }
            
            // Attempting to decode the JSON response into the ExchangeRateResponse structure.
            do {
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode(ExchangeRateResponse.self, from: data)
                // Extracting the exchange rate, base currency, and date from the decoded response.
                let rate = decodedResponse.rates[toCurrency]
                let base = decodedResponse.base
                let date = decodedResponse.date
                // Calling the completion closure with the results.
                completion(rate, base, date, nil)
            } catch {
                // Handling decoding errors.
                completion(nil, nil, nil, error)
            }
        }
        task.resume() // Starts the network task.
    }
}
