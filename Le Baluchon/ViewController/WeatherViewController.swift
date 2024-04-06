//
//  WeatherViewController.swift
//  Le Baluchon
//
//  Created by Thomas Carlier on 29/03/2024.
//

import UIKit

class WeatherViewController: UIViewController {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var currentTemperatureLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var minTemperatureLabel: UILabel!
    @IBOutlet weak var maxTemperatureLabel: UILabel!
    
    // Weather model instance to fetch data from the OpenWeatherMap API
    let weatherModel = WeatherModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Performs an initial request to get weather data for a specific city upon view loading.
        fetchWeatherData(forCity: "Paris")
    }
    /// Fetches weather data for a specified city and updates the UI accordingly.
    /// - Parameter city: The name of the city to retrieve weather data for.
    func fetchWeatherData(forCity city: String) {
        weatherModel.fetchWeather(forCity: city) { [weak self] weatherResponse, error in
            DispatchQueue.main.async {
                if let error = error {
                    // Displays an appropriate message in case of an error.
                    print("Erreur lors de la récupération des données météo: \(error.localizedDescription)")
                    return
                }
                
                // Handle the case where no result is returned.
                guard let weatherResponse = weatherResponse else {
                    print("Aucune donnée météo disponible.")
                    return
                }
                
                // Update the UI with the received weather data.
                self?.updateUI(with: weatherResponse)
            }
        }
    }
    
    /// Updates the UI with the provided weather data.
    /// - Parameter weatherData: The weather data to display.
    func updateUI(with weatherData: WeatherResponse) {
        locationLabel.text = weatherData.name
        currentTemperatureLabel.text = "\(weatherData.main.temp)°C"
        weatherDescriptionLabel.text = weatherData.weather.first?.description.capitalized
        minTemperatureLabel.text = "Min: \(weatherData.main.tempMin)°C"
        maxTemperatureLabel.text = "Max: \(weatherData.main.tempMax)°C"
        
        // Downloads and displays the weather icon based on the received icon code.
        if let iconCode = weatherData.weather.first?.icon {
            downloadWeatherIcon(withCode: iconCode)
        }
    }
    
    /// Downloads the weather icon from the provided icon code and updates `weatherIconImageView`.
    /// - Parameter iconCode: The icon code of the weather to download.
    func downloadWeatherIcon(withCode iconCode: String) {
        let urlString = "https://openweathermap.org/img/wn/\(iconCode)@2x.png"
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                // Creates a UIImage from the downloaded data and updates the UIImageView.
                self?.weatherIconImageView.image = UIImage(data: data)
            }
        }
        task.resume()
    }
}
