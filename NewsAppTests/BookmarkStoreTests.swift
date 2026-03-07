//
//  BookmarkStoreTests.swift
//  NewsAppTests
//
//  Created by Gaurish Bandekar on 07/03/26.
//

import XCTest
import CoreData
@testable import NewsApp

final class BookmarkStoreTests: XCTestCase {

    private func makeInMemoryStore() -> BookmarkStore {
        
        let container = NSPersistentContainer(name: "NewsApp")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        let context = container.viewContext
        return BookmarkStore(context: context)
    }

    func test_addBookmark_persistsArticle() {
        
        let store = makeInMemoryStore()
        let article = Article(
            id: "1",
            title: "Bookmark me",
            description: "Desc",
            url: URL(string: "https://example.com"),
            imageURL: nil,
            source: "X",
            publishedAt: Date(),
            content: "Content"
        )

        XCTAssertFalse(store.isBookmarked(id: "1"))
        store.addBookmark(article)
        XCTAssertTrue(store.isBookmarked(id: "1"))

        let bookmarks = store.fetchBookmarks()
        XCTAssertEqual(bookmarks.count, 1)
        XCTAssertEqual(bookmarks.first?.title, "Bookmark me")
    }

    func test_removeBookmark_deletesArticle() {
        
        let store = makeInMemoryStore()
        let article = Article(
            id: "1",
            title: "Delete me",
            description: "",
            url: nil,
            imageURL: nil,
            source: "X",
            publishedAt: nil,
            content: ""
        )

        store.addBookmark(article)
        XCTAssertTrue(store.isBookmarked(id: "1"))

        store.removeBookmark(id: "1")
        XCTAssertFalse(store.isBookmarked(id: "1"))
        XCTAssertEqual(store.fetchBookmarks().count, 0)
    }
}

