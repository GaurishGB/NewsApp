//
//  NewsAPIClientTests.swift
//  NewsAppTests
//
//  Created by Gaurish Bandekar on 07/03/26.
//

import XCTest
import Combine
@testable import NewsApp

final class NewsAPIClientTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()

    // Simple URLProtocol mock to intercept requests
    final class URLProtocolMock: URLProtocol {
        
        static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

        override class func canInit(with request: URLRequest) -> Bool { true }
        override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

        override func startLoading() {
            guard let handler = URLProtocolMock.requestHandler else {
                fatalError("Handler is not set.")
            }
            do {
                let (response, data) = try handler(request)
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client?.urlProtocol(self, didLoad: data)
                client?.urlProtocolDidFinishLoading(self)
            } catch {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }

        override func stopLoading() { }
    }

    private func makeClient(with data: Data, statusCode: Int = 200) -> NewsAPIClient {
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        let session = URLSession(configuration: config)

        URLProtocolMock.requestHandler = { request in
            let url = request.url ?? URL(string: "https://example.com")!
            let response = HTTPURLResponse(url: url,
                                           statusCode: statusCode,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, data)
        }

        return NewsAPIClient(urlSession: session)
    }

    func test_fetchTopHeadlines_parsesArticles() {
        
//        let json = """
//        {
//          "status": "ok",
//          "totalResults": 1,
//          "articles": [
//            {
//              "source": { "id": "", "name": "" },
//              "author": "",
//              "title": "",
//              "description": "",
//              "url": "",
//              "urlToImage": "",
//              "publishedAt": "",
//              "content": ""
//            }
//          ]
//        }
//        """.data(using: .utf8)!
        
        let json = """
        {
          "status": "ok",
          "totalResults": 1,
          "articles": [
            {
              "source": { "id": "abc-news", "name": "ABC News" },
              "author": "John Doe",
              "title": "Test headline",
              "description": "Test description",
              "url": "https://example.com/article",
              "urlToImage": "https://example.com/image.jpg",
              "publishedAt": "2020-01-01T10:00:00Z",
              "content": "Full content"
            }
          ]
        }
        """.data(using: .utf8)!

        let client = makeClient(with: json)

        let expectation = self.expectation(description: "Fetch articles")

        var receivedArticles: [Article] = []
        var receivedError: Error?

        client.fetchTopHeadlines(page: 1, query: nil)
            .sink { completion in
                if case let .failure(error) = completion {
                    receivedError = error
                }
                expectation.fulfill()
            } receiveValue: { articles in
                receivedArticles = articles
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)

        XCTAssertNil(receivedError)
        XCTAssertEqual(receivedArticles.count, 1)
        XCTAssertEqual(receivedArticles.first?.title, "Test headline")
        XCTAssertEqual(receivedArticles.first?.source, "ABC News")
    }

    func test_fetchTopHeadlines_handlesServerError() {
        
        let client = makeClient(with: Data(), statusCode: 500)

        let expectation = self.expectation(description: "Server error")

        var receivedError: Error?

        client.fetchTopHeadlines(page: 1, query: nil)
            .sink { completion in
                if case let .failure(error) = completion {
                    receivedError = error
                    expectation.fulfill()
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
        XCTAssertNotNil(receivedError)
    }
}

