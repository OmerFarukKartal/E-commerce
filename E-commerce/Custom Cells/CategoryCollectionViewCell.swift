//
//  CategoryCollectionViewCell.swift
//  E-commerce
//
//  Created by KARTAL on 7.07.2023.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    func generateCell(_ category: Category) {
        nameLabel.text = category.name
        imageView.image = category.image
        
    }
    
}
