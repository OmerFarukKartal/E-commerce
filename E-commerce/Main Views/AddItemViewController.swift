import UIKit
import FirebaseStorage
import JGProgressHUD
import NVActivityIndicatorView
import YPImagePicker
class AddItemViewController: UIViewController, UINavigationControllerDelegate {
    //MARK: IBOutlets    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    //MARK: Vars
    var category: Category!
    var itemImages: [UIImage?] = []
    var imageLinks: [String] = []
    var activityIndicator: NVActivityIndicatorView?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationController?.delegate = self
    }
    //MARK: IBActions
    @IBAction func doneBarButtonItemPressed(_ sender: Any) {
        dismissKeyboard()
        if fieldsAreCompleted() {
            saveToFirebase()
        } else {
            showErrorAlert(message: "All fields are required")
        }
    }
    @IBAction func cameraButtonPressed(_ sender: Any) {
        showImagePicker()
    }
    @IBAction func backgroundTapped(_ sender: Any) {
        dismissKeyboard()
    }
    //MARK: Helper Functions
    private func fieldsAreCompleted() -> Bool {
        return (nameTextField.text != "" && priceTextField.text != "" && descriptionTextView.text != "")
    }
    private func dismissKeyboard() {
        self.view.endEditing(false)
    }
    private func popTheView() {
        self.navigationController?.popViewController(animated: true)
    }
    private func showImagePicker() {
        var config = YPImagePickerConfiguration()
        config.showsPhotoFilters = false
        config.library.maxNumberOfItems = 10 // Maksimum seçilebilecek fotoğraf sayısı
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, _ in
            for item in items {
                switch item {
                case .photo(let photo):
                    self.itemImages.append(photo.image)
                default:
                    break
                }
            }
            self.dismiss(animated: true, completion: nil) // Fotoğraf yükleme ekranını kapat, AddItemViewController sayfasında kal
        }
        present(picker, animated: true, completion: nil)
    }
    //MARK: Save Item
    private func saveToFirebase() {
        let item = Item()
        item.id = UUID().uuidString
        item.name = nameTextField.text!
        item.categoryId = category.id
        item.description = descriptionTextView.text
        item.price = Double(priceTextField.text!)
        showLoadingIndicator() // Show the loading indicator before starting the upload process
        if itemImages.count > 0 {
            uploadImages(images: itemImages, itemId: item.id) { (imageLinkArray) in
                item.imageLinks = imageLinkArray
                // The upload is completed, hide the loading indicator
                self.hideLoadingIndicator()
                saveItemToFirestore(item)
                self.popTheView()
            }
        } else {
            // The upload is completed, hide the loading indicator
            self.hideLoadingIndicator()
            saveItemToFirestore(item)
            popTheView()
        }
    }
    private func saveImageToFirebase(_ image: UIImage?, completion: @escaping (String?) -> Void) {
        guard let image = image,
              let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(nil)
            return
        }
        let imageFileName = UUID().uuidString // Rastgele bir dosya adı oluşturuyoruz
        let storageRef = Storage.storage().reference().child("itemImages").child(imageFileName)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let uploadTask = storageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            // Yüklenen fotoğrafın URL'sini alıyoruz
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error retrieving download URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                if let downloadURL = url?.absoluteString {
                    completion(downloadURL)
                } else {
                    completion(nil)
                }
            }
        }
        // Görsel yükleme işlemini başlatıyoruz
        uploadTask.resume()
    }
    //MARK: Activity Indicator
    private func showLoadingIndicator() {
        if activityIndicator == nil {
            let indicatorSize: CGFloat = 60
            let indicatorFrame = CGRect(x: (view.bounds.width - indicatorSize) / 2,
                                        y: (view.bounds.height - indicatorSize) / 2,
                                        width: indicatorSize,
                                        height: indicatorSize)
            activityIndicator = NVActivityIndicatorView(frame: indicatorFrame, type: .ballSpinFadeLoader, color: .blue, padding: nil)
            view.addSubview(activityIndicator!)
        }
        activityIndicator?.startAnimating()
    }
    private func hideLoadingIndicator() {
        activityIndicator?.stopAnimating()
        activityIndicator?.removeFromSuperview()
        activityIndicator = nil
    }
    //MARK: UINavigationControllerDelegate
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is AddItemViewController {
        } else if viewController is ItemsTableViewController {
            navigationController.navigationBar.isHidden = true
            navigationController.navigationBar.isHidden = false
        }
    }
    //MARK: Show Error Alert
        private func showErrorAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
