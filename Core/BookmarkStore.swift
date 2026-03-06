//
//  BookmarkStore.swift
//  NewsApp
//
//  Created by Gaurish Bandekar on 05/03/26.
//

import Foundation
import CoreData

protocol BookmarkStoreProtocol {
    
    func isBookmarked(id: String) -> Bool
//    func bookmarked(id: String) -> Bool

    func fetchBookmarks() -> [Article]
    func addBookmark(_ article: Article)
    func removeBookmark(id: String)
}

final class BookmarkStore: BookmarkStoreProtocol {
    
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }

    func isBookmarked(id: String) -> Bool {
        let request: NSFetchRequest<ArticleBookmark> = ArticleBookmark.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        return (try? context.count(for: request)) ?? 0 > 0
    }

    func fetchBookmarks() -> [Article] {
        let request: NSFetchRequest<ArticleBookmark> = ArticleBookmark.fetchRequest()
        
        guard let results = try? context.fetch(request) else { return [] }
        
        return results.compactMap { bookmark in
            Article(
                id: bookmark.id ?? UUID().uuidString,
                title: bookmark.title ?? "",
                description: bookmark.descText ?? "",
                url: URL(string: bookmark.url ?? ""),
                imageURL: URL(string: bookmark.imageURL ?? ""),
                source: bookmark.source ?? "",
                publishedAt: bookmark.publishedAt,
                content: bookmark.content ?? ""
            )
        }
    }

    func addBookmark(_ article: Article) {
        
        guard !isBookmarked(id: article.id) else { return }
        
        let bookmark = ArticleBookmark(context: context)
        bookmark.id = article.id
        bookmark.title = article.title
        bookmark.descText = article.description
        bookmark.url = article.url?.absoluteString
        bookmark.imageURL = article.imageURL?.absoluteString
        bookmark.source = article.source
        bookmark.publishedAt = article.publishedAt
        bookmark.content = article.content
        
        save()
    }

    func removeBookmark(id: String) {
        
        let request: NSFetchRequest<ArticleBookmark> = ArticleBookmark.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        
        if let results = try? context.fetch(request) {
            for obj in results {
                context.delete(obj)
            }
            save()
        }
    }

    private func save() {
        
        if context.hasChanges {
            try? context.save()
        }
    }
}
