//
//  ArticleItem.swift
//  Google News
//
//  Created by Bedri Keskin on 10.02.2022.
//  Copyright © 2022 Bedri Keskin. All rights reserved.
//

import UIKit

// MARK: - NewsApi
struct NewsApi: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

// MARK: - Article
struct Article: Codable {
    let source: Source?
    let author: String?
    let title, articleDescription: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?
    
    enum CodingKeys: String, CodingKey {
        case source, author, title
        case articleDescription = "description"
        case url, urlToImage, publishedAt, content
    }
}

// MARK: - Source
struct Source: Codable {
    let id: String?
    let name: String?
}
