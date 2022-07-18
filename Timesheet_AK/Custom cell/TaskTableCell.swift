//
//  TaskTableCell.swift
//  Timesheet_AK
//
//  Created by Aniket Kumar on 10/07/22.
//

import UIKit

class TaskTableCell: UITableViewCell {

    @IBOutlet weak var taskMainView: UIView!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabelView: UIView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        statusLabelView.layer.cornerRadius = 6
        taskMainView.clipsToBounds = true
        taskMainView.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
