// ExchangeRateTest.swift
// Le BaluchonTests
//
// Created by Thomas Carlier on 07/04/2024.
//

import XCTest
@testable import Le_Baluchon

/// Tests for the ExchangeRateService class.
class ExchangeRateServiceTests: XCTestCase {
    var service: ExchangeRateService!
    var sessionFake: URLSessionFake!
    
    /// Set up the test environment before each test.
    /// Initializes `ExchangeRateService` with a fake URLSession to simulate network responses.
    override func setUp() {
        super.setUp()
        // Initialize URLSessionFake with no data, response, or error to start a clean state
        sessionFake = URLSessionFake(data: nil, response: nil, error: nil)
        // Initialize ExchangeRateService with the fake URLSession
        service = ExchangeRateService(session: sessionFake)
    }
    
    /// Test the behavior of `fetchExchangeRateIfNeeded` when an error occurs during the network call.
    /// This test expects the completion handler to be called with an error.
    func testFetchExchangeRateShouldPostFailedCallbackIfError() {
        // Configure URLSessionFake to simulate an error response
        sessionFake.error = NSError(domain: "test", code: 0, userInfo: nil)

        let expectation = self.expectation(description: "Waiting for network call")

        service.fetchExchangeRateIfNeeded(fromCurrency: "EUR", toCurrency: "USD") { exchangeRate, error in
            // Expect an error to be returned and no exchangeRate
            XCTAssertNotNil(error, "Expected an error but did not receive one.")
            XCTAssertNil(exchangeRate, "Expected no exchangeRate but received some.")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
    
    /// Test the behavior of `fetchExchangeRateIfNeeded` when the network call is successful and returns correct data.
    /// This test expects the completion handler to be called with a valid `ExchangeRate` object.
    func testFetchExchangeRateShouldPostSuccessCallbackIfNoErrorAndCorrectData() {
        // Configure URLSessionFake with valid fake data
        let correctData = """
        {
            "rates": {"USD": 1.2},
            "base": "EUR",
            "date": "2024-04-07"
        }
        """.data(using: .utf8)!
        sessionFake.data = correctData
        sessionFake.response = HTTPURLResponse(url: URL(string: "http://data.fixer.io/api/")!,
                                                statusCode: 200,
                                                httpVersion: nil,
                                                headerFields: nil)

        let expectation = self.expectation(description: "Waiting for network call")

        service.fetchExchangeRateIfNeeded(fromCurrency: "EUR", toCurrency: "USD") { exchangeRate, error in
            // Expect no error and valid exchangeRate data
            XCTAssertNil(error, "Expected no error but received one.")
            XCTAssertNotNil(exchangeRate, "Expected valid exchangeRate but did not receive one.")
            XCTAssertEqual(exchangeRate?.rate, 1.2, "Exchange rate does not match expected value.")
            XCTAssertEqual(exchangeRate?.baseCurrency, "EUR", "Base currency does not match expected value.")
            XCTAssertEqual(exchangeRate?.targetCurrency, "USD", "Target currency does not match expected value.")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
    
    /// Tear down the test environment after each test.
    /// Resets the service and sessionFake to nil to ensure a clean state for the next test.
    override func tearDown() {
        service = nil
        sessionFake = nil
        super.tearDown()
    }
}
