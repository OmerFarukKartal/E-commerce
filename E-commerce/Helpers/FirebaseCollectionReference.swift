//
//  FirebaseCollectionReference.swift
//  E-commerce
//
//  Created by KARTAL on 7.07.2023.
//

import Foundation
import FirebaseFirestore



enum FCollectionReference: String{
    case user
    case Category
    case Items
    case Basket
    
}


func FirebaseReference(_ collectionReference: FCollectionReference) -> CollectionReference {
    return Firestore.firestore().collection(collectionReference.rawValue)
    
}
