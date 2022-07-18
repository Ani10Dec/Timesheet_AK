//
//  TaskViewController.swift
//  Timesheet_AK
//
//  Created by Aniket Kumar on 10/07/22.
//

import UIKit
import Firebase

class TaskViewController: UIViewController {
    let db = Firestore.firestore()
    let refreshControl = UIRefreshControl()
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var titleText = ""
    var taskList : [Tasks] = []
    var filterList: [Tasks]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        titleLabel.text = titleText
        loadFirebaseData()
        filterList = taskList
        
        refreshControl.attributedTitle = NSAttributedString(string: AppConstants.PULL_TO_REFRESH)
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)

    }
    
    @objc func refresh(_ sender: AnyObject) {
        loadFirebaseData()
    }
    
    private func loadFirebaseData() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        print(uid)
        
        db.collection(AppConstants.USERS)
            .document(Auth.auth().currentUser?.uid ?? "")
            .collection(AppConstants.COLLECTION_NAME).document(titleText).collection(AppConstants.TASKS)
            .addSnapshotListener { (snapShots, error) in
                
                if let e = error {
                    print("There was an issue retrieving data from Firestore. \(e)")
                } else {
                    if let snapShotsDocuments = snapShots?.documents {
                        self.taskList = []
                        for doc in snapShotsDocuments {
                            let data = doc.data()
                            if let taskName = data[AppConstants.TaskConstants.TASK_NAME] as? String,
                               let taskDesc = data[AppConstants.TaskConstants.TASK_DESC] as? String,
                               let taskMonth = data[AppConstants.TaskConstants.TASK_MONTH] as? String,
                               let taskStatus = data[AppConstants.TaskConstants.TASK_STATUS] as? String {
                                let newTask = Tasks(TaskName: taskName, desc: taskDesc, month: taskMonth, status: taskStatus, projectName: self.titleText)
                                
                                self.taskList.append(newTask)
                                
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                            }
                        }
                        self.filterList = self.taskList
                    }
                }
            }
        refreshControl.endRefreshing()
    }
    
    @IBAction func backBtnPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func addBtnPressed(_ sender: UIBarButtonItem) {
        gotToAddTaskDialog(isEdit: false, at: nil)
    }
    
    private func gotToAddTaskDialog(isEdit: Bool, at: Int?) {
        let dialogVC = storyboard?.instantiateViewController(withIdentifier: Constant.ADD_TASK_VIEWCONTROLLER) as! AddTaskDialogView
        
        if isEdit {
            dialogVC.taskName = filterList[at!].TaskName
            dialogVC.desc = filterList[at!].desc
            dialogVC.month = filterList[at!].month
            dialogVC.dialogTitle = Constant.EDIT_YOUR_TASK
            dialogVC.primaryBtnText = AppConstants.EDIT
            switch filterList[at!].status {
                
            case Constant.TODO :  dialogVC.status = 0
            case Constant.IN_PROGRESS : dialogVC.status = 1
            case Constant.DONE :  dialogVC.status = 2
            default: print("")
                
            }
            
        }
        dialogVC.projectName = titleText
        dialogVC.modalPresentationStyle = .overCurrentContext
        dialogVC.providesPresentationContextTransitionStyle = true
        dialogVC.definesPresentationContext = true
        dialogVC.modalTransitionStyle = .crossDissolve
        present(dialogVC, animated: true)
    }

}

extension TaskViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filterList.count == 0 {
//            searchBar.isHidden = true
            self.tableView.setEmptyMessage(Constant.EMPLTY_TABLE_VIEW_TEXT)
         } else {
//             searchBar.isHidden = false
             self.tableView.restore()
         }
        
        return filterList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.TASK_CELL, for: indexPath) as! TaskTableCell
        cell.taskLabel.text = filterList[indexPath.row].TaskName
        cell.date.text = filterList[indexPath.row].month
        cell.statusLabel.text = filterList[indexPath.row].status
        
        switch filterList[indexPath.row].status {
            
        case Constant.TODO : do {
            cell.statusView.backgroundColor = UIColor.blueColor
            cell.statusLabelView.backgroundColor = UIColor.blueColor
        }
            
        case Constant.IN_PROGRESS : do {
            cell.statusView.backgroundColor = UIColor.yellowColor
            cell.statusLabelView.backgroundColor = UIColor.yellowColor
        }
            
        case Constant.DONE : do {
            cell.statusView.backgroundColor = UIColor.greenColor
            cell.statusLabelView.backgroundColor = UIColor.greenColor
        }
            
        default: print("")
            
        }
        
        return cell
    }
    
    
    // MARK: Delegate Method
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: AppConstants.EDIT) { action, _, _ in
            self.gotToAddTaskDialog(isEdit: true, at: indexPath.row)
        }
        
        let delete = UIContextualAction(style: .destructive, title: AppConstants.DELETE) { action, _, _ in
            let alert = UIAlertController(title: AppConstants.WARNIING, message: Constant.REMOVE_TASK_TEXT, preferredStyle: .alert)
            
            let yes = UIAlertAction(title: AppConstants.YES, style: .destructive) { _ in
                self.db.collection(AppConstants.USERS)
                    .document(Auth.auth().currentUser?.uid ?? "")
                    .collection(AppConstants.COLLECTION_NAME)
                    .document(self.titleText)
                    .collection(AppConstants.TASKS)
                    .document(self.filterList[indexPath.row].TaskName)
                    .delete { error in
        
                    if let error = error {
                        print("There was an issue deleting data in firestore, \(error)")
                    } else {
                        print("Successfully deleted the data.")
                    }
                }
            }
            
            let no = UIAlertAction(title: AppConstants.NO, style: .default)
            
            alert.addAction(yes)
            alert.addAction(no)
          
            
            self.present(alert, animated: true)
        }
        
        let swipeConfig = UISwipeActionsConfiguration(actions: [edit, delete])
        return swipeConfig
    }
    
}

extension TaskViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterList = []
        
        if searchText == "" {
            filterList = taskList
        } else {
            for task in taskList {
                if task.projectName.lowercased().contains(searchText.lowercased()) {
                    filterList.append(task)
                }
            }
        }
        
        self.tableView.reloadData()
    }
}

private struct Constant {
    static let EMPLTY_TABLE_VIEW_TEXT = "You don't have any task yet. \nYou can add task by clicking the add (+)."
    static let REMOVE_TASK_TEXT = "Are you sure you want to remove this task?"
    static let EDIT_YOUR_TASK = "Edit your task"
    static let ADD_TASK_VIEWCONTROLLER = "addTaskVC"
    static let TASK_CELL = "taskCell"
    static let TODO = "Todo"
    static let IN_PROGRESS = "In Progress"
    static let DONE = "Done"
}


