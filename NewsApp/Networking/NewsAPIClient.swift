//
//  NewsAPIClient.swift
//  NewsApp
//
//  Created by Gaurish Bandekar on 05/03/26.
//

import Foundation
import Combine

protocol NewsAPIClientProtocol {
    func fetchTopHeadlines(page: Int, query: String?) -> AnyPublisher<[Article], Error>
}

final class NewsAPIClient: NewsAPIClientProtocol {
    private let urlSession: URLSession

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func fetchTopHeadlines(page: Int, query: String?) -> AnyPublisher<[Article], Error> {
        let request = NewsEndpoint.topHeadlines(page: page, query: query).urlRequest

        return urlSession.dataTaskPublisher(for: request)
            .tryMap { output -> Data in
                guard let response = output.response as? HTTPURLResponse,
                      200..<300 ~= response.statusCode else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: NewsAPIResponse.self, decoder: JSONDecoder())
            .map { $0.articles.map(Article.init(from:)) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

