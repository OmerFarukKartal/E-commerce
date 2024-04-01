import UIKit

class ItemTableViewCell: UITableViewCell {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func generateCell(_ item: Item) {
        nameLabel.text = item.name
        descriptionLabel.text = item.description
        
        if let price = item.price {
            priceLabel.text = convertToCurrency(price, showCurrencySymbol: true)
        } else {
            priceLabel.text = "N/A"
        }
        
        if let imageUrl = item.imageLinks.first {
            downloadImages(imageUrls: [imageUrl]) { (images) in
                self.itemImageView.image = images.first as? UIImage
            }
        }
    }
    
    func convertToCurrency(_ number: Double, showCurrencySymbol: Bool = true) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = showCurrencySymbol ? "₺" : "" // ₺ simgesi veya boşluk
        formatter.locale = Locale(identifier: "tr_TR") // Türkçe için Türkiye bölgesini belirliyoruz
        
        return formatter.string(from: NSNumber(value: number)) ?? ""
    }
}
