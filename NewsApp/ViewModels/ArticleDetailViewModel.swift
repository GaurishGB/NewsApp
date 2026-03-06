//
//  ArticleDetailViewModel.swift
//  NewsApp
//
//  Created by Gaurish Bandekar on 04/03/26.
//

import Foundation

final class ArticleDetailViewModel {
    
    let article: Article
    private let bookmarkStore: BookmarkStoreProtocol

    init(article: Article, store: BookmarkStoreProtocol = BookmarkStore()) {
        self.article = article
        self.bookmarkStore = store
    }

    var isBookmarked: Bool {
        bookmarkStore.isBookmarked(id: article.id)
    }

    func toggleBookmark() {
        if isBookmarked {
            bookmarkStore.removeBookmark(id: article.id)
        } else {
            bookmarkStore.addBookmark(article)
        }
    }
}

