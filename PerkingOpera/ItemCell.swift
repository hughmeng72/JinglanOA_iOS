//
//  ItemCell.swift
//  PerkingOpera
//
//  Created by admin on 02/12/2016.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {

    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    func updateUI() {
        let bodyFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        subjectLabel.font = bodyFont
        
        let captionFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)
        categoryLabel.font = captionFont
        timeLabel.font = captionFont
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
