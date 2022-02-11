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
    var articles = [Article]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let article1 = Article(source: nil, author: "String?", title: "String?1", articleDescription: "String?", url: "String?", urlToImage: "String?", publishedAt: "String?", content: "String?11")
        let article2 = Article(source: nil, author: "String?", title: "String?2", articleDescription: "String?", url: "String?", urlToImage: "String?", publishedAt: "String?", content: "String?22")
        let article3 = Article(source: nil, author: "String?", title: "String?3", articleDescription: "String?", url: "String?", urlToImage: "String?", publishedAt: "String?", content: "String?33")
        let article4 = Article(source: nil, author: "String?", title: "String?4", articleDescription: "String?", url: "String?", urlToImage: "String?", publishedAt: "String?", content: "String?44")
        let article5 = Article(source: nil, author: "String?", title: "String?5", articleDescription: "String?", url: "String?", urlToImage: "String?", publishedAt: "String?", content: "String?55")
        
        articles = [article1, article2, article3, article4, article5]
        
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

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let article = articles[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArticleCell", for: indexPath) as? ArticleCollectionViewCell
        
        //cell.ImageView.image = article.image
        cell!.lblTitle.text = article.title
        cell!.lblContent.text = article.content
        print(article.content as Any)
        return cell!
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.view.frame.width - 16.0 * 2
        let height: CGFloat = 234.0
        
        return CGSize(width: width, height: height)
    }
}
