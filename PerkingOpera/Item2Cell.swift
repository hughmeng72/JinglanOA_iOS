//
//  Item2CellTableViewCell.swift
//  PerkingOpera
//
//  Created by admin on 03/12/2016.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import UIKit

class Item2Cell: UITableViewCell {
    
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var addTimeLabel: UILabel!

    func updateUI() {
        let bodyFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        subjectLabel.font = bodyFont
        
        let captionFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)
        categoryLabel.font = captionFont
        creatorLabel.font = captionFont
        amountLabel.font = captionFont
        addTimeLabel.font = captionFont
    }
    

}
