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
    
    // Instance du modèle météo pour récupérer les données de l'API OpenWeatherMap
    let weatherModel = WeatherModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Effectue une requête initiale pour obtenir les données météo pour une ville spécifique dès le chargement de la vue.
        fetchWeatherData(forCity: "Paris")
    }
    /// Récupère les données météorologiques pour une ville spécifiée et met à jour l'interface utilisateur en conséquence.
        /// - Parameter city: Le nom de la ville pour laquelle récupérer les données météo.
        func fetchWeatherData(forCity city: String) {
            weatherModel.fetchWeather(forCity: city) { [weak self] weatherResponse, error in
                DispatchQueue.main.async {
                    if let error = error {
                        // En cas d'erreur, affichez un message approprié.
                        print("Erreur lors de la récupération des données météo: \(error.localizedDescription)")
                        return
                    }
                    
                    // Gérer le cas où aucun résultat n'est retourné.
                    guard let weatherResponse = weatherResponse else {
                        print("Aucune donnée météo disponible.")
                        return
                    }
                    
                    // Mise à jour de l'interface utilisateur avec les données météo reçues.
                    self?.updateUI(with: weatherResponse)
                }
            }
        }
        
    /// Met à jour l'interface utilisateur avec les données météorologiques fournies.
    /// - Parameter weatherData: Les données météorologiques à afficher.
    func updateUI(with weatherData: WeatherResponse) {
        locationLabel.text = weatherData.name
        currentTemperatureLabel.text = "\(weatherData.main.temp)°C"
        weatherDescriptionLabel.text = weatherData.weather.first?.description.capitalized
        minTemperatureLabel.text = "Min: \(weatherData.main.tempMin)°C"
        maxTemperatureLabel.text = "Max: \(weatherData.main.tempMax)°C"
        
        // Télécharge et affiche l'icône météo basée sur le code d'icône reçu.
        if let iconCode = weatherData.weather.first?.icon {
            downloadWeatherIcon(withCode: iconCode)
        }
    }
    
    /// Télécharge l'icône météo à partir du code d'icône fourni et met à jour `weatherIconImageView`.
    /// - Parameter iconCode: Le code de l'icône météo à télécharger.
    func downloadWeatherIcon(withCode iconCode: String) {
        let urlString = "https://openweathermap.org/img/wn/\(iconCode)@2x.png"
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                // Crée une UIImage à partir des données téléchargées et met à jour l'UIImageView.
                self?.weatherIconImageView.image = UIImage(data: data)
            }
        }
        task.resume()
    }
}
