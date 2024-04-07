//
//  WeatherService.swift
//  Le Baluchon
//
//  Created by Thomas Carlier on 06/04/2024.
//

import Foundation

/// Manages fetching weather data from the OpenWeatherMap API.
class WeatherService {
    private let apiKey = "abe459e1d44b33ea60ce9f7a1d51d105"
    private let baseUrl = "https://api.openweathermap.org/data/2.5/weather"
    private var session: URLSession
    
    // Ajoutez un paramètre de session avec une valeur par défaut à URLSession.shared pour le rendre testable.
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    /// Fetches weather data for a given city and executes a completion closure with the results.
    /// - Parameters:
    ///   - city: The name of the city for which to retrieve weather data.
    ///   - completion: A closure executed with the weather data or an error.
    func fetchWeather(forCity city: String, completion: @escaping (WeatherResponse?, Error?) -> Void) {
        guard let url = URL(string: "\(baseUrl)?q=\(city)&appid=\(apiKey)&units=metric") else {
            completion(nil, NSError(domain: "WeatherService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }

        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = data else {
                completion(nil, NSError(domain: "WeatherService", code: 2, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }

            do {
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                completion(weatherResponse, nil)
            } catch {
                completion(nil, error)
            }
        }

        task.resume()
    }
}
