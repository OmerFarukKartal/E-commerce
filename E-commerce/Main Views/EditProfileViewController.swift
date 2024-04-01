//
//  EditProfileViewController.swift
//  E-commerce
//
//  Created by KARTAL on 1.08.2023.
//
import UIKit
import JGProgressHUD
class EditProfileViewController: UIViewController {
    //MARK: IBOutlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    //MARK: Vars
    let hud = JGProgressHUD(style: .dark)
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    //MARK: IBAction
    @IBAction func saveBarButtonPressed(_ sender: Any) {
        dismissKeyboard()
        if textFieldHaveText() {
            let withValues = [kFIRSTNAME : nameTextField.text!, kLASTNAME : surnameTextField.text!, kFULLNAME : (nameTextField.text! + " " + surnameTextField.text!), kFULLADDRESS : addressTextField.text!]
            updateCurrentUserInFirestore(withValues: withValues) { (error) in
                if error == nil {
                    self.hud.textLabel.text = "Update!"
                    self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                    self.hud.show(in: self.view)
                    self.hud.dismiss(afterDelay: 2.0)
                }else{
                    print("Error updating user", error?.localizedDescription)
                    self.hud.textLabel.text = error?.localizedDescription
                    self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.hud.show(in: self.view)
                    self.hud.dismiss(afterDelay: 2.0)
                }
            }
        }else{
            hud.textLabel.text = "All fields are required!"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0)
        }
    }
    @IBAction func logOutButtonPressed(_ sender: Any) {
        logOutUser()
    }
    //MARK: UpdateUI
    private func loadUserInfo(){
        if MUser.currentUser() != nil {
            let currenUser = MUser.currentUser()!
            nameTextField.text = currenUser.firstName
            surnameTextField.text = currenUser.lastName
            addressTextField.text = currenUser.fullAddress
        }
    }
    //MARK: Helper Func
    private func dismissKeyboard() {
        self.view.endEditing(false)
    }
    private func textFieldHaveText() -> Bool {
        return (nameTextField.text != "" && surnameTextField.text != "" && addressTextField.text != "")
    }
    private func logOutUser() {
        MUser.logOutCurrentUser { (error) in
            if error == nil {
                print("Logged Out")
                self.navigationController?.popViewController(animated: true)
            }else{
                print("Error login out", error!.localizedDescription)
            }
        }
    }
}
