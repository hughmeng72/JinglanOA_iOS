//
//  PlanDetailViewController.swift
//  PerkingOpera
//
//  Created by admin on 12/11/16.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import UIKit
import WebKit

class PlanDetailViewController: UIViewController, WKNavigationDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var urlString: String!
    
    var attachments = [FlowDoc]()

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var container: UIView!
    
    private var webView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 48
        
        let url = URL(string: self.urlString)
        let request = URLRequest(url: url!)
        
        webView = WKWebView(frame: self.view.frame)
        webView?.navigationDelegate = self
        let _ = webView?.load(request)
        container.addSubview(webView!)
        container.sendSubview(toBack: webView!)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showAttachment" {
            
            if let row = tableView.indexPathForSelectedRow?.row {
                let item = self.attachments[row]
                let destVC = segue.destination as! WebViewController
                
                destVC.urlString = item.uri
            }
        }
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.attachments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AttachmentCell", for: indexPath)
        
        let item = attachments[indexPath.row]
        
        cell.textLabel?.text = item.fileName
        
        return cell
    }

}
