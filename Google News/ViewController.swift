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
    @IBOutlet weak var collectionView: UICollectionView!
    var db: Connection?
    let NewsApiTable = Table("NewsApiTable")
    var articles = [Article]()
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        collectionView.alwaysBounceVertical = true
        collectionView.refreshControl = refreshControl
        
        dbSetup()
        getNews {
            self.reloadCollectionView{
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    fileprivate func dbSetup() {
        do {
            db = try Connection(.inMemory)
            let id = Expression<Int64>("id")
            let source = Expression<String>("source")
            let author = Expression<String?>("author")
            let title = Expression<String>("title")
            let description = Expression<String>("description")
            let url = Expression<String>("url")
            let urlToImage = Expression<String>("urlToImage")
            let publishedAt = Expression<String>("publishedAt")
            let content = Expression<String>("content")
            
            try self.db!.run(NewsApiTable.create { t in
                t.column(id, primaryKey: true)
                t.column(source)
                t.column(author)
                t.column(title)
                t.column(description)
                t.column(url)
                t.column(urlToImage)
                t.column(publishedAt)
                t.column(content)
            })
        } catch {
            print(error)
        }
    }
    
    fileprivate func getNews(completionHandler: @escaping () -> ()) {
        let session = URLSession(configuration: .default)
        let url = NSURL(string: "https://newsapi.org/v2/top-headlines?country=us&apiKey=aa9436a462cb41c7a6b08cb71d1d9ad9")
        var request = URLRequest(url: url! as URL)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request) { data, response, error in
            let newsapiresults = try! JSONDecoder().decode(NewsApi.self, from: data!)
            for article in newsapiresults.articles {
                do {
                    let insert = try self.NewsApiTable.insert(article)
                    _ = try self.db!.run(insert)
                } catch {
                    print(error)
                }
            }
            completionHandler()
        }
        task.resume()
    }
    
    fileprivate func reloadCollectionView(completionHandler: @escaping () -> ()) {
        for article in try! self.db!.prepare("SELECT * FROM NewsApiTable") {
            self.articles.append(Article(source: article[1] as? Source, author: article[2] as? String, title: article[3] as? String, articleDescription: article[4] as? String, url: article[5] as? String, urlToImage: article[6] as? String, publishedAt: article[7] as? String, content: article[8] as? String))
        }
        completionHandler()
    }
    
    @objc
    private func didPullToRefresh(_ sender: Any) {
        _ = try! self.db!.run("DELETE FROM NewsApiTable")
        articles = []
        self.collectionView.reloadData()

        getNews {
                   self.reloadCollectionView{
                       DispatchQueue.main.async {
                           self.collectionView.reloadData()
                       }
                   }
               }
        refreshControl.endRefreshing()
    }

}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let article = articles[indexPath.row]
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArticleCell", for: indexPath) as? ArticleCollectionViewCell {
            
            cell.ImageView.image = UIImage(named: "Image.png")
            cell.lblTitle.text = article.title
            cell.lblContent.text = article.content
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let url = URL(string: articles[indexPath.row].url!) {
            print(url)
            UIApplication.shared.open(url, options: [:])
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.view.frame.width - 10 * 2
        let height: CGFloat = 350
        
        return CGSize(width: width, height: height)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
           
           guard let url = navigationAction.request.url else{
               decisionHandler(.allow)
               return
           }
           
           let urlString = url.absoluteString.lowercased()
           if urlString.starts(with: "http://") || urlString.starts(with: "https://") {
               decisionHandler(.cancel)
               UIApplication.shared.open(url, options: [:])
           } else {
               decisionHandler(.allow)
           }
           
       }
}

