//
//  NewsEndpoint.swift
//  NewsApp
//
//  Created by Gaurish Bandekar on 05/03/26.
//

import Foundation

enum NewsEndpoint {
    
    case topHeadlines(page: Int, query: String?)

    var urlRequest: URLRequest {
        switch self {
        case .topHeadlines(let page, let query):
            // Format: /top-headlines/category/{category}/{country}.json?page={page}
            let category = "general"  // or "business", "health", "sports", etc.
            var path = "top-headlines/category/\(category)/\(NewsAPIConfig.country).json"
            
            if let q = query, !q.isEmpty {
                path = "everything/\(q.lowercased()).json"  // fallback to everything search
            }
            
            var components = URLComponents(url: NewsAPIConfig.baseURL.appendingPathComponent(path),
                                           resolvingAgainstBaseURL: false)!
            components.queryItems = [.init(name: "page", value: String(page))]
            
            return URLRequest(url: components.url!)
        }
    }

}

