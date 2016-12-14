//
//  FlowDetailViewController.swift
//  PerkingOpera
//
//  Created by admin on 12/4/16.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import Gloss
import UIKit

class FlowDetailViewController: UITableViewController, XMLParserDelegate {
    
    var itemId: Int!
    
    private let soapMethod = "GetFlowDetail"
    
    private var elementValue: String?
    
    private var item: Flow?
    
    private var steps = [FlowStep]()
    
    private var attachments = [FlowDoc]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 48
        
        guard let user = Repository.sharedInstance.user
            else {
                print("Failed to get user object")
                return
        }
        
        let parameters = "<token>\(user.token)</token>"
            + "<flowId>\(itemId!)</flowId>"
        
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
                if self.item == nil {
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
    
    
    @IBAction func review(_ sender: Any) {
//        let reviewVC = ReviewViewController()
//        reviewVC.view.frame = (UIApplication.shared.keyWindow?.bounds)!

        let reviewVC = self.storyboard?.instantiateViewController(withIdentifier: "reviewController") as! ReviewViewController
        
        self.present(reviewVC, animated: true, completion: { () -> Void in
            print("show ReviewVC...")
        })
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showFlowAttachment" {
            
            if let row = tableView.indexPathForSelectedRow?.row {
                let item = self.attachments[row]
                let destVC = segue.destination as! WebViewController
                
                destVC.urlString = item.uri
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if item != nil && item?.attachments != nil {
                return item!.attachments!.count
            }
            else {
                return 0
            }
        case 2:
            if item != nil && item?.steps != nil {
                return item!.steps!.count
            }
            else {
                return 0
            }
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "基本信息"
        case 1:
            return "附件"
        case 2:
            return "审批进度"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FlowHeaderCell", for: indexPath) as! FlowHeaderCell

            if let item = self.item {
                cell.flowNameLabel.text = item.flowName
                cell.flowNoLabel.text = item.flowNo
                cell.depNameLabel.text = item.depName
                cell.creatorLabel.text = item.creator
                cell.createDateLabel.text = item.createTime
                cell.amountLabel.text = "\(item.amount)"

//                cell.remarkLabel.text = item.remark
                cell.remarkLabel.attributedText = HtmlHelper.stringFromHtml(string: self.item?.remark)

                cell.itemNameLabel.text = item.itemName
                cell.projectNameLabel.text = item.projectName
                cell.totalAmountLabel.text = "\(item.totalAmount)"
                cell.amountLeftLabel.text = "\(item.amountLeft)"
                cell.amountBeingPaidProcurementLabel.text = "\(item.amountToBePaidProcurement)"
                cell.amountPaidProcurementLabel.text = "\(item.amountPaidProcurement)"
                cell.amountBeingPaidReimbursementLabel.text = "\(item.amountToBePaidReimbursement)"
                cell.amountPaidReimbursementLabel.text = "\(item.amountPaidReimbursement)"
            }
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AttachmentCell", for: indexPath)
            
            let item = attachments[indexPath.row]
            
            cell.textLabel?.text = item.fileName
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "StepCell", for: indexPath)
            
            let item = steps[indexPath.row]
            
            cell.textLabel?.text = item.stepName
            cell.detailTextLabel?.text = item.description

            return cell
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
            print(elementValue ?? "Not got any data from ws.")
            
            let result = convertStringToDictionary(text: elementValue!)
            print(result ?? "Not got any data from ws.")
            
            guard let resultObject = ResponseResultList<Flow>(json: result!) else {
                print("DECODING FAILURE :(")
                return
            }
            
            self.item = resultObject.list[0]
            
            if let a = self.item?.attachments {
                self.attachments = a
            }
            
            if let s = self.item?.steps {
                self.steps = s
            }
            
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
