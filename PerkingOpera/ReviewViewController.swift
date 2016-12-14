//
//  ReviewViewController.swift
//  PerkingOpera
//
//  Created by admin on 14/12/2016.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import UIKit
import DLRadioButton

class ReviewViewController: UIViewController {
    
    @IBOutlet var reviewButton: DLRadioButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.reviewButton.isMultipleSelectionEnabled = false
    }

}
