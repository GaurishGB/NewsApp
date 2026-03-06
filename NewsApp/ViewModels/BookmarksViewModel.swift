//
//  BookmarksViewModel.swift
//  NewsApp
//
//  Created by Gaurish Bandekar on 04/03/26.
//

import Foundation
import Combine

final class BookmarksViewModel {
    
    @Published private(set) var bookmarks: [Article] = []

    private let store: BookmarkStoreProtocol

    init(store: BookmarkStoreProtocol = BookmarkStore()) {
        self.store = store
        reload()
    }

    func reload() {
        bookmarks = store.fetchBookmarks()
    }

    func remove(at index: Int) {
        let article = bookmarks[index]
        store.removeBookmark(id: article.id)
        bookmarks.remove(at: index)
    }
}

