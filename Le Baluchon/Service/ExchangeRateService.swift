//
//  ExchangeRateService.swift
//  Le Baluchon
//
//  Created by Thomas Carlier on 06/04/2024.
//

import Foundation

/// Model for fetching exchange rates from the Fixer.io API.
class ExchangeRateService {
    // API key used to access the Fixer.io API.
    private let apiKey = "8ab60a4a125337ce98010667e48c33c3"
    var lastExchangeRate: ExchangeRate?
    
    // URLSession
    private let session: URLSession

    init(session: URLSession = URLSession.shared) {
        self.session = session
    }

    /// Fetches the exchange rate between two currencies from the Fixer.io API and executes a completion closure with the results.
    /// This method checks if the exchange rate for the same currencies was already fetched today. If so, it uses the cached rate.
    /// - Parameters:
    ///   - fromCurrency: The starting currency for which to obtain the exchange rate.
    ///   - toCurrency: The target currency for the conversion.
    ///   - completion: A closure that is called with the ExchangeRate object or an error if the request fails.
    func fetchExchangeRateIfNeeded(fromCurrency: String, toCurrency: String, completion: @escaping (ExchangeRate?, Error?) -> Void) {
         let currentDate = Date()
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "yyyy-MM-dd"
         
         // Check if the rate for the specified currencies has already been fetched today
         if let lastExchangeRate = lastExchangeRate,
            dateFormatter.string(from: lastExchangeRate.date) == dateFormatter.string(from: currentDate),
            lastExchangeRate.baseCurrency == fromCurrency,
            lastExchangeRate.targetCurrency == toCurrency {
             // Use the cached rate
             completion(lastExchangeRate, nil)
             return
         }
         
         // Construct the URL for the API request
        guard let baseUrl = URL(string: "http://data.fixer.io/api/latest") else {
            completion(nil, NSError(domain: "ExchangeRateService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid base URL"]))
            return
        }
        var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)
        components?.queryItems = [
            URLQueryItem(name: "access_key", value: apiKey),
            URLQueryItem(name: "base", value: fromCurrency),
            URLQueryItem(name: "symbols", value: toCurrency)
        ]
         
        guard let url = components?.url else {
            completion(nil, NSError(domain: "ExchangeRateService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid URL components"]))
            return
        }
         
         // Perform the network request
         let task = session.dataTask(with: url) { [weak self] data, response, error in
             guard let data = data, error == nil else {
                 completion(nil, error)
                 return
             }
             
             do {
                 // Decode the JSON response
                 let decodedResponse = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
                 if let rate = decodedResponse.rates[toCurrency] {
                     let exchangeRate = ExchangeRate(baseCurrency: fromCurrency, targetCurrency: toCurrency, rate: rate, date: currentDate)
                     self?.lastExchangeRate = exchangeRate // Cache the rate
                     completion(exchangeRate, nil)
                 } else {
                     completion(nil, NSError(domain: "ExchangeRateService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Rate not found for target currency"]))
                 }
             } catch {
                 completion(nil, error)
             }
         }
         task.resume()
     }
}


