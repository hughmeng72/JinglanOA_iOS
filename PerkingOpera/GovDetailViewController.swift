//
//  GovDetailViewController.swift
//  PerkingOpera
//
//  Created by admin on 12/4/16.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import Gloss
import UIKit

class GovDetailViewController: UITableViewController, XMLParserDelegate {

    var itemId: Int!
    
    private let soapMethod = "GetGovDetail"
    private let soapMethodAgreed = "SubmitGovRequest"
    private let soapMethodFinalized = "FinalizeGovRequest"
    
    private var elementValue: String?
    
    private var item: Gov?
    
    private var steps = [FlowStep]()
    
    private var attachments = [FlowDoc]()
    
    private var reviewResult: ResponseBase?
    
    var submitHandler: ((GovDetailViewController?) -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 64
        
        load()
    }
    
    func load() {
        
        guard let user = Repository.sharedInstance.user
            else {
                print("Failed to get user object")
                return
        }
        
        let parameters = "<token>\(user.token)</token>"
            + "<govId>\(itemId!)</govId>"
        
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
                
                if (!self.item!.approvalAuthorized) {
                    self.navigationItem.rightBarButtonItem = nil
                }
                
                self.tableView.reloadData()
            }
        }
        
        task.resume()
    }
    
    @IBAction func review(_ sender: Any) {
        let reviewVC = self.storyboard?.instantiateViewController(withIdentifier: "govReviewController") as! GovReviewViewController
        
        reviewVC.flow = item
        
        reviewVC.submitHandler = {
            (controller) in
            
            print("Gonna dismiss Review controller")
            
            let words = controller?.wordsTextView.text
            
            if let button = controller?.reviewButton.selectedButtons()[0] {
                
                switch button.tag {
                case 0:
                    self.sumbit(reviewWords: words!)
                case 2:
                    self.finalize(reviewWords: words!)
                default:
                    self.sumbit(reviewWords: words!)
                }
                
                controller?.dismiss(animated: true, completion: nil)
            }
        }
        
        //        print("Remark in item: \(self.item?.remark)")
        
        self.present(reviewVC, animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showGovAttachment" {
            
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
            return 1
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
        
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AttachmentCell", for: indexPath)
            
            let item = attachments[indexPath.row]
            
            cell.textLabel?.text = item.fileName
            
            return cell
        }
        else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StepCell", for: indexPath)
            
            let item = steps[indexPath.row]
            
            cell.textLabel?.text = item.stepName
            cell.detailTextLabel?.text = item.description
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GovHeaderCell", for: indexPath) as! GovHeaderCell
            
            cell.flowNameLabel.text = self.item?.flowName
            cell.depNameLabel.text = self.item?.depName
            cell.creatorLabel.text = self.item?.creator
            cell.createDateLabel.text = self.item?.createTime
            
//            cell.remarkLabel.text = self.item?.remark
            cell.remarkLabel.attributedText = HtmlHelper.stringFromHtml(string: self.item?.remark)
            
            return cell
        }
    }
    

    func sumbit(reviewWords: String) {
        
        guard let user = Repository.sharedInstance.user
            else {
                print("Failed to get user object")
                return
        }
        
        let parameters = "<token>\(user.token)</token>"
            + "<id>\(self.item!.id)</id>"
            + "<words>\(reviewWords)</words>"
            + "<depName>\(self.item!.depName)</depName>"
            + "<currentDocPath>\(self.item!.currentDocPath)</currentDocPath>"
            + "<flowFiles>\(self.item!.flowFiles)</flowFiles>"
        
        let request = SoapHelper.getURLRequest(method: soapMethodAgreed, parameters: parameters)
        
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
                
                if let result = self.reviewResult {
                    if result.result != 1 {
                        let controller = UIAlertController(
                            title: "操作失败，稍后请重试。如果问题依然存在，请联系管理员。",
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
            }
        }
        
        task.resume()
    }
    
    func finalize(reviewWords: String) {
        
        guard let user = Repository.sharedInstance.user
            else {
                print("Failed to get user object")
                return
        }
        
        let parameters = "<token>\(user.token)</token>"
            + "<id>\(self.item!.id)</id>"
            + "<words>\(reviewWords)</words>"
            + "<depName>\(self.item!.depName)</depName>"
            + "<currentDocPath>\(self.item!.currentDocPath)</currentDocPath>"
            + "<flowFiles>\(self.item!.flowFiles)</flowFiles>"
        
        let request = SoapHelper.getURLRequest(method: soapMethodFinalized, parameters: parameters)
        
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
                
                if let result = self.reviewResult {
                    if result.result != 1 {
                        let controller = UIAlertController(
                            title: "操作失败，稍后请重试。如果问题依然存在，请联系管理员。",
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
            }
        }
        
        task.resume()
    }
    

    // MARK: - XML Parser
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "\(soapMethod)Result"
            || elementName == "\(soapMethodAgreed)Result"
            || elementName == "\(soapMethodFinalized)Result"
        {
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
            
            guard let resultObject = ResponseResultList<Gov>(json: result!) else {
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
        else if elementName == "\(soapMethodAgreed)Result" {
            print(elementValue ?? "Not got any data from ws.")
            
            let result = convertStringToDictionary(text: elementValue!)
            print(result ?? "Not got any data from ws.")
            
            guard let resultObject = ResponseBase(json: result!) else {
                print("DECODING FAILURE :(")
                return
            }
            
            self.reviewResult = resultObject
            
            elementValue = nil;
        }
        else if elementName == "\(soapMethodFinalized)Result" {
            print(elementValue ?? "Not got any data from ws.")
            
            let result = convertStringToDictionary(text: elementValue!)
            print(result ?? "Not got any data from ws.")
            
            guard let resultObject = ResponseBase(json: result!) else {
                print("DECODING FAILURE :(")
                return
            }
            
            self.reviewResult = resultObject
            
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
