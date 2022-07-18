//
//  AddChannelViewController.swift
//  Timesheet_AK
//
//  Created by Aniket Kumar on 09/07/22.
//

import UIKit
import Firebase


class AddProjectDialogView: UIViewController {
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var dialogTitle: UILabel!
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var tfMonth: UITextField!
    @IBOutlet weak var tfProjectName: UITextField!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var importanceSegment: UISegmentedControl!
    
    
    var dialogTitleText = Constant.CREATE_YOUR_CHANNEL
    var channelName = ""
    var channelDate = ""
    var importance = 0
    var primaryBtnText = AppConstants.CREATE
    
    // Previous value
    var previousProjectName = ""
    var previousDate = ""
    var previousImportance = 0
    
    var datePicker  = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dialogView.layer.cornerRadius = 20
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        let tap = UITapGestureRecognizer(target: self, action:#selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        dialogTitle.text = dialogTitleText
        createBtn.setTitle(primaryBtnText, for: .normal)
        tfProjectName.text = channelName
        tfMonth.text  = channelDate
        importanceSegment.selectedSegmentIndex = importance
        
        // Checking previous value
        if let name = tfProjectName.text {
            previousProjectName = name
        }
        
        if let month = tfMonth.text {
            previousDate = month
        }
        
        previousImportance = importanceSegment.selectedSegmentIndex
        
        createDatePicker()
        
    }
    
    func createDatePicker() {
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        
        toolBar.setItems([doneBtn], animated: true)
        tfMonth.inputAccessoryView = toolBar
        
        tfMonth.inputView = datePicker
        
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
    }
    
    @objc func donePressed() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        tfMonth.text = formatter.string(from: datePicker.date)
        print(datePicker.date)
        self.view.endEditing(true)
    }
    
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        if isValuesChanged() {
            alertView(title: "", desc: "There are some changes found. Would you like to save the changes?", pBtn: "Discard", sBtn: "Back", multiBtn: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func createBtnPressed(_ sender: UIButton) {
        
        uploadDataIntoFirestore(with: sender.currentTitle!)
        
    }
    private func uploadDataIntoFirestore(with: String) {
        
        guard let name = tfProjectName.text, !name.isEmpty,
              let month = tfMonth.text, !month.isEmpty else {
            alertView(title: "", desc: "All the fields must be filled", pBtn: "", sBtn: "OK",multiBtn: false)
            return
        }
        
        var importance = ""
        switch importanceSegment.selectedSegmentIndex {
        case 0 : importance = Constant.NORMAL
        case 1: importance = Constant.MEDIUM
        case 2: importance = Constant.HIGH
        default:
            print("No segment selected")
        }
        
        let docData: [String: Any] = [
            AppConstants.ProjectConstants.PROJECT_NAME: name,
            AppConstants.ProjectConstants.PROJECT_MONTH: month,
            AppConstants.ProjectConstants.PROJECT_IMPORTANCE: importance,
        ]
        
        let database = db.collection(AppConstants.USERS)
            .document(Auth.auth().currentUser?.uid ?? "")
            .collection(AppConstants.COLLECTION_NAME)
            .document(name)
        
        if with == AppConstants.CREATE {
            // Creating the new project
           database.setData(docData) { error in
                if let error = error {
                    print("There was an issue saving data in firestore, \(error)")
                } else {
                    print("Successfully saved data.")
                    self.dismiss(animated: true)
                }
            }
        } else {
            // Updating existing project
            database.updateData(docData) { error in
                if let error = error {
                    print("There was an issue updating data in firestore, \(error)")
                } else {
                    print("Successfully updated data.")
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func isValuesChanged() -> Bool {
        
        if tfProjectName.text != previousProjectName
            || tfMonth.text != previousDate
            || importanceSegment.selectedSegmentIndex != previousImportance {
            return true
        }
        
        return false
    }
    
    private func alertView(title: String, desc: String, pBtn: String, sBtn: String, multiBtn: Bool) {
        let alert = UIAlertController(title: title, message: desc, preferredStyle: .alert)
        
        if multiBtn {
            let discardBtn = UIAlertAction(title: pBtn, style: .default) { _ in
                self.dismiss(animated: true)
            }
            alert.addAction(discardBtn)
        }
        
        
        let back = UIAlertAction(title: sBtn, style: .cancel)
        
        
        alert.addAction(back)
        
        present(alert, animated: true)
    }
}


extension AddProjectDialogView : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfProjectName {
            tfMonth.becomeFirstResponder()
        }
        return true
    }
}


private struct Constant {
    static let CREATE_YOUR_CHANNEL = "Create your project"
    static let NORMAL = "Normal"
    static let MEDIUM = "Medium"
    static let HIGH = "High"
}
