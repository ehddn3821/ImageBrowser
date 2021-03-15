//
//  SearchCollectionViewCell.swift
//  ImageBrowser
//
//  Created by dwKang on 2021/03/15.
//

import UIKit

class SearchCollectionViewCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let screenWidth = UIScreen.main.bounds.width
        let imageWidth = (screenWidth - 44) / 3
        
        let searchImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageWidth, height: imageWidth))
        searchImageView.image = UIImage(named: "image")
        
        self.contentView.addSubview(searchImageView)
    }

}
