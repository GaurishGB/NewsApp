//
//  ArticleBookmark.swift
//  NewsApp
//
//  Created by Gaurish Bandekar on 05/03/26.
//

import Foundation
import CoreData

@objc(ArticleBookmark)
public class ArticleBookmark: NSManagedObject {
    
}

extension ArticleBookmark {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ArticleBookmark> {
        return NSFetchRequest<ArticleBookmark>(entityName: "ArticleBookmark")
    }
    
    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var descText: String?
    @NSManaged public var url: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var source: String?
    @NSManaged public var publishedAt: Date?
    @NSManaged public var content: String?
}

