//
//  WeatherModel.swift
//  Le Baluchon
//
//  Created by Thomas Carlier on 30/03/2024.
//

import Foundation

/// Main weather API response, containing essential weather information.
struct WeatherResponse: Codable {
    let main: WeatherMain
    let weather: [WeatherCondition]
    let name: String // Corresponds to "name": "Paris"
    // Add other properties as needed, based on the data you want to use
}

/// Contains main weather information, such as temperature and humidity.
struct WeatherMain: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
    
    /// Custom keys for mapping JSON to the structure's properties, allowing for handling of different field names.
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case humidity
    }
}

/// Represents a specific weather condition, such as "sunny" or "cloudy".
struct WeatherCondition: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

/// Manages fetching weather data from the OpenWeatherMap API.
class WeatherModel {
    private let apiKey = "abe459e1d44b33ea60ce9f7a1d51d105"
    private let baseUrl = "https://api.openweathermap.org/data/2.5/weather"
    
    /// Fetches weather data for a given city and executes a completion closure with the results.
    /// - Parameters:
    ///   - city: The name of the city for which to retrieve weather data.
    ///   - completion: A closure executed with the weather data or an error.
    func fetchWeather(forCity city: String, completion: @escaping (WeatherResponse?, Error?) -> Void) {
        // Constructs the request URL including the city name, API key, and metric units.
        let urlString = "\(baseUrl)?q=\(city)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else {
            // If the URL is invalid, calls the completion closure with an error.
            completion(nil, NSError(domain: "WeatherModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        // Performs the network request.
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                // In case of a network error, calls the completion closure with this error.
                completion(nil, error)
                return
            }
            
            // Checks that data was received.
            guard let data = data else {
                completion(nil, NSError(domain: "WeatherModel", code: 2, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }
            
            // Attempts to decode the JSON response into Swift structures.
            do {
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                completion(weatherResponse, nil)
            } catch {
                completion(nil, error)
            }
        }
        
        task.resume() // Starts the network task.
    }
}
