//
//  WeatherViewController.swift
//  Le Baluchon
//
//  Created by Thomas Carlier on 29/03/2024.
//

import UIKit

import UIKit

/// A view controller responsible for displaying weather information for two cities, a home city and a destination city.
class WeatherViewController: UIViewController {
    
    // Outlets for home city weather information
    @IBOutlet weak var homeCityName: UILabel!
    @IBOutlet weak var homeWeatherIcon: UIImageView!
    @IBOutlet weak var homeActualTemp: UILabel!
    @IBOutlet weak var homeWeatherDescription: UILabel!
    @IBOutlet weak var homeHumidityRate: UILabel!
    @IBOutlet weak var homeMinTemp: UILabel!
    @IBOutlet weak var homeMaxTemp: UILabel!
    
    // Outlets for destination city weather information
    @IBOutlet weak var destinationCityName: UILabel!
    @IBOutlet weak var destinationWeatherIcon: UIImageView!
    @IBOutlet weak var destinationActualTemp: UILabel!
    @IBOutlet weak var destinationWeatherDescription: UILabel!
    @IBOutlet weak var destinationHumidityRate: UILabel!
    @IBOutlet weak var destinationMinTemp: UILabel!
    @IBOutlet weak var destinationMaxTemp: UILabel!
    
    // Instance of WeatherService to fetch weather data
    let weatherService = WeatherService()
    
    // Initializes the view controller and triggers the retrieval of weather data for specified cities.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch weather for both cities
        self.fetchWeather(forCity: "Paris", isHome: true)
        self.fetchWeather(forCity: "New York", isHome: false)
    }
    
    ///  Fetches weather data for a specified city and updates the UI accordingly.
    /// - Parameters:
    ///   - city: The name of the city to retrieve weather data for.
    ///   - isHome: A boolean indicating if the city is the home city (true) or the destination city (false).
    private func fetchWeather(forCity city: String, isHome: Bool) {
        self.weatherService.fetchWeather(forCity: city) { [weak self] response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching weather: \(error)")
                    return
                }
                guard let weatherData = response else {
                    print("No weather data available")
                    return
                }
                
                // Update UI based on which city the data is for
                if isHome {
                    self?.updateUI(with: weatherData, isHome: true)
                } else {
                    self?.updateUI(with: weatherData, isHome: false)
                }
            }
        }
    }
    
    /// Updates the UI with the provided weather data.
    /// - Parameters:
    ///   - weatherData: The weather data to display.
    ///   - isHome: A boolean indicating if the data is for the home city (true) or the destination city (false).
    private func updateUI(with weatherData: WeatherResponse, isHome: Bool) {
        let cityLabel = isHome ? homeCityName : destinationCityName
        let tempLabel = isHome ? homeActualTemp : destinationActualTemp
        let descriptionLabel = isHome ? homeWeatherDescription : destinationWeatherDescription
        let humidityLabel = isHome ? homeHumidityRate : destinationHumidityRate
        let minTempLabel = isHome ? homeMinTemp : destinationMinTemp
        let maxTempLabel = isHome ? homeMaxTemp : destinationMaxTemp
        let iconImageView = isHome ? homeWeatherIcon : destinationWeatherIcon
        
        cityLabel?.text = weatherData.name
        tempLabel?.text = "\(weatherData.main.temp)°C"
        descriptionLabel?.text = weatherData.weather.first?.description.capitalized
        humidityLabel?.text = "Humidity: \(weatherData.main.humidity)%"
        minTempLabel?.text = "Min: \(weatherData.main.tempMin)°C"
        maxTempLabel?.text = "Max: \(weatherData.main.tempMax)°C"
        
        if let iconCode = weatherData.weather.first?.icon {
            self.fetchIcon(for: iconCode, imageView: iconImageView)
        }
    }
    
    /// Downloads the weather icon from the provided icon code and updates the specified imageView.
    /// - Parameters:
    ///   - iconCode: The icon code of the weather to download.
    ///   - imageView: The UIImageView to update with the icon.
    private func fetchIcon(for iconCode: String, imageView: UIImageView?) {
        let iconURLString = "https://openweathermap.org/img/wn/\(iconCode)@2x.png"
        guard let url = URL(string: iconURLString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, error == nil {
                DispatchQueue.main.async {
                    imageView?.image = UIImage(data: data)
                }
            }
        }.resume()
    }
}

