//
//  TranslationTest.swift
//  Le BaluchonTests
//
//  Created by Thomas Carlier on 07/04/2024.
//

import XCTest
@testable import Le_Baluchon

/// Tests for the TranslationService class.
class TranslationServiceTests: XCTestCase {
    var service: TranslationService!
    var sessionMock: URLSessionFake!

    /// Sets up the test environment before each test.
    override func setUp() {
        super.setUp()
        self.sessionMock = URLSessionFake(data: nil, response: nil, error: nil)
        self.service = TranslationService(session: sessionMock)
    }


    /// Tears down the test environment after each test.
    override func tearDown() {
        self.service = nil
        self.sessionMock = nil
        super.tearDown()
    }
    
    func testURLEncoderClosure() {
        // Given
        let inputText = "Bonjour, ça va ?"
        let expectedEncodedText = "Bonjour,%20%C3%A7a%20va%20?" // Résultat attendu après encodage
        
        // When
        let encodedText = service.urlEncoder(inputText)
        
        // Then
        XCTAssertEqual(encodedText, expectedEncodedText, "Encoded text does not match expected value.")
    }

    /// Tests if translating text successfully calls the completion with correct translated text.
    func testTranslateSuccess() {
        let expectedText = "Good morning"
        let fakeData = """
        {
            "data": {
                "translations": [
                    { "translatedText": "\(expectedText)" }
                ]
            }
        }
        """.data(using: .utf8)!
        sessionMock.data = fakeData
        let expectation = self.expectation(description: "Translate text successfully.")

        service.translate(text: "Bonjour", from: "fr", to: "en") { result, error in
            XCTAssertNil(error)
            XCTAssertNotNil(result)
            XCTAssertEqual(result?.translatedText, expectedText)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    /// Tests if translating text with a network error calls the completion with an error.
    func testTranslateFailure() {
        let error = NSError(domain: "TestError", code: 1, userInfo: nil)
        sessionMock.error = error
        sessionMock.data = nil
        let expectation = self.expectation(description: "Translate text fails with error.")

        service.translate(text: "Bonjour", from: "fr", to: "en") { result, error in
            XCTAssertNotNil(error)
            XCTAssertNil(result)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    /// Tests the JSON decoding of the translation response.
    func testTranslationDecoding() {
        let jsonData = """
        {
            "data": {
                "translations": [
                    { "translatedText": "Hello" }
                ]
            }
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(TranslateResponse.self, from: jsonData)
            let translations = response.data.translations
            XCTAssertFalse(translations.isEmpty)
            XCTAssertEqual(translations.first?.translatedText, "Hello")
        } catch {
            XCTFail("Decoding failed: \(error)")
        }
    }
    
    /// Tests the service's handling of an empty response, simulating a situation where no data is returned from the server.
    func testTranslateWithEmptyResponse() {
        // Given
        sessionMock.data = Data() // Aucune donnée
        let expectation = self.expectation(description: "Translate text with empty response.")

        // When
        service.translate(text: "Salut", from: "fr", to: "en") { result, error in
            // Then
            XCTAssertNil(result, "Expected no result for an empty response.")
            XCTAssertNotNil(error, "Expected an error for an empty response.")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    /// Verifies the behavior of the translation service when receiving a malformed JSON response, ensuring that an error is returned.
    func testTranslateWithMalformedResponse() {
        // Given
        let malformedData = "This is not JSON".data(using: .utf8)!
        sessionMock.data = malformedData
        let expectation = self.expectation(description: "Translate text with malformed response.")

        // When
        service.translate(text: "Bonjour", from: "fr", to: "en") { result, error in
            // Then
            XCTAssertNil(result, "Expected no result for a malformed response.")
            XCTAssertNotNil(error, "Expected an error for a malformed response.")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    /// Simulates the failure of URL encoding the input text, ensuring the service properly handles and reports the error.
    func testTranslateWithEncodingFailure() {
        // Given
        let service = TranslationService(session: sessionMock, urlEncoder: { _ in return nil as String? })
        
        let expectation = self.expectation(description: "Completion handler called with encoding failure.")
        
        // When
        service.translate(text: "This will not encode", from: "fr", to: "en") { result, error in
            // Then
            XCTAssertNil(result, "Expected no result due to encoding failure.")
            XCTAssertNotNil(error, "Expected an error due to encoding failure.")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }

}
