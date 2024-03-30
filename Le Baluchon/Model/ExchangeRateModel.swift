//
//  ExchangeRateModel.swift
//  Le Baluchon
//
//  Created by Thomas Carlier on 30/03/2024.
//

import Foundation

/// Structure pour décoder la réponse de l'API Fixer.io. Conforme au protocole `Codable` pour faciliter le décodage à partir d'une réponse JSON.
struct ExchangeRateResponse: Codable {
    let rates: [String: Double] // Dictionnaire des taux de change avec les codes des devises comme clés.
    let base: String // La devise de base utilisée pour les taux de change.
    let date: String // La date de la dernière mise à jour des taux de change.
}


/// Modèle pour récupérer les taux de change depuis l'API Fixer.io.
class ExchangeRateModel {
    // Clé API utilisée pour accéder à l'API Fixer.io.
    static let apiKey = "8ab60a4a125337ce98010667e48c33c3"
    
    /// Récupère le taux de change entre deux devises depuis l'API Fixer.io et exécute une closure de complétion avec les résultats.
    /// - Parameters:
    ///   - fromCurrency: La devise de départ pour laquelle obtenir le taux de change.
    ///   - toCurrency: La devise cible pour la conversion.
    ///   - completion: Une closure qui est appelée avec le taux de change, la devise de base, la date de la dernière mise à jour, ou une erreur si la requête échoue.
    func fetchExchangeRate(fromCurrency: String, toCurrency: String, completion: @escaping (Double?, String?, String?, Error?) -> Void) {
        // Construction de l'URL pour la requête à l'API en utilisant la clé API et les devises spécifiées.
        let urlString = "http://data.fixer.io/api/latest?access_key=\(ExchangeRateModel.apiKey)&symbols=\(toCurrency)"
        
        // Vérification de la validité de l'URL.
        guard let url = URL(string: urlString) else {
            completion(nil, nil, nil, NSError(domain: "ExchangeRateModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        // Création et démarrage d'une tâche de session de réseau pour effectuer la requête HTTP.
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Gestion des erreurs de requête réseau.
            if let error = error {
                completion(nil, nil, nil, error)
                return
            }
            
            // Vérification de la présence de données dans la réponse.
            guard let data = data else {
                completion(nil, nil, nil, NSError(domain: "ExchangeRateModel", code: 2, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }
            
            // Tentative de décodage de la réponse JSON dans la structure ExchangeRateResponse.
            do {
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode(ExchangeRateResponse.self, from: data)
                // Extraction du taux de change, de la devise de base et de la date à partir de la réponse décodée.
                let rate = decodedResponse.rates[toCurrency]
                let base = decodedResponse.base
                let date = decodedResponse.date
                // Appel de la closure de complétion avec les résultats.
                completion(rate, base, date, nil)
            } catch {
                // Gestion des erreurs de décodage.
                completion(nil, nil, nil, error)
            }
        }
        task.resume()
    }
}

