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
    
    /// Tests handling of invalid JSON data to ensure proper error handling.
    func testFetchWeatherInvalidJSON() {
        // Setup fake response with invalid JSON data
        let invalidJSONData = "Invalid JSON".data(using: .utf8)!
        sessionFake.data = invalidJSONData
        sessionFake.response = HTTPURLResponse(url: URL(string: "https://api.openweathermap.org/")!, statusCode: 200, httpVersion: nil, headerFields: nil)

        let expectation = self.expectation(description: "Fetching weather data with invalid JSON fails")

        service.fetchWeather(forCity: "Paris") { weatherResponse, error in
            XCTAssertNil(weatherResponse, "Expected no weatherResponse due to invalid JSON")
            XCTAssertNotNil(error, "Expected an error due to invalid JSON")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    /// Tests the handling of an unexpected status code to ensure proper error handling.
    func testFetchWeatherUnexpectedStatusCode() {
        // Setup fake response with a 404 status code
        let notFoundJSON = "{\"message\":\"city not found\"}".data(using: .utf8)!
        sessionFake.data = notFoundJSON
        sessionFake.response = HTTPURLResponse(url: URL(string: "https://api.openweathermap.org/")!, statusCode: 404, httpVersion: nil, headerFields: nil)

        let expectation = self.expectation(description: "Fetching weather data with unexpected status code fails")

        service.fetchWeather(forCity: "Atlantis") { weatherResponse, error in
            XCTAssertNil(weatherResponse, "Expected no weatherResponse due to 404 status code")
            XCTAssertNotNil(error, "Expected an error due to 404 status code")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    /// Tests that completion handler is called on the main thread if necessary.
    func testFetchWeatherCompletionCalledOnMainThread() {
        let jsonData = """
        {
            "weather": [{"id": 800, "main": "Clear", "description": "clear sky", "icon": "01d"}],
            "main": {"temp": 22.0, "feels_like": 21.0, "temp_min": 20.0, "temp_max": 23.0, "pressure": 1012, "humidity": 60},
            "name": "Paris"
        }
        """.data(using: .utf8)!
        sessionFake.data = jsonData
        sessionFake.response = HTTPURLResponse(url: URL(string: "https://api.openweathermap.org/")!, statusCode: 200, httpVersion: nil, headerFields: nil)

        let expectation = self.expectation(description: "Completion handler called on main thread")

        service.fetchWeather(forCity: "Paris") { _, _ in
            XCTAssertTrue(Thread.isMainThread, "Completion handler should be called on main thread")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    /// Tests that an invalid URL results in the correct error being returned.
    func testFetchWeatherWithInvalidURL() {
        // Configurez le mock URLSession pour simuler une condition d'URL invalide
        // Dans ce cas, nous simulons simplement une réponse avec une erreur spécifique
        let expectedErrorCode = 1
        let error = NSError(domain: "WeatherService", code: expectedErrorCode, userInfo: nil)
        sessionFake.error = error

        let expectation = self.expectation(description: "Completion handler called with URL error.")

        // Testez la méthode fetchWeather avec une URL connue pour être invalide
        service.fetchWeather(forCity: "InvalidCity") { weatherResponse, error in
            XCTAssertNil(weatherResponse, "Expected no weatherResponse for an invalid URL.")
            XCTAssertNotNil(error, "Expected an error for an invalid URL.")
            if let error = error as NSError? {
                XCTAssertEqual(error.code, expectedErrorCode, "Error code does not match expected value.")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    /// Tests the handling of a network response that returns no data.
    func testFetchWeatherNoDataReceived() {
        sessionFake.data = nil
        sessionFake.response = HTTPURLResponse(url: URL(string: "https://api.openweathermap.org/")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        sessionFake.error = nil

        let expectation = self.expectation(description: "Completion handler called with no data error.")

        service.fetchWeather(forCity: "Paris") { weatherResponse, error in
            XCTAssertNil(weatherResponse, "Expected no weatherResponse due to no data received.")
            XCTAssertNotNil(error, "Expected an error due to no data received.")
            if let error = error as NSError? {
                XCTAssertEqual(error.domain, "WeatherService")
                XCTAssertEqual(error.code, 2, "Expected 'No data received' error code.")
                XCTAssertEqual(error.userInfo[NSLocalizedDescriptionKey] as? String, "No data received")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    /// Tests the `fetchIcon` method to ensure it properly downloads and sets the image for the given icon code.
    func testFetchIcon() {
        let imageView = UIImageView()

        let imageData = UIImage(systemName: "sun.max")!.pngData()
        sessionFake.data = imageData
        sessionFake.response = HTTPURLResponse(url: URL(string: "https://openweathermap.org/")!, statusCode: 200, httpVersion: nil, headerFields: nil)

        service.fetchIcon(for: "01d", imageView: imageView)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertNotNil(imageView.image, "Expected image to be set")
            XCTAssertEqual(imageView.image, UIImage(data: imageData!), "Image does not match expected image")
        }
    }
}
