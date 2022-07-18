//
//  DashboardViewController.swift
//  Timesheet_AK
//
//  Created by Aniket Kumar on 09/07/22.
//

import UIKit
import Firebase

class ProjectViewController: UIViewController {
    
    let db = Firestore.firestore()
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var channelTableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    let controller  = AddProjectDialogView()
    var projectList: [Projects] = []
    var filterData: [Projects]!
    var isSearchEnableed = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegate and DataSources
        channelTableView.dataSource = self
        channelTableView.delegate = self
        searchBar.delegate = self
        
        loadFirebaseData()
        filterData = projectList
        
        refreshControl.attributedTitle = NSAttributedString(string: AppConstants.PULL_TO_REFRESH)
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        channelTableView.addSubview(refreshControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        loadFirebaseData()
    }
    
    @IBAction func addChannelPressed(_ sender: UIBarButtonItem) {
        gotToAddProjectDialog(isEdit: false, at: nil)
    }
    
    
    private func gotToAddProjectDialog(isEdit: Bool, at: Int?) {
        
        let dialogVC = storyboard?.instantiateViewController(withIdentifier: Constant.ADD_CHANNEL_VC) as! AddProjectDialogView
        
        if isEdit {
            
            dialogVC.dialogTitleText = Constant.EDIT_YOUR_PROJECT
            dialogVC.primaryBtnText = Constant.EDIT
            dialogVC.channelName = filterData[at!].projectName
            dialogVC.channelDate = filterData[at!].date
            
            switch filterData[at!].importance {
            case Constant.HIGH :  dialogVC.importance = 2
            case Constant.MEDIUM : dialogVC.importance = 1
            case Constant.DONE :  dialogVC.importance = 0
            default: print("")
                
            }
        }
        
        dialogVC.modalPresentationStyle = .overCurrentContext
        dialogVC.providesPresentationContextTransitionStyle = true
        dialogVC.definesPresentationContext = true
        dialogVC.modalTransitionStyle = .crossDissolve
        present(dialogVC, animated: true)
    }
    
    private func loadFirebaseData() {
        
        guard let uid = AuthFile.uid else {
            return
        }
        
        db.collection(AppConstants.USERS)
            .document(uid)
            .collection(AppConstants.COLLECTION_NAME)
            .addSnapshotListener { (snapShots, error) in
                
                if let e = error {
                    print("\(Constant.FIREBASE_RETRIEVE_ERROR) \(e)")
                } else {
                    if let snapShotsDocuments = snapShots?.documents {
                        self.projectList = []
                        for doc in snapShotsDocuments {
                            let data = doc.data()
                            if let projectName = data[AppConstants.ProjectConstants.PROJECT_NAME] as? String,
                               let projectMonth = data[AppConstants.ProjectConstants.PROJECT_MONTH] as? String,
                               let projectImportance = data[AppConstants.ProjectConstants.PROJECT_IMPORTANCE] as? String {
                                let newProject = Projects(projectName: projectName, date: projectMonth, importance: projectImportance)
                                self.projectList.append(newProject)
                                
                                DispatchQueue.main.async {
                                    self.channelTableView.reloadData()
                                }
                            }
                        }
                        self.filterData = self.projectList
                    }
                }
                
            }
        refreshControl.endRefreshing()
    }
    
}

// MARK: - TableView Delegates and DataSources
extension ProjectViewController : UITableViewDataSource, UITableViewDelegate {
    
    //MARK: DataSource Method
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.CHANNEL_CELL, for: indexPath) as! ChannelTableCell
        
        cell.channelName.text = filterData[indexPath.row].projectName
        cell.dateLabel.text = filterData[indexPath.row].date
        cell.importanceLabel.text = filterData[indexPath.row].importance
        
        switch filterData[indexPath.row].importance {
            
        case Constant.NORMAL : do {
            cell.importanceLabelView.backgroundColor = UIColor.blueColor
            cell.importanceVerticalView.backgroundColor = UIColor.blueColor
        }
            
        case Constant.MEDIUM: do {
            cell.importanceLabelView.backgroundColor = UIColor.yellowColor
            cell.importanceVerticalView.backgroundColor = UIColor.yellowColor
        }
            
        case Constant.HIGH : do {
            cell.importanceLabelView.backgroundColor = UIColor.redColor
            cell.importanceVerticalView.backgroundColor = UIColor.redColor
        }
            
        default: print("")
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if filterData.count == 0 {
            self.channelTableView.setEmptyMessage(Constant.EMPTY_TABLE_VIEW_TEXT)
        } else {
            self.channelTableView.restore()
            
        }
        
        return filterData.count
    }
    
    
    // MARK: Delegate Method
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: Constant.EDIT) { action, _, _ in
            self.gotToAddProjectDialog(isEdit: true, at: indexPath.row)
        }
        
        let delete = UIContextualAction(style: .destructive, title: Constant.DELETE) { action, _, _ in
            let alert = UIAlertController(title: AppConstants.WARNIING, message: Constant.REMOVE_PROJECT_TEXT, preferredStyle: .alert)
            
            let yes = UIAlertAction(title: AppConstants.YES, style: .destructive) { _ in
                
                guard let uid = AuthFile.uid else {
                    return
                }
                
                // Remove collection with documents
                self.db.collection(AppConstants.USERS)
                    .document(uid)
                    .collection(AppConstants.COLLECTION_NAME)
                    .document(self.filterData[indexPath.row]
                        .projectName).collection(AppConstants.TASKS)
                    .document()
                    .delete { error in
                        if let error = error {
                            print("There was an issue deleting data with collection in firestore, \(error)")
                        } else {
                            print("Successfully deleted the data with collection.")
                        }
                    }
                
                // Remove collection
                self.db.collection(AppConstants.USERS)
                    .document(uid)
                    .collection(AppConstants.COLLECTION_NAME)
                    .document(self.filterData[indexPath.row]
                        .projectName).delete { error in
                            
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
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.text = ""
        let controller = storyboard?.instantiateViewController(withIdentifier: Constant.TASK_VC) as! TaskViewController
        controller.titleText = filterData[indexPath.row].projectName
        controller.modalPresentationStyle = .fullScreen
        controller.providesPresentationContextTransitionStyle = true
        controller.modalTransitionStyle = .coverVertical
        present(controller, animated: true)
    }
}

//MARK: - Searchbar Delegate Method
extension ProjectViewController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterData = []
        
        if searchText == "" {
            filterData = projectList
        } else {
            for project in projectList {
                if project.projectName.lowercased().contains(searchText.lowercased()) {
                    filterData.append(project)
                }
            }
        }
        
        self.channelTableView.reloadData()
    }
}

private struct Constant {
    static let TASK_VC = "taskVC"
    static let NORMAL = "Normal"
    static let MEDIUM = "Medium"
    static let HIGH = "High"
    static let IN_PROGRESS = "In Progress"
    static let DONE = "Done"
    static let EDIT = "Edit"
    static let DELETE = "Delete"
    static let CHANNEL_CELL = "channelCell"
    static let EDIT_YOUR_PROJECT = "Edit your project"
    static let ADD_CHANNEL_VC = "addChannelVC"
    static let EMPTY_TABLE_VIEW_TEXT = "You don't have any project yet. \nYou can add projects by clicking the add (+)."
    static let REMOVE_PROJECT_TEXT = "Are you sure you want to remove this project?"
    static let FIREBASE_RETRIEVE_ERROR = "There was an issue retrieving data from Firestore."
}
