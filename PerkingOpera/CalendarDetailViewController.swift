//
//  CalendarDetailViewController.swift
//  PerkingOpera
//
//  Created by admin on 12/11/16.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import UIKit
import WebKit

class CalendarDetailViewController: UITableViewController, WKNavigationDelegate {
    
    var urlString: String!
    
    var attachments = [FlowDoc]()

    @IBOutlet weak var container: UIView!
    
    private var webView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 48

        let url = URL(string: self.urlString)
        let request = URLRequest(url: url!)
        
        webView = WKWebView(frame: container.frame)
        webView?.navigationDelegate = self
        let _ = webView?.load(request)
        container.addSubview(webView!)
        container.sendSubview(toBack: webView!)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let headerView = tableView.tableHeaderView!
        
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showCalendarAttachment" {
            
            if let row = tableView.indexPathForSelectedRow?.row {
                let item = self.attachments[row]
                let destVC = segue.destination as! WebViewController
                
                destVC.urlString = item.uri
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.attachments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AttachmentCell", for: indexPath)
        
        let item = attachments[indexPath.row]
        
        cell.textLabel?.text = item.fileName
        
        return cell
    }

    
    
    
}
