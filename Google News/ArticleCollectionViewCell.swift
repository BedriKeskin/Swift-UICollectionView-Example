//
//  ArticleCollectionViewCell.swift
//  Google News
//
//  Created by Bedri Keskin on 10.02.2022.
//  Copyright © 2022 Bedri Keskin. All rights reserved.
//

import UIKit

@IBDesignable class ArticleCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblContent: UILabel!
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
}
