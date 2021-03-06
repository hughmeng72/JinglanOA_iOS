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
    
    weak var activityIndicatorView: UIActivityIndicatorView!
    
    var itemId: Int!
    
    private let soapMethod = "GetFlowDetail"
    private let soapMethodAgreed = "SubmitFlowRequest"
    private let soapMethodDisagreed = "RejectFlowRequest"
    private let soapMethodFinalized = "FinalizeFlowRequest"
    
    private var elementValue: String?
    
    private var item: Flow?
    
    private var steps = [FlowStep]()
    
    private var attachments = [FlowDoc]()
    
    private var reviewResult: ResponseBase?

    var submitHandler: ((FlowDetailViewController?) -> Void)?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 48
        
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        tableView.backgroundView = activityIndicatorView
        
        self.activityIndicatorView = activityIndicatorView
    }

    @IBAction func review(_ sender: Any) {

        let reviewVC = self.storyboard?.instantiateViewController(withIdentifier: "reviewController") as! ReviewViewController
        
        reviewVC.flow = item
        
        reviewVC.submitHandler = {
            (controller) in
            
            print("Gonna dismiss Review controller")
            
            let words = controller?.wordsTextView.text
            
            if let button = controller?.reviewButton.selectedButtons()[0] {

                switch button.tag {
                case 0:
                    self.sumbit(reviewWords: words!)
                case 1:
                    self.reject(reviewWords: words!)
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

                if item.budgetInvolved && item.budgetAuthorized && item.modelName != "采购申请" {
                    cell.budgetStackView.isHidden = false
                    
                    cell.itemNameLabel.text = item.itemName
                    cell.projectNameLabel.text = item.projectName
                    cell.totalAmountLabel.text = "\(item.totalAmount)"
                    cell.amountLeftLabel.text = "\(item.amountLeft)"
                    cell.amountBeingPaidProcurementLabel.text = "\(item.amountToBePaidProcurement)"
                    cell.amountPaidProcurementLabel.text = "\(item.amountPaidProcurement)"
                    cell.amountBeingPaidReimbursementLabel.text = "\(item.amountToBePaidReimbursement)"
                    cell.amountPaidReimbursementLabel.text = "\(item.amountPaidReimbursement)"
                }
                else {
                    cell.budgetStackView.isHidden = true
                }
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

    // MARK: - Load Flow detail information
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.item == nil {
            load()
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

                self.activityIndicatorView.stopAnimating()
                
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
            + "<docBody>\(self.item!.docBody)</docBody>"
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
    
    func reject(reviewWords: String) {
        
        guard let user = Repository.sharedInstance.user
            else {
                print("Failed to get user object")
                return
        }
        
        let parameters = "<token>\(user.token)</token>"
            + "<id>\(self.item!.id)</id>"
            + "<words>\(reviewWords)</words>"
            + "<depName>\(self.item!.depName)</depName>"
            + "<docBody>\(self.item!.docBody)</docBody>"
            + "<currentDocPath>\(self.item!.currentDocPath)</currentDocPath>"
            + "<flowFiles>\(self.item!.flowFiles)</flowFiles>"
        
        let request = SoapHelper.getURLRequest(method: soapMethodDisagreed, parameters: parameters)
        
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
            + "<docBody>\(self.item!.docBody)</docBody>"
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
    
    
    // MARK: - XML Parser for Flow Detail
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "\(soapMethod)Result"
            || elementName == "\(soapMethodAgreed)Result"
            || elementName == "\(soapMethodDisagreed)Result"
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
        else if elementName == "\(soapMethodDisagreed)Result" {
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
