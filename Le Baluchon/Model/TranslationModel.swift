//
//  TranslationModel.swift
//  Le Baluchon
//
//  Created by Thomas Carlier on 30/03/2024.
//

import Foundation

// Modèles pour décoder la réponse JSON de l'API Google Translate.
struct TranslateResponse: Codable {
    let data: TranslationsData
}

struct TranslationsData: Codable {
    let translations: [Translation]
}

struct Translation: Codable {
    let translatedText: String
}

/// Modèle pour interagir avec l'API Google Translate.
class TranslationModel {
    // Clé API pour Google Translate.
    private let apiKey = "AIzaSyCxSsQc8WHyOCRDgO-8UbFMZOScvgE0FH0"
    // L'URL de base de l'API Google Translate.
    private let baseUrlString = "https://translation.googleapis.com/language/translate/v2"
    
    /// Traduit un texte d'une langue source vers une langue cible en utilisant l'API Google Translate.
    /// - Parameters:
    ///   - text: Le texte à traduire.
    ///   - sourceLanguage:  La langue source du texte (par exemple, "fr" pour le français).
    ///   - targetLanguage: La langue cible pour la traduction (par exemple, "en" pour l'anglais).
    ///   - completion: Une closure appelée avec le texte traduit ou une erreur.
    func translate(text: String, from sourceLanguage: String, to targetLanguage: String, completion: @escaping (String?, Error?) -> Void) {
        guard let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(nil, NSError(domain: "GoogleTranslateModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode text"]))
            return
        }
        
        let urlString = "\(baseUrlString)?key=\(apiKey)&q=\(encodedText)&source=\(sourceLanguage)&target=\(targetLanguage)"
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "GoogleTranslateModel", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "GoogleTranslateModel", code: 3, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(TranslateResponse.self, from: data)
                if let translatedText = decodedResponse.data.translations.first?.translatedText {
                    completion(translatedText, nil)
                } else {
                    completion(nil, NSError(domain: "GoogleTranslateModel", code: 4, userInfo: [NSLocalizedDescriptionKey: "Translation not found in response"]))
                }
            } catch {
                completion(nil, error)
            }
        }
        
        task.resume()
    }
}
