//
//  ExchangeRateService.swift
//  Le Baluchon
//
//  Created by Thomas Carlier on 06/04/2024.
//

import Foundation

/// <#Description#>
class ExchangeRateService {
    private let apiKey = "8ab60a4a125337ce98010667e48c33c3"
    private let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    // Utilisez une clé constante pour accéder aux données stockées
    private let lastExchangeRateKey = "lastExchangeRate"
    
    // Sauvegarder le dernier taux de change dans UserDefaults
    private func saveLastExchangeRate(_ exchangeRate: ExchangeRate) {
        let defaults = UserDefaults.standard
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(exchangeRate) {
            defaults.set(encoded, forKey: lastExchangeRateKey)
        }
    }
    
    /// Charger le dernier taux de change depuis UserDefaults
    /// - Returns: <#description#>
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
    
    /// <#Description#>
    /// - Parameters:
    ///   - fromCurrency: <#fromCurrency description#>
    ///   - toCurrency: <#toCurrency description#>
    ///   - completion: <#completion description#>
    func fetchExchangeRateIfNeeded(fromCurrency: String, toCurrency: String, completion: @escaping (ExchangeRate?, Error?) -> Void) {
        // Charger le dernier taux de change depuis UserDefaults
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
        
        // Faire un appel réseau si les données sont obsolètes ou manquantes
        self.performNetworkRequest(fromCurrency: fromCurrency, toCurrency: toCurrency, completion: completion)
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - fromCurrency: <#fromCurrency description#>
    ///   - toCurrency: <#toCurrency description#>
    ///   - completion: <#completion description#>
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
