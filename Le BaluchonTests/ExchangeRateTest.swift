// ExchangeRateTest.swift
// Le BaluchonTests
//
// Created by Thomas Carlier on 07/04/2024.
//

import XCTest
@testable import Le_Baluchon

/// Tests for the `ExchangeRateService` class to ensure it properly handles fetching exchange rates.
/// These tests validate both successful fetches and error handling, including simulated network responses.
class ExchangeRateServiceTests: XCTestCase {
    // The exchange rate service under test. Initialized with a mock URLSession.
    var service: ExchangeRateService!
    // A mock URLSession used to simulate network responses.
    var sessionFake: URLSessionFake!
    
    /// Sets up the testing environment before each test runs. This includes clearing UserDefaults
    /// to ensure a clean state and initializing `service` with a `sessionFake` to simulate network responses.
    override func setUp() {
        super.setUp()
        // Clear UserDefaults before each test to ensure a clean state
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
        // Initialize sessionFake with no predefined behavior
        sessionFake = URLSessionFake(data: nil, response: nil, error: nil)
        // Initialize the service with the mock session
        service = ExchangeRateService(session: sessionFake)
    }
    
    /// Cleans up the testing environment after each test completes. This includes setting
    /// `service` and `sessionFake` to nil to break any potential reference cycles.
    override func tearDown() {
        service = nil
        sessionFake = nil
        super.tearDown()
    }
    
    /// Helper function to simulate a cached exchange rate in UserDefaults.
    /// This is used to test the behavior of fetching exchange rates when cached data exists.
    /// - Parameters:
    ///   - rate: The exchange rate value to cache.
    ///   - base: The base currency code for the cached rate.
    ///   - target: The target currency code for the cached rate.
    private func simulateCachedExchangeRate(rate: Double, base: String, target: String) {
        let exchangeRate = ExchangeRate(baseCurrency: base, targetCurrency: target, rate: rate, date: Date())
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(exchangeRate) {
            UserDefaults.standard.set(encoded, forKey: "lastExchangeRate")
        }
    }
    
    /// Tests that `fetchExchangeRateIfNeeded` correctly calls its completion handler with an error
    /// when the URLSessionFake simulates an error response.
    func testFetchExchangeRateShouldPostFailedCallbackIfError() {
        // Configure the sessionFake to simulate an error
        sessionFake.error = NSError(domain: "testError", code: 1, userInfo: nil)
        
        let expectation = self.expectation(description: "Waiting for network call")
        
        service.fetchExchangeRateIfNeeded(fromCurrency: "EUR", toCurrency: "USD") { exchangeRate, error in
            XCTAssertNotNil(error, "An error was expected but none was received.")
            XCTAssertNil(exchangeRate, "No exchangeRate was expected but one was received.")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    /// Tests that `fetchExchangeRateIfNeeded` correctly calls its completion handler with valid
    /// exchange rate data when the URLSessionFake is configured to return successful response data.
    func testFetchExchangeRateShouldPostSuccessCallbackIfNoErrorAndCorrectData() {
        // Configure sessionFake with valid data to simulate a successful response
        let correctData = """
        {
            "rates": {"USD": 1.2},
            "base": "EUR",
            "date": "2024-04-07"
        }
        """.data(using: .utf8)!
        sessionFake.data = correctData
        sessionFake.response = HTTPURLResponse(url: URL(string: "http://data.fixer.io/api/")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        let expectation = self.expectation(description: "Waiting for network call")
        
        service.fetchExchangeRateIfNeeded(fromCurrency: "EUR", toCurrency: "USD") { exchangeRate, error in
            XCTAssertNil(error, "No error was expected but one was received.")
            XCTAssertNotNil(exchangeRate, "Valid exchangeRate data was expected but none was received.")
            XCTAssertEqual(exchangeRate?.rate, 1.2, "The received exchange rate does not match the expected value.")
            XCTAssertEqual(exchangeRate?.baseCurrency, "EUR", "The received base currency does not match the expected value.")
            XCTAssertEqual(exchangeRate?.targetCurrency, "USD", "The received target currency does not match the expected value.")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    /// Tests the service's response to an invalid URL by ensuring the callback receives an error.
    func testFetchExchangeRateWithInvalidURL() {
        let sessionFake = URLSessionFake(data: nil, response: nil, error: NSError(domain: "URLSessionError", code: NSURLErrorBadURL, userInfo: nil))
        let serviceWithInvalidURL = ExchangeRateService(apiKey: "fakeKey", baseUrlString: "htp://invalid.url", session: sessionFake)
        
        let expectation = self.expectation(description: "Completion handler called with URL error.")
        
        serviceWithInvalidURL.fetchExchangeRateIfNeeded(fromCurrency: "EUR", toCurrency: "USD") { exchangeRate, error in
            // Then
            XCTAssertNil(exchangeRate, "Expected no exchange rate for an invalid URL.")
            XCTAssertNotNil(error, "Expected an error for an invalid URL.")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    
    /// Evaluates the service's handling of invalid JSON responses by expecting a decoding error in the callback.
    func testFetchExchangeRateWithInvalidJSON() {
        let invalidJSONData = "Invalid JSON".data(using: .utf8)!
        sessionFake.data = invalidJSONData
        
        let expectation = self.expectation(description: "Completion handler called with JSON decoding error.")
        
        service.fetchExchangeRateIfNeeded(fromCurrency: "EUR", toCurrency: "USD") { exchangeRate, error in
            // Then
            XCTAssertNil(exchangeRate, "Expected no exchange rate due to invalid JSON.")
            XCTAssertNotNil(error, "Expected a JSON decoding error.")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    /// Tests correct loading of the last exchange rate saved in UserDefaults.
    func testLoadLastExchangeRate() {
        // Simulate and save an exchange rate in UserDefaults
        let expectedRate = ExchangeRate(baseCurrency: "EUR", targetCurrency: "USD", rate: 1.2, date: Date())
        let encoder = JSONEncoder()
        if let encodedExchangeRate = try? encoder.encode(expectedRate) {
            UserDefaults.standard.set(encodedExchangeRate, forKey: "lastExchangeRate")
        }
        
        // Initialize ExchangeRateService with a mock session (to avoid network calls)
        let service = ExchangeRateService(session: sessionFake)
        
        // Call the loading method and verify the result
        if let loadedExchangeRate = service.loadLastExchangeRate() {
            // Verify that the loaded exchange rate matches the expected data
            XCTAssertEqual(loadedExchangeRate.baseCurrency, expectedRate.baseCurrency, "The loaded base currency does not match the expected base currency.")
            XCTAssertEqual(loadedExchangeRate.targetCurrency, expectedRate.targetCurrency, "The loaded target currency does not match the expected target currency.")
            XCTAssertEqual(loadedExchangeRate.rate, expectedRate.rate, "The loaded exchange rate does not match the expected rate.")
        } else {
            XCTFail("No exchange rate was loaded from UserDefaults.")
        }
        
        // Clean up UserDefaults after the test
        UserDefaults.standard.removeObject(forKey: "lastExchangeRate")
    }
    
    /// Tests that `fetchExchangeRateIfNeeded` uses the cached rate when appropriate.
    func testFetchExchangeRateIfNeededUsesCachedRate() {
        // Simulate saving an exchange rate in UserDefaults
        let cachedRate = ExchangeRate(baseCurrency: "EUR", targetCurrency: "USD", rate: 1.2, date: Date())
        simulateCachedExchangeRate(rate: cachedRate.rate, base: cachedRate.baseCurrency, target: cachedRate.targetCurrency)
        
        // Initialize ExchangeRateService with sessionFake to avoid network calls
        let service = ExchangeRateService(session: sessionFake)
        
        // Define an expectation to wait for the completion handler call
        let expectation = self.expectation(description: "Completion handler called with cached exchange rate.")
        
        // Call `fetchExchangeRateIfNeeded`
        service.fetchExchangeRateIfNeeded(fromCurrency: "EUR", toCurrency: "USD") { exchangeRate, error in
            // Verify that no error is returned
            XCTAssertNil(error)
            // Verify that the returned exchange rate matches the saved rate
            XCTAssertNotNil(exchangeRate)
            XCTAssertEqual(exchangeRate?.rate, cachedRate.rate)
            XCTAssertEqual(exchangeRate?.baseCurrency, cachedRate.baseCurrency)
            XCTAssertEqual(exchangeRate?.targetCurrency, cachedRate.targetCurrency)
            
            expectation.fulfill()
        }
        
        // Wait for the expectation to be fulfilled
        waitForExpectations(timeout: 1.0, handler: nil)
        
        // Clean up UserDefaults after the test
        UserDefaults.standard.removeObject(forKey: "lastExchangeRate")
    }
}
