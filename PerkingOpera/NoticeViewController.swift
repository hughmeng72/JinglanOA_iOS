//
//  NoticeViewController.swift
//  PerkingOpera
//
//  Created by admin on 01/12/2016.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import Gloss
import UIKit

class NoticeViewController: UITableViewController, XMLParserDelegate {

    weak var activityIndicatorView: UIActivityIndicatorView!
    
    private let soapMethod = "GetNoticeList"
    
    var elementValue: String?
    
    var list: [Notice]! = nil
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 48
       
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        tableView.backgroundView = activityIndicatorView
        
        self.activityIndicatorView = activityIndicatorView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.list == nil {
            load()
        }
        else {
            self.tableView.reloadData()
        }
    }
    
    func load() {
        
        self.activityIndicatorView.startAnimating()
        
        guard let user = Repository.sharedInstance.user
            else {
                print("Failed to get user object")
                return
        }
        
        let parameters = "<token>\(user.token)</token>"
        
        let request = SoapHelper.getURLRequest(method: soapMethod, parameters: parameters)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("network error: \(error)")
                return
            }
            
            let parser = XMLParser(data: data)
            parser.delegate = self
            guard parser.parse() else {
                print("parsing error: \(parser.parserError)")
                return
            }
            
            // if we've gotten here, update the UI
            DispatchQueue.main.async {
                
                self.activityIndicatorView.stopAnimating()
                
                if self.list == nil {
                    self.list = []
                }
                
                if self.list.count == 0 {
                    let controller = UIAlertController(
                        title: "没有检索到相关数据",
                        message: "", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(
                        title: "Ok",
                        style: .cancel, handler: nil)
                    
                    controller.addAction(cancelAction)
                    
                    self.present(controller, animated: true, completion: nil)
                    
                    return
                }
                
                self.tableView.reloadData()
            }
        }
        
        task.resume()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return list == nil ? 0 : list.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        let item = list[indexPath.row]
        
        cell.subjectLabel.text = item.title
        cell.categoryLabel.text = item.typeName
        cell.timeLabel.text = item.addTime
        
        return cell
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNotice" {
            if let row = tableView.indexPathForSelectedRow?.row {
                let item = list[row]
                let webController = segue.destination as! WebViewController
                
                webController.urlString = item.url
            }
        }
    }
    
    // MARK: - XML Parser
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "\(soapMethod)Result" {
            elementValue = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        elementValue? += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "\(soapMethod)Result" {
//            print(elementValue ?? "Not got any data from ws.")
            
            let result = convertStringToDictionary(text: elementValue!)
            print(result ?? "Not got any data from ws.")
            
            guard let resultObject = ResponseResultList<Notice>(json: result!) else {
                print("DECODING FAILURE :(")
                return
            }
            
            self.list = resultObject.list
            
            elementValue = nil;
        }
    }
    
    func convertStringToDictionary(text: String) -> JSON? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? JSON
            } catch let error as NSError {
                print(error)
            }
        }
        
        return nil
    }

}
