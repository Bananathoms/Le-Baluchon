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
}
