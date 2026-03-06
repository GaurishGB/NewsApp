//
//  Article.swift
//  NewsApp
//
//  Created by Gaurish Bandekar on 04/03/26.
//

import Foundation

struct NewsAPIResponse: Decodable {
    let status: String
    let totalResults: Int
    let articles: [ArticleDTO]
}

struct ArticleDTO: Decodable {
    let source: SourceDTO?
    let author: String?
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?
}

struct SourceDTO: Decodable {
    let id: String?
    let name: String?
}

struct Article: Hashable {
    let id: String
    let title: String
    let description: String
    let url: URL?
    let imageURL: URL?
    let source: String
    let publishedAt: Date?
    let content: String

    init(from dto: ArticleDTO) {
        let urlString = dto.url ?? UUID().uuidString
        self.id = urlString
        self.title = dto.title ?? "No title"
        self.description = dto.description ?? ""
        self.url = URL(string: dto.url ?? "")
        self.imageURL = URL(string: dto.urlToImage ?? "")
        self.source = dto.source?.name ?? "Unknown"
        self.publishedAt = ISO8601DateFormatter().date(from: dto.publishedAt ?? "")
        self.content = dto.content ?? ""
    }

    init(
        id: String,
        title: String,
        description: String,
        url: URL?,
        imageURL: URL?,
        source: String,
        publishedAt: Date?,
        content: String
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.url = url
        self.imageURL = imageURL
        self.source = source
        self.publishedAt = publishedAt
        self.content = content
    }
}

