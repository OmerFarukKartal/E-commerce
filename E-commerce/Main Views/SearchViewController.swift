import UIKit
import NVActivityIndicatorView
import FirebaseFirestore

class SearchViewController: UIViewController {
    
    //MARK: IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchOptionsView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButtonOutlet: UIButton!
    
    //MARK: Vars
    
    var searchResults: [Item] = []
    
    var activityIndicator: NVActivityIndicatorView?
    
    let firestoreDB = Firestore.firestore()
    
    //MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        searchTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.height / 2 - 30, width: 60, height: 60), type: .ballPulse, color: #colorLiteral(red: 0.9998469949, green: 0.4941213727, blue: 0.4734867811, alpha: 1), padding: nil)
    }
    
    //MARK: IBActions
    
    @IBAction func showSearchBarButtonPressed(_ sender: Any) {
        dismissKeyboard()
        showSearchField()
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        performSearch()
    }
    
    //MARK: Helpers
    
    private func performSearch() {
        if let searchText = searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !searchText.isEmpty {
            let descriptionQuery = firestoreDB.collection("Items")
                .whereField("description", isGreaterThanOrEqualTo: searchText)
                .whereField("description", isLessThanOrEqualTo: searchText + "\u{f8ff}")
            
            let nameQuery = firestoreDB.collection("Items")
                .whereField("name", isGreaterThanOrEqualTo: searchText)
                .whereField("name", isLessThanOrEqualTo: searchText + "\u{f8ff}")
            
            var combinedResults: [Item] = []
            
            descriptionQuery.getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error searching items: \(error)")
                    return
                }
                for document in snapshot!.documents {
                    if let data = document.data() as? [String: Any] {
                        let item = Item(data)
                        combinedResults.append(item)
                    }
                }
                nameQuery.getDocuments { (snapshot, error) in
                    if let error = error {
                        print("Error searching items: \(error)")
                        return
                    }
                    for document in snapshot!.documents {
                        if let data = document.data() as? [String: Any] {
                            let item = Item(data)
                            combinedResults.append(item)
                        }
                    }
                    // Remove duplicates from combinedResults if necessary
                    let uniqueResults = Array(Set(combinedResults))
                    self.searchResults = uniqueResults
                    self.tableView.reloadData()
                }
            }
        } else {
            self.searchResults.removeAll()
            self.tableView.reloadData()
        }
        searchButtonOutlet.isEnabled = searchTextField.text != ""
        
        if searchButtonOutlet.isEnabled {
            searchButtonOutlet.backgroundColor = #colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1)
        } else {
            disableSearchButton()
        }
    }
    
    private func emptyTextField() {
        searchTextField.text = ""
    }
    
    private func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let searchText = searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !searchText.isEmpty {
            performSearch()
        } else {
            self.searchResults.removeAll()
            self.tableView.reloadData()
        }
        
        searchButtonOutlet.isEnabled = searchTextField.text != ""
        
        if searchButtonOutlet.isEnabled {
            searchButtonOutlet.backgroundColor = #colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1)
        } else {
            disableSearchButton()
        }
    }
    
    private func disableSearchButton() {
        searchButtonOutlet.isEnabled = false
        searchButtonOutlet.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
    }
    
    private func showSearchField() {
        disableSearchButton()
        emptyTextField()
        animateSearchOptionsIn()
    }
    
    //MARK: Animations
    
    private func animateSearchOptionsIn() {
        UIView.animate(withDuration: 0.5) {
            self.searchOptionsView.isHidden = !self.searchOptionsView.isHidden
        }
    }
    
    //MARK: Activity Indicator
    
    private func showLoadingIndıcator() {
        if activityIndicator != nil {
            self.view.addSubview(activityIndicator!)
            activityIndicator!.startAnimating()
        }
    }
    
    private func hideLoadingIndicator() {
        if activityIndicator != nil {
            activityIndicator!.removeFromSuperview()
            activityIndicator!.stopAnimating()
        }
    }
    
    private func showItemView(withItem: Item) {
        let itemVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "itemView") as! ItemViewController
        itemVC.item = withItem
        self.navigationController?.pushViewController(itemVC, animated: true)
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
        cell.generateCell(searchResults[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showItemView(withItem: searchResults[indexPath.row])
    }
}
