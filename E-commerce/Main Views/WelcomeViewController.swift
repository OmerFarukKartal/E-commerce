//
//  WelcomeViewController.swift
//  E-commerce
//
//  Created by KARTAL on 25.07.2023.
//

import UIKit
import JGProgressHUD
import NVActivityIndicatorView


class WelcomeViewController: UIViewController {
    //MARK: IBOutlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var resendButtonOutlet: UIButton!
    
    //MARK: Vars
    
    let hud = JGProgressHUD(style: .dark)
    var activityIndicator: NVActivityIndicatorView?
    
    
    //MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.height / 2 - 30, width: 60.0, height: 60.0), type: .ballPulse, color: #colorLiteral(red: 0.9998469949, green: 0.4941213727, blue: 0.4734867811, alpha: 1.0), padding: nil)
    }
    
    
    //MARK: IBActions
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        
        dissmissView()
        
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        if textFieldsHaveText(){
            
            loginUser()
        }else {
            hud.textLabel.text = "All fields are required"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0)
            
        }
        
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        
        if textFieldsHaveText(){
            
            registerUser()
            
        }else {
            hud.textLabel.text = "All fields are required"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0)
            
        }
        
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: Any) {
        
        if emailTextField.text != "" {
            resetThePassword()
        }else{
            hud.textLabel.text = "Please insert email!"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0)
        }
        
    }
    @IBAction func resendEmailButtonPressed(_ sender: Any) {
        
        MUser.resendVerificationEmail(email:  emailTextField.text!) { (error) in
            
            print("Error resending email", error?.localizedDescription)
            
        }
        
    }
    
    //MARK: Login User
    
    private func loginUser() {
        
        showLoadingIndicator()
        
        MUser.lohinUserWith(email: emailTextField.text!, password: passwordTextfield.text!) { (error, isEmailVerified) in
            
            if error == nil {
                
                if isEmailVerified {
                    self.dissmissView()
                    print("Email is verified")
                    
                }else {
                    self.hud.textLabel.text = "Please Verify Your Email!"
                    self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.hud.show(in: self.view)
                    self.hud.dismiss(afterDelay: 2.0)
                    self.resendButtonOutlet.isHidden = false
                }
                
            }else {
                print("error loging in the user", error!.localizedDescription)
                self.hud.textLabel.text = error!.localizedDescription
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            }
            
            self.hideLoadingIndicator()
        }
    }
    
    
    
    //MARK: Register User
    
    private func registerUser() {
        
        showLoadingIndicator()
        
        MUser.registerUserWith(email: emailTextField.text!, password: passwordTextfield.text!) { (error) in
            
            if error == nil {
                self.hud.textLabel.text = "Verification Email send!"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            }else{
                print("error registering", error!.localizedDescription)
                self.hud.textLabel.text = error!.localizedDescription
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            }
            
            self.hideLoadingIndicator()
        }
    }
    
    
    //MARK: Helpers
    
    private func resetThePassword() {
        
        MUser.resetPasswordFor(email: emailTextField.text!) { (error) in
            
            if error == nil {
                self.hud.textLabel.text = "Reset password email sent!"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            } else {
                self.hud.textLabel.text = error!.localizedDescription
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            }
        }
    }
    
    private func textFieldsHaveText() -> Bool {
        return (emailTextField.text != "" && passwordTextfield.text != "")
    }
    
    private func dissmissView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Actvity Indicator
    
    private func showLoadingIndicator() {
        
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
}
