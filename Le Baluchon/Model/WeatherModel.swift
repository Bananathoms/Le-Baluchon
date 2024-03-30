//
//  WeatherModel.swift
//  Le Baluchon
//
//  Created by Thomas Carlier on 30/03/2024.
//

import Foundation

/// Réponse principale de l'API météo, contenant les informations météorologiques essentielles.
struct WeatherResponse: Codable {
    let main: WeatherMain
    let weather: [WeatherCondition]
    let name: String // Correspond au "name": "Paris"
    // Ajoutez d'autres propriétés au besoin, en fonction des données que vous souhaitez utiliser
}

/// Contient les informations principales sur la météo, telles que la température et l'humidité.
struct WeatherMain: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
    
    /// Custom keys pour le mapping de JSON vers les propriétés de la structure, permettant de gérer les noms de champs différents.
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case humidity
    }
}

/// Représente une condition météorologique spécifique, comme "ensoleillé" ou "nuageux".
struct WeatherCondition: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

/// Gère la récupération des données météorologiques depuis l'API OpenWeatherMap.
class WeatherModel {
    private let apiKey = "abe459e1d44b33ea60ce9f7a1d51d105"
    private let baseUrl = "https://api.openweathermap.org/data/2.5/weather"
    
    /// Récupère les données météorologiques pour une ville donnée et exécute une closure de complétion avec les résultats.
    /// - Parameters:
    ///   - city: Le nom de la ville pour laquelle récupérer les données météo.
    ///   - completion: Une closure exécutée avec les données météo ou une erreur
    func fetchWeather(forCity city: String, completion: @escaping (WeatherResponse?, Error?) -> Void) {
        // Construit l'URL de la requête en incluant le nom de la ville, la clé API, et les unités en métrique.
        let urlString = "\(baseUrl)?q=\(city)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else {
            // En cas d'URL invalide, appelle la closure de complétion avec une erreur.
            completion(nil, NSError(domain: "WeatherModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        // Effectue la requête réseau.
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                // En cas d'erreur réseau, appelle la closure de complétion avec cette erreur.
                completion(nil, error)
                return
            }
            
            // Vérifie que des données ont été reçues.
            guard let data = data else {
                completion(nil, NSError(domain: "WeatherModel", code: 2, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }
            
            // Tente de décoder la réponse JSON dans les structures Swift.
            do {
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                completion(weatherResponse, nil)
            } catch {
                completion(nil, error)
            }
        }
        
        task.resume() // Démarre la tâche de réseau.
    }
}

