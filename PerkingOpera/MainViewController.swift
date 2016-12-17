//
//  MainViewController.swift
//  PerkingOpera
//
//  Created by admin on 29/11/2016.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let user = Repository.sharedInstance.user
        print(user?.token ?? "Unknown User")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showRequestToDoList(_ sender: Any) {
        self.performSegue(withIdentifier: "showRequestToDoList", sender: nil)
    }

    @IBAction func showFinanceRequestList(_ sender: Any) {
        self.performSegue(withIdentifier: "showFinanceRequestList", sender: nil)
    }
    
    @IBAction func showGeneralRequestList(_ sender: Any) {
        self.performSegue(withIdentifier: "showGeneralRequestList", sender: nil)
    }

    @IBAction func showGovToDoList(_ sender: Any) {
        self.performSegue(withIdentifier: "showGovToDoList", sender: nil)
    }
    
    @IBAction func showDocList(_ sender: Any) {
        self.performSegue(withIdentifier: "showDocList", sender: nil)
    }
    
    @IBAction func showReimburseRequest(_ sender: Any) {
        self.performSegue(withIdentifier: "showReimburseRequest", sender: nil)
    }
    
    @IBAction func showNoticeList(_ sender: Any) {
        self.performSegue(withIdentifier: "showNoticeList", sender: nil)
    }
    
    @IBAction func showMailList(_ sender: Any) {
        self.performSegue(withIdentifier: "showMailList", sender: nil)
    }

    
    @IBAction func showCalendarList(_ sender: Any) {
        self.performSegue(withIdentifier: "showCalendarList", sender: nil)
    }
    
    @IBOutlet weak var showReimburse: RoundButton!
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
