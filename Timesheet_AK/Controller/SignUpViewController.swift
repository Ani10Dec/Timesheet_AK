//
//  SignUpViewController.swift
//  Timesheet_AK
//
//  Created by Aniket Kumar on 08/07/22.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var tfConfirmPassword: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfName : UITextField!
    @IBOutlet weak var signUpBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfEmail.delegate = self
        tfPassword.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action:#selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        signUpBtn.layer.cornerRadius = 18
        
        hideLoader()
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func signUpBtnPressed(_ sender: UIButton) {
        showLoader()
        
        guard let name = tfName.text, !name.isEmpty,
              let email = tfEmail.text, !email.isEmpty ,
              let password = tfPassword.text, !password.isEmpty,
              let confirmPassword = tfConfirmPassword.text, !confirmPassword.isEmpty else {
            print("Enter valide field")
            return
        }
        
  
        
        if password == confirmPassword {
            
            Auth.auth().createUser(withEmail: email, password: confirmPassword, completion: { [weak self] authResult, authError in
                
                guard let strongSelf = self else {
                    return
                }
                
                guard authError == nil else {
                    strongSelf.showErrorAlert(title: Constant.ALERT_TITLE, message: authError?.localizedDescription ?? Constant.ALERT_DESC)
                    self!.hideLoader()
                    return
                }
                
                self!.gotToSignInScreen()
                
            })
        } else {
            hideLoader()
            showErrorAlert(title: "Note!", message: Constant.PASSWORD_MISSMATCH)
        }
    }
    
    
    func gotToSignInScreen() {
        
        hideLoader()
        
        if let storyboard = self.storyboard {
            let vc = storyboard.instantiateViewController(withIdentifier:  AppConstants.SIGN_IN) as! SignInViewController
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
        }
        
//        let controller = UIStoryboard(name: AppConstants.MAIN, bundle: nil).instantiateViewController(withIdentifier: AppConstants.SIGN_IN) as! SignInViewController
//        controller.modalPresentationStyle = .fullScreen
//        present(controller, animated: true, completion: nil)
    }
    
    private func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title:  title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: AppConstants.OK, style: .cancel, handler: { _ in
            alert.dismiss(animated: true)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func showLoader() {
        loadingView.isHidden = false
        spinner.startAnimating()
    }
    
    private func hideLoader() {
        loadingView.isHidden = true
        spinner.stopAnimating()
    }
 }


extension SignUpViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == tfEmail {
            tfPassword.becomeFirstResponder()
        }
        
        if textField == tfPassword {
            tfConfirmPassword.becomeFirstResponder()
        }
        
        if textField == tfConfirmPassword {
            dismissKeyboard()
            return false
        }
        
        return true
    }
}


private struct Constant {
    static let ALERT_TITLE = "We are having some trouble!"
    static let ALERT_DESC = "We are deeply sorry for inconvience, Please try agin later"
    static let PASSWORD_MISSMATCH = "Password missmatch"
}
