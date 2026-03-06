//
//  FeedViewModel.swift
//  NewsApp
//
//  Created by Gaurish Bandekar on 04/03/26.
//

import Foundation
import Combine

enum FeedState {
    case idle
    case loading
    case loaded
    case error(String)
    case empty
}

final class FeedViewModel {
    
    @Published var searchQuery: String = ""

    @Published private(set) var articles: [Article] = []
    @Published private(set) var state: FeedState = .idle
    @Published private(set) var isLoadingNextPage: Bool = false

    private let apiClient: NewsAPIClientProtocol
    private var cancellables = Set<AnyCancellable>()

    private var currentPage: Int = 1
    private var canLoadMore: Bool = true
    private var currentQuery: String?

    init(apiClient: NewsAPIClientProtocol = NewsAPIClient()) {
        self.apiClient = apiClient
        bindSearch()
        loadInitial()
    }

    func loadInitial() {
        currentPage = 1
        canLoadMore = true
        articles = []
        fetch(page: currentPage, query: currentQuery, reset: true)
    }
    
    
    func loadNextPageIfNeeded(currentIndex: Int) {

        if isLoadingNextPage { return }

        if !canLoadMore { return }

        let thresholdIndex = articles.count - 5

        if currentIndex >= thresholdIndex {
            currentPage += 1
            fetch(page: currentPage, query: currentQuery, reset: false)
        }
    }

    private func bindSearch() {
        
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self else { return }
                self.currentQuery = query.isEmpty ? nil : query
                self.loadInitial()
            }
            .store(in: &cancellables)
    }

    private func fetch(page: Int, query: String?, reset: Bool) {
        
        if reset {
            state = .loading
        } else {
            isLoadingNextPage = true
        }

        apiClient.fetchTopHeadlines(page: page, query: query)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoadingNextPage = false
                switch completion {
                case .failure(let error):
                    if self.articles.isEmpty {
                        self.state = .error(error.localizedDescription)
                    }
                    self.canLoadMore = false
                case .finished:
                    break
                }
            } receiveValue: { [weak self] newArticles in
                guard let self = self else { return }
                if reset {
                    self.articles = newArticles
                } else {
                    self.articles.append(contentsOf: newArticles)
                }
                self.canLoadMore = !newArticles.isEmpty
                if self.articles.isEmpty {
                    self.state = .empty
                } else {
                    self.state = .loaded
                }
            }
            .store(in: &cancellables)
    }
}

