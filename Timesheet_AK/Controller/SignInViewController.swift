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
                strongSelf.showCreateAccountAlert()
                return
            }
            
            self!.gotToDashboardScreen()
            
        })
        
    }
    
    func gotToDashboardScreen() {
        hideLoader()
        let controller = UIStoryboard(name: AppConstants.MAIN, bundle: nil).instantiateViewController(withIdentifier: AppConstants.PROJECT_VC) as! ProjectViewController
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true, completion: nil)
    }
    
    func showCreateAccountAlert() {
        let alert = UIAlertController(title: Constant.NO_USER_FOUND, message: Constant.ALERT_DESC, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: AppConstants.YES, style: .default, handler: { _ in
            self.goToSignUp()
        }))
        
        alert.addAction(UIAlertAction(title: AppConstants.NO, style: .cancel, handler: { _ in
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
        rightEyeImage.image = UIImage(named: "eye_light")

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
