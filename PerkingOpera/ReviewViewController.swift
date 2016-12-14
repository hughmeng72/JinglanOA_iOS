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
    
    @IBOutlet weak var cancel: UIButton!
    
    
    @IBOutlet weak var wordsTextView: UITextView!
    
    var submitHandler: ((ReviewViewController?) -> Void)?
    
    var flow: Flow?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.reviewButton.isMultipleSelectionEnabled = false
        
        registerDismissKeyboardEvent()
    }

    // Dismiss keyboard when user click anyplace else
    func registerDismissKeyboardEvent() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    

    @IBAction func action(_ sender: Any) {

        if self.reviewButton.selectedButtons().count == 0 {
            let controller = UIAlertController(
                title: "请选择审批结果",
                message: "", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(
                title: "Ok",
                style: .cancel, handler: nil)
            
            controller.addAction(cancelAction)
            
            self.present(controller, animated: true, completion: nil)
            
            return
        }
        
        self.submitHandler!(self)
    }
    
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
