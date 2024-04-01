import Foundation
import UIKit
import Firebase

class Item: Hashable {
    
    var id: String!
    var categoryId: String!
    var name: String!
    var description: String!
    var price: Double!
    var imageLinks: [String]!
    
    init() {
    }
    
    init(_ dictionary: [String: Any]) {
        id = dictionary[kOBJECTID] as? String
        categoryId = dictionary[kCATEGORYID] as? String
        name = dictionary[kNAME] as? String
        description = dictionary[kDESCRIPTION] as? String
        price = dictionary[kPRICE] as? Double
        imageLinks = dictionary[kIMAGELINKS] as? [String]
    }
    
    // 'id' özelliğini kullanarak hash değerini hesaplayın
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // 'id' özelliğinin eşitliğini kontrol edin
    static func ==(lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id
    }
}



func saveItemToFirestore(_ item: Item) {
    FirebaseReference(.Items).document(item.id).setData(itemDictionaryFrom(item) as! [String: Any])
}

func itemDictionaryFrom(_ item: Item) -> [String: Any] {
    return [
        kOBJECTID: item.id ?? "",
        kCATEGORYID: item.categoryId ?? "",
        kNAME: item.name ?? "",
        kDESCRIPTION: item.description ?? "",
        kPRICE: item.price ?? 0.0,
        kIMAGELINKS: item.imageLinks ?? []
    ]
}

func downloadItemsFromFirebase(_ withCategoryId: String, completion: @escaping (_ itemArray: [Item]) -> Void) {
    var itemArray: [Item] = []
    FirebaseReference(.Items).whereField(kCATEGORYID, isEqualTo: withCategoryId).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else {
            completion(itemArray)
            return
        }
        
        if !snapshot.isEmpty {
            for itemDoc in snapshot.documents {
                if let itemDict = itemDoc.data() as? [String: Any] {
                    let item = Item(itemDict)
                    itemArray.append(item)
                }
            }
        }
        completion(itemArray)
    }
}

func downloadItems(_ withIds: [String], completion: @escaping (_ itemArray: [Item]) -> Void) {
    var count = 0
    var itemArray: [Item] = []
    
    if withIds.count > 0 {
        for itemId in withIds {
            FirebaseReference(.Items).document(itemId).getDocument { (snapshot, error) in
                guard let snapshot = snapshot else {
                    completion(itemArray)
                    return
                }
                
                if snapshot.exists, let itemDict = snapshot.data() as? [String: Any] {
                    let item = Item(itemDict)
                    itemArray.append(item)
                    count += 1
                } else {
                    completion(itemArray)
                }
                
                if count == withIds.count {
                    completion(itemArray)
                }
            }
        }
    } else {
        completion(itemArray)
    }
}
