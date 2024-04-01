//
//  Category.swift
//  E-commerce
//
//  Created by KARTAL on 7.07.2023.
//

import Foundation
import UIKit
class Category{
    var id: String
    var name: String
    var image: UIImage?
    var imageName: String?
    
    
    init (_name: String, _imageName: String){
        id = ""
        name = _name
        imageName = _imageName
        image = UIImage(named: _imageName)
    }
    
    init(_dictionary: NSDictionary) {
        id = _dictionary[kOBJECTID] as! String
        name = _dictionary[kNAME] as! String
        image = UIImage(named:  _dictionary[kIMAGENAME] as? String ?? "")
    }
}
//MARK: Download category fireabse
func downloadCategoriesFromFirebase(completion: @escaping (_ categoryArray:[Category]) -> Void) {
    
    var categoryArray : [Category] = []
    FirebaseReference(.Category).getDocuments {( snapshot, error) in
        
        guard let snapshot = snapshot else {
            completion(categoryArray)
            return
        }
        
        if !snapshot.isEmpty{
            
            for categoryDict in snapshot.documents{
                categoryArray.append(Category(_dictionary: categoryDict.data() as NSDictionary))
                
            }
        }
        completion(categoryArray)
    }
}

//MARK: Save category function

func saveCategoryToFirebase(_ category: Category) {
    
    let id = UUID().uuidString
    category.id = id
    
    FirebaseReference(.Category).document(id).setData(categoryDictionaryFrom(category) as! [String : Any])
    
}


//MARK: Helpers
func categoryDictionaryFrom(_ category: Category) -> NSDictionary {
    return NSDictionary(objects: [category.id, category.name, category.imageName!], forKeys: [kOBJECTID as NSCopying, kNAME as NSCopying, kIMAGENAME as NSCopying])
}

