//
//  ViewController.swift
//  Google News
//
//  Created by Bedri Keskin on 9.02.2022.
//  Copyright © 2022 Bedri Keskin. All rights reserved.
//

import UIKit
import Foundation
import SQLite

class ViewController: UIViewController {
    var db: Connection?
    let NewsApiTable = Table("NewsApiTable")
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dbSetup()
        ViewController.getNews { articles in
            for article in articles {
                do {
                    let insert = try self.NewsApiTable.insert(article)
                    let rowid = try self.db!.run(insert)
                    print(rowid)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    fileprivate func dbSetup() {
           do {
               db = try Connection(.inMemory)
               let id = Expression<Int64>("id")
               let author = Expression<String?>("author")
               let title = Expression<String>("title")
               let description = Expression<String>("description")
               let url = Expression<String>("url")
               let urlToImage = Expression<String>("urlToImage")
               let publishedAt = Expression<String>("publishedAt")
               let content = Expression<String>("content")
               let source = Expression<String>("source")
               
               try self.db!.run(NewsApiTable.create { t in
                   t.column(id, primaryKey: true)
                   t.column(author)
                   t.column(title)
                   t.column(description)
                   t.column(url)
                   t.column(urlToImage)
                   t.column(publishedAt)
                   t.column(content)
                   t.column(source)
               })
           } catch {
               print(error)
           }
       }
    
    class func getNews(completionHandler: @escaping (_ genres: [Article]) -> ()) {
        let session = URLSession(configuration: .default)
        let url = NSURL(string: "https://newsapi.org/v2/top-headlines?country=us&apiKey=aa9436a462cb41c7a6b08cb71d1d9ad9")
        var request = URLRequest(url: url! as URL)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request) { data, response, error in
            let newsapiresults = try! JSONDecoder().decode(NewsApi.self, from: data!)
            var articles:[Article]=[]
            for article in newsapiresults.articles {
                let anarticle:Article = Article(source: article.source, author: article.author, title: article.title, articleDescription: article.articleDescription, url: article.url, urlToImage: article.urlToImage, publishedAt: article.publishedAt, content: article.content)
                articles.append(anarticle)
            }
            completionHandler(articles)
        }
        task.resume()
    }
}

