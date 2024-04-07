//
//  ExchangeRateService.swift
//  Le Baluchon
//
//  Created by Thomas Carlier on 06/04/2024.
//

import Foundation

/// Service responsible for fetching and managing exchange rates from the Fixer.io API.
class ExchangeRateService {
    // API key to access the Fixer.io API.
    private let apiKey = "8ab60a4a125337ce98010667e48c33c3"
    // Session used for network calls.
    private let session: URLSession
    
    /// Initializes the service with a specific session for testing or uses URLSession.shared by default.
    /// - Parameter session: The URLSession to use for network calls.
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    // Key used to store the last fetched exchange rate in UserDefaults.
    private let lastExchangeRateKey = "lastExchangeRate"
    
    /// Saves the last fetched exchange rate in UserDefaults for quick access without needing a network call.
    /// - Parameter exchangeRate: The exchange rate to save.
    private func saveLastExchangeRate(_ exchangeRate: ExchangeRate) {
        let defaults = UserDefaults.standard
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(exchangeRate) {
            defaults.set(encoded, forKey: lastExchangeRateKey)
        }
    }
    
    /// Attempts to load the last saved exchange rate from UserDefaults.
    /// - Returns: The last saved exchange rate if available, otherwise nil.
    private func loadLastExchangeRate() -> ExchangeRate? {
        let defaults = UserDefaults.standard
        if let savedExchangeRate = defaults.object(forKey: lastExchangeRateKey) as? Data {
            let decoder = JSONDecoder()
            if let loadedExchangeRate = try? decoder.decode(ExchangeRate.self, from: savedExchangeRate) {
                return loadedExchangeRate
            }
        }
        return nil
    }
    
    /// Checks if a network call is necessary to fetch the exchange rate or if recent data is available. Makes a network call if necessary.
        /// - Parameters:
        ///   - fromCurrency: The source currency for which to fetch the exchange rate.
        ///   - toCurrency: The target currency for conversion.
        ///   - completion: A closure called with the exchange rate or an error.
    func fetchExchangeRateIfNeeded(fromCurrency: String, toCurrency: String, completion: @escaping (ExchangeRate?, Error?) -> Void) {
        // Use last exchange rate from UserDefaults
        if let lastExchangeRate = loadLastExchangeRate() {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if dateFormatter.string(from: lastExchangeRate.date) == dateFormatter.string(from: Date()),
               lastExchangeRate.baseCurrency == fromCurrency,
               lastExchangeRate.targetCurrency == toCurrency {
                completion(lastExchangeRate, nil)
                return
            }
        }
        
        // Performs the network call if the saved data is outdated or missing.
        self.performNetworkRequest(fromCurrency: fromCurrency, toCurrency: toCurrency, completion: completion)
    }
    
    /// Performs the network call to fetch the exchange rate from the Fixer.io API.
    /// - Parameters:
    ///   - fromCurrency: The source currency for which to fetch the exchange rate.
    ///   - toCurrency: The target currency for conversion.
    ///   - completion: A closure called with the exchange rate or an error.
    private func performNetworkRequest(fromCurrency: String, toCurrency: String, completion: @escaping (ExchangeRate?, Error?) -> Void) {
        guard let url = URL(string: "http://data.fixer.io/api/latest?access_key=\(apiKey)&base=\(fromCurrency)&symbols=\(toCurrency)") else {
            completion(nil, NSError(domain: "URLCreationError", code: -1, userInfo: nil))
            return
        }
        
        let task = session.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
                if let rate = decodedResponse.rates[toCurrency] {
                    let exchangeRate = ExchangeRate(baseCurrency: fromCurrency, targetCurrency: toCurrency, rate: rate, date: Date())
                    self?.saveLastExchangeRate(exchangeRate)
                    completion(exchangeRate, nil)
                } else {
                    completion(nil, NSError(domain: "RateNotFoundError", code: -2, userInfo: nil))
                }
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }
}
