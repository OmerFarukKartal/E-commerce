//
//  ImageCollectionViewCell.swift
//  E-commerce
//
//  Created by KARTAL on 20.07.2023.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    func setupImageWith(itemImage: UIImage) {
        
        imageView.image = itemImage
    }
}
