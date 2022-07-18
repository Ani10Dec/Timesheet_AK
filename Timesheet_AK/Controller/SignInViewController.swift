//
//  SignInViewController.swift
//  Timesheet_AK
//
//  Created by Aniket Kumar on 08/07/22.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {
    
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var signUpScreenView: UIStackView!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var signInBtn: UIButton!
    
    private var isPasswordVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfEmail.delegate = self
        tfPassword.delegate = self
        signInBtn.layer.cornerRadius = 18
        
        addRightEyeImage()
        
        let tap = UITapGestureRecognizer(target: self, action:#selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        hideLoader()
    }
    
    @IBAction func signInBtnPressed(_ sender: UIButton) {
        
        showLoader()
        
        guard let email = tfEmail.text, !email.isEmpty ,
              let password = tfPassword.text, !password.isEmpty else {
            return
        }
        
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, authError in
            
            guard let strongSelf = self else {
                return
            }
            
            guard authError == nil else {
                self?.hideLoader()
                strongSelf.showCreateAccountAlert(AppConstants.ERROR, authError!)
                return
            }
            
            self?.showToast(message: "Sign in sucessfull", font: .systemFont(ofSize: 12.0))
            self!.gotToLoginScreen()
            
        })
        
    }
    
    func gotToLoginScreen() {
        
        hideLoader()
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let defaults = UserDefaults.standard
        defaults.setValue(uid, forKey: AppConstants.USER_UID)
        AuthFile.uid = defaults.string(forKey: AppConstants.USER_UID)
        
        let controller = UIStoryboard(name: AppConstants.MAIN, bundle: nil).instantiateViewController(withIdentifier: AppConstants.PROJECT_VC) as! ProjectViewController
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true, completion: nil)
    }
    
    func showCreateAccountAlert(_ title: String, _ desc: Error) {
        let alert = UIAlertController(title: title, message: desc.localizedDescription, preferredStyle: .alert)
        
        
        alert.addAction(UIAlertAction(title: AppConstants.OK, style: .cancel, handler: { _ in
            alert.dismiss(animated: true)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func isFieldValid() -> Bool {
        
        if (tfEmail.text == nil || tfEmail.text == "") {
            return false
        }
        
        if (tfPassword.text == nil || tfPassword.text == "") {
            return false
        }
        
        return true
    }
    
    func goToSignUp() {
        let controller = UIStoryboard(name: AppConstants.MAIN, bundle: nil).instantiateViewController(withIdentifier: Constant.SIGNUP) as! SignUpViewController
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func goToSignUpScreen() {
        goToSignUp()
    }
    
    func addRightEyeImage() {
        let rightEyeImage = UIImageView(frame: CGRect(x: CGFloat(tfPassword.frame.size.width - 50), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25)))
        let touchRecogniser = UITapGestureRecognizer(target: self, action: #selector(eyeBtnPressed))
        rightEyeImage.isUserInteractionEnabled = true
        rightEyeImage.addGestureRecognizer(touchRecogniser)
//        rightEyeImage.image = UIImage.openEyeImage
        
        tfPassword.rightView = rightEyeImage
        tfPassword.rightViewMode = .always
        
    }
    
    @objc private func eyeBtnPressed(){
        
        if !isPasswordVisible {
            tfPassword.isSecureTextEntry = false
        } else {
            tfPassword.isSecureTextEntry = true
        }
        
        isPasswordVisible = !isPasswordVisible
    }
    
    func showLoader() {
        spinner.startAnimating()
        loadingView.isHidden = false
    }
    
    func hideLoader() {
        spinner.stopAnimating()
        loadingView.isHidden = true
    }
}

extension SignInViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfEmail {
            tfPassword.becomeFirstResponder()
        } else {
            dismissKeyboard()
            return false
        }
        
        return true
    }
}


private struct Constant {
    static let NO_USER_FOUND = "No user found!"
    static let ALERT_DESC = "Would you like to create an account with new credentials?"
    static let SIGNUP = "signUp"
}
