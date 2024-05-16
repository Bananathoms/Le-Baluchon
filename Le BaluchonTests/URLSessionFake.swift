// URLSessionFake.swift
// Le Baluchon
//
// Created by Thomas Carlier on 07/04/2024.
//

import Foundation

/// A mock URLSessionDataTask class to simulate network requests.
class URLSessionDataTaskFake: URLSessionDataTask {
    let data: Data?
    let urlResponse: URLResponse?
    let respError: Error?
    
    var completionHandler: ((Data?, URLResponse?, Error?) -> Void)?
    
    /// Initializes a new instance of the mock data task.
    /// - Parameters:
    ///   - data: The mock data to return.
    ///   - urlResponse: The mock URL response.
    ///   - error: The mock error to return.
    ///   - completionHandler: The completion handler to invoke with the mock data, response, and error.
    init(data: Data?, urlResponse: URLResponse?, error: Error?, completionHandler: ((Data?, URLResponse?, Error?) -> Void)?) {
        self.data = data
        self.urlResponse = urlResponse
        self.respError = error
        self.completionHandler = completionHandler
    }
    
    /// Simulates the resumption of the network request by immediately invoking the completion handler with the mock data, response, and error.
    override func resume() {
        completionHandler?(data, urlResponse, respError)
    }
}

/// A mock URLSession class to simulate network requests.
class URLSessionFake: URLSession {
    var data: Data?
    var response: URLResponse?
    var error: Error?

    /// Initializes a new instance of the mock URLSession.
    /// - Parameters:
    ///   - data: The mock data to return for the network request.
    ///   - response: The mock URL response for the network request.
    ///   - error: The mock error to return for the network request.
    init(data: Data?, response: URLResponse?, error: Error?) {
        self.data = data
        self.response = response
        self.error = error
    }
    
    /// Creates a mock data task for the given URL.
    /// - Parameters:
    ///   - url: The URL for the network request.
    ///   - completionHandler: The completion handler to invoke with the mock data, response, and error.
    /// - Returns: A mock URLSessionDataTask instance.
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return URLSessionDataTaskFake(data: data, urlResponse: response, error: error, completionHandler: completionHandler)
    }
    
    /// Creates a mock data task for the given URLRequest.
    /// - Parameters:
    ///   - request: The URLRequest for the network request.
    ///   - completionHandler: The completion handler to invoke with the mock data, response, and error.
    /// - Returns: A mock URLSessionDataTask instance.
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return URLSessionDataTaskFake(data: data, urlResponse: response, error: error, completionHandler: completionHandler)
    }
}
