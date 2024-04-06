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
    private let baseUrl = "http://data.fixer.io/api/"
    var lastExchangeRate: ExchangeRate?

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
        
        if let lastExchangeRate = lastExchangeRate,
           dateFormatter.string(from: lastExchangeRate.date) == dateFormatter.string(from: currentDate),
           lastExchangeRate.baseCurrency == fromCurrency, lastExchangeRate.targetCurrency == toCurrency {
            completion(lastExchangeRate, nil)
            return
        }
        
        let urlString = "\(baseUrl)latest?access_key=\(apiKey)&base=\(fromCurrency)&symbols=\(toCurrency)"
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "ExchangeRateService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "ExchangeRateService", code: 2, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode(ExchangeRateResponse.self, from: data)
                if let rate = decodedResponse.rates[toCurrency] {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    let rateDate = formatter.date(from: decodedResponse.date) ?? Date()
                    let exchangeRate = ExchangeRate(baseCurrency: decodedResponse.base, targetCurrency: toCurrency, rate: rate, date: rateDate)
                    self?.lastExchangeRate = exchangeRate
                    completion(exchangeRate, nil)
                } else {
                    completion(nil, NSError(domain: "ExchangeRateService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Rate not found for target currency"]))
                }
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }
}


