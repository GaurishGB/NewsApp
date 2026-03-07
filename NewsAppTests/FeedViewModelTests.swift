//
//  FeedViewModelTests.swift
//  NewsAppTests
//
//  Created by Gaurish Bandekar on 07/03/26.
//

import XCTest
import Combine
@testable import NewsApp

final class FeedViewModelTests: XCTestCase {

    final class MockClient: NewsAPIClientProtocol {
        
        var pages: [[Article]] = []
        var lastQuery: String?

        func fetchTopHeadlines(page: Int, query: String?) -> AnyPublisher<[Article], Error> {
            lastQuery = query
            let index = max(0, min(page - 1, pages.count - 1))
            let result = pages.isEmpty ? [] : pages[index]
            return Just(result)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }

    private var cancellables = Set<AnyCancellable>()

    func test_initialLoad_setsArticlesAndLoadedState() {
        
        let mock = MockClient()
        mock.pages = [[
            Article(id: "1", title: "A", description: "", url: nil, imageURL: nil, source: "X", publishedAt: nil, content: "")
        ]]

        let vm = FeedViewModel(apiClient: mock)

        let expectation = self.expectation(description: "Loaded")
        vm.$state
            .dropFirst()
            .sink { state in
                if case .loaded = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 1)

        XCTAssertEqual(vm.articles.count, 1)
        XCTAssertEqual(vm.articles.first?.title, "A")
    }

    func test_searchQueryTriggersReload() {
        
        let mock = MockClient()
        mock.pages = [[
            Article(id: "1", title: "Search result", description: "", url: nil, imageURL: nil, source: "X", publishedAt: nil, content: "")
        ]]

        let vm = FeedViewModel(apiClient: mock)

        let expectation = self.expectation(description: "Search reload")

        vm.$articles
            .dropFirst(2) // after initial + after search reload
            .sink { articles in
                if articles.first?.title == "Search result" {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        vm.searchQuery = "apple"

        waitForExpectations(timeout: 2)
        XCTAssertEqual(mock.lastQuery, "apple")
    }

    func test_loadNextPage_appendsArticles() {
        
        let mock = MockClient()
        mock.pages = [
            [Article(id: "1", title: "Page1", description: "", url: nil, imageURL: nil, source: "X", publishedAt: nil, content: "")],
            [Article(id: "2", title: "Page2", description: "", url: nil, imageURL: nil, source: "X", publishedAt: nil, content: "")]
        ]

        let vm = FeedViewModel(apiClient: mock)

        let expectation = self.expectation(description: "Pagination")

        vm.$articles
            .dropFirst(2) // after page 1 and page 2
            .sink { articles in
                if articles.count == 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        vm.loadNextPageIfNeeded(currentIndex: 0)

        waitForExpectations(timeout: 1)

        XCTAssertEqual(vm.articles.map(\.title), ["Page1", "Page2"])
    }
}

