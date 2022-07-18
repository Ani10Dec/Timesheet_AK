//
//  AddTaskViewController.swift
//  Timesheet_AK
//
//  Created by Aniket Kumar on 10/07/22.
//

import UIKit
import Firebase

class AddTaskDialogView: UIViewController {
    let db = Firestore.firestore()
    
    @IBOutlet weak var dialogTitleLabel: UILabel!
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var tfMonth: UITextField!
    @IBOutlet weak var tfTaskName: UITextField!
    @IBOutlet weak var primaryBtn: UIButton!
    @IBOutlet weak var tfDescription: UITextField!
    @IBOutlet weak var statusSegmentView: UISegmentedControl!
    
    var projectName = ""
    var dialogTitle = Constant.CREATE_YOUR_TASK
    var taskName = ""
    var desc = ""
    var month = ""
    var status = 0
    var primaryBtnText = AppConstants.CREATE
    var datePicker  = UIDatePicker()
    
    // Previous value
    var previousTaskName = ""
    var previousTaskDate = ""
    var previousTaskDesc = ""
    var previousTaskStatus = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dialogView.layer.cornerRadius = 20
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        // Getting data from previous screen from edit
        dialogTitleLabel.text = dialogTitle
        tfTaskName.text = taskName
        tfDescription.text  = desc
        tfMonth.text = month
        primaryBtn.setTitle(primaryBtnText, for: .normal)
        statusSegmentView.selectedSegmentIndex = status
        
        // Checking previous value
        if let name = tfTaskName.text {
            previousTaskName = name
        }
        
        if let desc = tfDescription.text {
            previousTaskDesc = desc
        }
        
        if let month = tfMonth.text {
            previousTaskDate = month
        }
        
        previousTaskStatus = statusSegmentView.selectedSegmentIndex
        
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
    
    @IBAction func createBtnPressed(_ sender: UIButton) {
        
        uploadDataIntoFirestore(with: sender.currentTitle!)
    }
    
    
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        if isValuesChanged() {
            alertView(title: "", desc: AppConstants.CHANGES_FOUND, pBtn: AppConstants.DISCARD, sBtn: AppConstants.BACK, multiBtn: true)
        } else {
            self.dismiss(animated: true)
        }
    
    }
    
    private func uploadDataIntoFirestore(with: String) {
        
        guard let name = tfTaskName.text, !name.isEmpty,
              let month = tfMonth.text, !month.isEmpty,
        let desc = tfDescription.text, !desc.isEmpty else {
            alertView(title: "", desc: AppConstants.FIELD_MUST_FIELD, pBtn: "", sBtn: AppConstants.OK,multiBtn: false)
            return
        }
        
        var status = ""
        switch statusSegmentView.selectedSegmentIndex {
        case 0 : status = AppConstants.TaskConstants.TODO
        case 1: status = AppConstants.TaskConstants.IN_PROGRESS
        case 2: status = AppConstants.TaskConstants.DONE
        default:
            print("No segment selected")
        }
        
        let docData: [String: Any] = [
            AppConstants.TaskConstants.TASK_NAME: name,
            AppConstants.TaskConstants.TASK_MONTH: month,
            AppConstants.TaskConstants.TASK_DESC: desc,
            AppConstants.TaskConstants.TASK_STATUS: status
        ]
        
        let database = db.collection(AppConstants.USERS)
            .document(Auth.auth().currentUser?.uid ?? "")
            .collection(AppConstants.COLLECTION_NAME)
            .document(projectName).collection(AppConstants.TASKS)
            .document(name)
        
        if with == AppConstants.CREATE {
            
            database.setData(docData) { error in
                if let error = error {
                    print("There was an issue saving data in firestore, \(error)")
                } else {
                    print("Successfully saved data.")
                    self.dismiss(animated: true)
                }
            }
        } else {
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
    
    private func isValuesChanged() -> Bool {
        
        if tfTaskName.text != previousTaskName
            || tfMonth.text != previousTaskDate
            || statusSegmentView.selectedSegmentIndex != previousTaskStatus
            || tfDescription.text != previousTaskDesc {
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


private struct Constant {
    static let CREATE_YOUR_TASK = "Create your task"
    static let TODO = "Todo"
    static let IN_PROGRESS = "Medium"
    static let HIGH = "High"
}
