//
//  ProfileViewController.swift
//  Timesheet_AK
//
//  Created by Aniket Kumar on 15/07/22.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImage.layer.borderWidth = 1
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.blue.cgColor
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
    }
    
    @IBAction func backBtnPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func logOutPressed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { _ in
            do { try Auth.auth().signOut() }
            catch { print("already logged out") }
            
            UserDefaults.standard.removeObject(forKey: AppConstants.USER_UID)
            
            if let storyboard = self.storyboard {
                let vc = storyboard.instantiateViewController(withIdentifier: "signInVC") as! SignInViewController
                self.present(vc, animated: false, completion: nil)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        
        present(alert, animated: true)
        
       
    }
}
