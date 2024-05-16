//
//  TranslationModel.swift
//  Le Baluchon
//
//  Created by Thomas Carlier on 30/03/2024.
//

import Foundation

// Models to decode the JSON response from the Google Translate API.
struct TranslateResponse: Codable {
    let data: TranslationsData
}

struct TranslationsData: Codable {
    let translations: [Translation]
}

struct Translation: Codable {
    let translatedText: String
}

struct TranslationResult: Codable {
    let originalText: String
    let translatedText: String
    let sourceLanguage: String
    let targetLanguage: String
}

struct LanguagesList: Codable {
    let data: LanguagesData
}

struct LanguagesData: Codable {
    let languages: [Language]
}

struct Language: Codable {
    let language: String
    let name: String
}

