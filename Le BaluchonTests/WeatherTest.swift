//
//  WeatherTest.swift
//  Le BaluchonTests
//
//  Created by Thomas Carlier on 07/04/2024.
//

import XCTest
@testable import Le_Baluchon

/// Tests for `WeatherService` to ensure it properly fetches weather data from the API.
class WeatherServiceTests: XCTestCase {
    // Service under test and a fake URLSession for mocking network responses
    var service: WeatherService!
    var sessionFake: URLSessionFake!
    
    /// Prepares the test environment before each test runs. Sets up a `WeatherService` instance with a fake URLSession.
    override func setUp() {
        super.setUp()
        // Initialize URLSessionFake with no predefined data, response, or error.
        sessionFake = URLSessionFake(data: nil, response: nil, error: nil)
        // Initialize WeatherService with the fake URLSession to intercept network calls.
        service = WeatherService(session: sessionFake)
    }
    
    /// Cleans up and resets the test environment after each test.
    override func tearDown() {
        // Clear the service and the fake URLSession to avoid test interference.
        service = nil
        sessionFake = nil
        super.tearDown()
    }
    
    /// Tests that `WeatherService.fetchWeather` successfully returns weather data when the network call succeeds.
    func testFetchWeatherSuccess() {
        // Set up URLSessionFake to return a successful response with fake weather data.
        let jsonData = """
        {
            "weather": [{"id": 800, "main": "Clear", "description": "clear sky", "icon": "01d"}],
            "main": {"temp": 22.0, "feels_like": 21.0, "temp_min": 20.0, "temp_max": 23.0, "pressure": 1012, "humidity": 60},
            "name": "Paris"
        }
        """.data(using: .utf8)!
        sessionFake.data = jsonData
        sessionFake.response = HTTPURLResponse(url: URL(string: "https://api.openweathermap.org/")!, statusCode: 200, httpVersion: nil, headerFields: nil)

        // Expectation to wait for the fetch to complete
        let expectation = self.expectation(description: "Fetching weather data succeeds")

        // Call fetchWeather and verify the response matches expected values
        service.fetchWeather(forCity: "Paris") { weatherResponse, error in
            XCTAssertNotNil(weatherResponse, "Expected valid weatherResponse")
            XCTAssertEqual(weatherResponse?.name, "Paris", "Weather data did not match expected values")
            XCTAssertNil(error, "Expected no error")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
    
    /// Tests that `WeatherService.fetchWeather` properly handles failures and returns an error.
    func testFetchWeatherFailure() {
        // Configure URLSessionFake to simulate a network error
        sessionFake.error = NSError(domain: "WeatherServiceTest", code: -1, userInfo: nil)

        // Expectation to wait for the fetch to fail
        let expectation = self.expectation(description: "Fetching weather data fails")

        // Call fetchWeather and verify it correctly handles errors
        service.fetchWeather(forCity: "Nowhere") { weatherResponse, error in
            XCTAssertNil(weatherResponse, "Expected no weatherResponse")
            XCTAssertNotNil(error, "Expected an error")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
}
