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
