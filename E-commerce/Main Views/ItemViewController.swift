import UIKit
import JGProgressHUD

class ItemViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    //MARK: - Vars
    var item: Item!
    var itemImages: [UIImage] = []
    let hud = JGProgressHUD(style: .dark)
    //MARK: - Constants
    let cellHeight: CGFloat = 200.0 // UICollectionViewCell yüksekliğini burada belirleyin
    //MARK - ViewLifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        downloadPictures()
        //        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "back"), style: .plain , target: self, action: #selector(self.backAction))]
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "addToBasket"), style: .plain , target: self, action: #selector(self.addToBasketButtonPressed))]
    }
    //MARK: Download Pictures
    private func downloadPictures() {
        if let itemImagesUrls = item?.imageLinks, !itemImagesUrls.isEmpty {
            downloadImages(imageUrls: itemImagesUrls) { (allImages) in
                self.itemImages = allImages as? [UIImage] ?? []
                self.imageCollectionView.reloadData()
            }
        }
    }
    //MARK:  Setup UI
    private func setupUI() {
        if let item = item {
            self.title = item.name
            nameLabel.text = item.name
            priceLabel.text = convertToCurrency(item.price)
            descriptionTextView.text = item.description
        }
    }
    //MARK: IBActions
    //    @objc func backAction () {
    //        self.navigationController?.popViewController(animated: true)}
    @objc func addToBasketButtonPressed () {
        if MUser.currentUser() != nil {
            downloadBasketFromFirestore(MUser.currentID()) { (basket) in
                if basket == nil {
                    self.createNewBasket()
                } else {
                    basket!.itemIds.append(self.item.id)
                    self.updateBasket(basket: basket!, withValues: [kITEMIDS : basket!.itemIds])
                }
            }
        }else{
            showLoginView()
        }
    }
    // MARK: Add to basket
    private func createNewBasket() {
        let newBasket = Basket()
        newBasket.id = UUID().uuidString
        newBasket.ownerId = MUser.currentID()
        newBasket.itemIds = [self.item.id]
        saveBasketToFirestore(newBasket)
        self.hud.textLabel.text = "Added to basket!"
        self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        self.hud.show(in: self.view)
        self.hud.dismiss(afterDelay: 2.0)
    }
    private func updateBasket (basket: Basket, withValues: [String : Any]) {
        updateBasketInFirestore(basket, withValues: withValues) { (error) in
            if error != nil {
                self.hud.textLabel.text = "Error: \(error!.localizedDescription)"
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
                print("error updating basket", error!.localizedDescription)
            } else {
                self.hud.textLabel.text = "Added to basket!"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            }
        }
    }
    //MARK: Show Login view
    private func showLoginView(){
        let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
        self.present(loginView, animated: true, completion: nil)
    }
}
extension ItemViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemImages.isEmpty ? 1 : itemImages.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageCollectionViewCell
        if itemImages.count > 0 {
            cell.setupImageWith(itemImage: itemImages[indexPath.row])
        }
        return cell
    }
}
extension ItemViewController: UICollectionViewDelegateFlowLayout {
    // Define the sectionInsets variable here with the desired values
    private var sectionInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - (sectionInsets.left + sectionInsets.right)
        return CGSize(width: availableWidth, height: cellHeight)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
extension ItemViewController {
    // Rest of the code for your class...
    func convertToCurrency(_ number: Double, showCurrencySymbol: Bool = true) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = showCurrencySymbol ? "₺" : "" // ₺ simgesi veya boşluk
        formatter.locale = Locale(identifier: "tr_TR") // Türkçe bölgesini belirliyoruz
        return formatter.string(from: NSNumber(value: number)) ?? ""
    }
}
