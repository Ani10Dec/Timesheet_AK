//
//  ViewController.swift
//  Timesheet_AK
//
//  Created by Aniket Kumar on 08/07/22.
//

import UIKit
import FirebaseAuth

class WelcomeViewController: UIViewController {
    
    private lazy var defaults = UserDefaults.standard
    
    @IBOutlet weak var appName : UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appName.text = ""
        var charIndex = 0.0
        let titleText = "⚡️TimeSheet"
        for letter in titleText {
            Timer.scheduledTimer(withTimeInterval: 0.1 * charIndex, repeats: false) { (timer) in
                self.appName.text?.append(letter)
            }
            charIndex += 1
        }
        
        checkForLoginUser()
    }

    fileprivate func goToHomeScreen() {
        let controller = UIStoryboard(name: AppConstants.MAIN, bundle: nil).instantiateViewController(withIdentifier: AppConstants.PROJECT_VC) as! ProjectViewController
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true, completion: nil)
    }
    
    private func checkForLoginUser() {
        if let _ = defaults.string(forKey: AppConstants.USER_UID) {
            goToHomeScreen()
        }
    }

}

