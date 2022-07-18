//
//  ChannelTableCell.swift
//  Timesheet_AK
//
//  Created by Aniket Kumar on 10/07/22.
//

import UIKit

class ChannelTableCell: UITableViewCell {
    
    @IBOutlet weak var channelName: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var importanceVerticalView: UIView!
    @IBOutlet weak var importanceLabel: UILabel!
    @IBOutlet weak var importanceLabelView: UIView!
    
    @IBOutlet weak var channelMainView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        importanceLabelView.layer.cornerRadius = 6
        channelMainView.clipsToBounds = true
        channelMainView.layer.cornerRadius = 8
        
    
//        channelMainView.layer.cornerRadius = 8
//        channelMainView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
