//
//  WeatherService.swift
//  Le Baluchon
//
//  Created by Thomas Carlier on 06/04/2024.
//

import Foundation

/// Manages fetching weather data from the OpenWeatherMap API.
class WeatherService {
    private let apiKey: String
    private let baseUrl: String
    private var session: URLSession

    /// Initializes a new WeatherService.
    /// - Parameters:
    ///   - session: The URLSession to use for network requests. Defaults to `.shared` for production use.
    ///   - apiKey: The API key for authenticating requests to the OpenWeatherMap API.
    ///   - baseUrl: The base URL for the OpenWeatherMap API endpoints.
    init(session: URLSession = URLSession.shared, apiKey: String = "abe459e1d44b33ea60ce9f7a1d51d105", baseUrl: String = "https://api.openweathermap.org/data/2.5/weather") {
        self.session = session
        self.apiKey = apiKey
        self.baseUrl = baseUrl
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
