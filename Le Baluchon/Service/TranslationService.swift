//
//  TranslationService.swift
//  Le Baluchon
//
//  Created by Thomas Carlier on 06/04/2024.
//

import Foundation

/// Manages fetching weather data from the GoogleTranslate API.
class TranslationService {
    // API key for Google Translate.
    private let apiKey = "AIzaSyCxSsQc8WHyOCRDgO-8UbFMZOScvgE0FH0"
    // The base URL of the Google Translate API.
    private let baseUrlString = "https://translation.googleapis.com/language/translate/v2"
    
    /// Translates text from a source language to a target language using the Google Translate API.
    /// - Parameters:
    ///   - text: The text to translate.
    ///   - sourceLanguage: The source language of the text (e.g., "fr" for French).
    ///   - targetLanguage: The target language for the translation (e.g., "en" for English).
    ///   - completion: A closure called with the translated text or an error.
    func translate(text: String, from sourceLanguage: String, to targetLanguage: String, completion: @escaping (TranslationResult?, Error?) -> Void) {
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
                    let result = TranslationResult(originalText: text, translatedText: translatedText, sourceLanguage: sourceLanguage, targetLanguage: targetLanguage)
                    completion(result, nil)
                } else {
                    completion(nil, NSError(domain: "GoogleTranslateModel", code: 4, userInfo: [NSLocalizedDescriptionKey: "Translation not found in response"]))
                }
            } catch {
                completion(nil, error)
            }
        }
        task.resume() // Starts the network task.
    }
}


