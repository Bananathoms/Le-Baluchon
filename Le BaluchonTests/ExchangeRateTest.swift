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
    
    /// Tests the `convert` method of the `ExchangeRate` model to ensure it accurately converts an amount from the base currency to the target currency using the specified exchange rate.
    func testConvert() {
        // Given: Setup the initial conditions with a specific exchange rate between EUR (base currency) and USD (target currency).
        let baseCurrency = "EUR"
        let targetCurrency = "USD"
        let rate: Double = 1.2
        let exchangeRate = ExchangeRate(baseCurrency: baseCurrency, targetCurrency: targetCurrency, rate: rate, date: Date())

        // The amount in the base currency (EUR) that we want to convert to the target currency (USD).
        let amountToConvert: Double = 100

        // When: Perform the conversion using the exchange rate's convert method.
        let convertedAmount = exchangeRate.convert(amount: amountToConvert)

        // Then: Check if the converted amount matches the expected amount.
        let expectedAmount = amountToConvert * rate
        XCTAssertEqual(convertedAmount, expectedAmount, "The converted amount should match the expected amount.")
    }
}
