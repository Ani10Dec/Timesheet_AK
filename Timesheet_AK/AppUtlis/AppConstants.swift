//
//  AppConstants.swift
//  Timesheet_AK
//
//  Created by Aniket Kumar on 13/07/22.
//

import Foundation

struct AppConstants {
    static let USER_UID = "uid"
    static let ERROR = "Error"
    static let FIELD_MUST_FIELD = "All the fields must be filled"
    static let BACK = "Back"
    static let DISCARD = "Discard"
    static let CHANGES_FOUND = "There are some changes found. Would you like to save the changes?"
    static let DELETE = "Delete"
    static let ENTER_FIELDS = "Enter valid field"
    static let WARNIING = "Warning!"
    static let PULL_TO_REFRESH = "Pull to refresh"
    static let TASKS = "Tasks"
    static let USERS = "users"
    static let PROJECT_VC = "projectVC"
    static let SIGN_IN = "signInVC"
    static let YES = "Yes"
    static let NO = "No"
    static let MAIN = "Main"
    static let OK = "Ok"
    static let CREATE = "Create"
    static let EDIT = "Edit"
    static let COLLECTION_NAME = "collectionProject"
    

    struct ProjectConstants {
        static let PROJECT_NAME = "projectName"
        static let PROJECT_MONTH = "projectMonth"
        static let PROJECT_IMPORTANCE = "projectImportance"
    }
    
    struct TaskConstants {
        static let TASK_NAME = "taskName"
        static let TASK_MONTH = "taskMonth"
        static let TASK_STATUS = "taskStatus"
        static let TASK_DESC = "taskDesc"
        static let TODO = "Todo"
        static let IN_PROGRESS = "In Progress"
        static let DONE = "Done"
        
    }
}
