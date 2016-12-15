//
//  GovReviewViewController.swift
//  PerkingOpera
//
//  Created by admin on 12/16/16.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import UIKit
import DLRadioButton
import Gloss

class GovReviewViewController: UIViewController, XMLParserDelegate {
    
    @IBOutlet var reviewButton: DLRadioButton!
    
    @IBOutlet weak var cancel: UIButton!
    
    @IBOutlet weak var wordsTextView: UITextView!
    
    var submitHandler: ((GovReviewViewController?) -> Void)?
    
    var flow: Gov?
    
    private let soapMethod = "GetMissedGovReviwer"
    private let soapUpdateMethod = "UpdateGovReviewer"
    
    private var elementValue: String?
    
    private var list = [Employee]()
    
    private var managerId: Int?
    
    private var updateResul: ResponseBase?
    
    // MARK: - View events
    
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
    
    
    // MARK: - Actions
    
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
        
        for button in self.reviewButton.selectedButtons() {
            if button.tag == 0 {
                checkReviewers()
            }
            else {
                self.submitHandler!(self)
            }
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Web service
    
    func checkReviewers() {
        
        guard let user = Repository.sharedInstance.user
            else {
                print("Failed to get user object")
                return
        }
        
        let parameters = "<token>\(user.token)</token>"
            + "<flowId>\(self.flow!.id)</flowId>"
        
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
                if self.list.count == 0 {
                    self.submitHandler!(self)
                }
                else {
                    let managerVC = self.storyboard?.instantiateViewController(withIdentifier: "managerController") as! ManagerViewController
                    
                    managerVC.list = self.list
                    
                    managerVC.submitHandler = {
                        (controller) in
                        
                        print("Gonna dismiss Gov Review controller")
                        
                        self.managerId = controller?.selectedManagerId
                        
                        controller?.dismiss(animated: true, completion: nil)
                        
                        self.updateReviewer()
                    }
                    
                    self.present(managerVC, animated: true, completion: nil)
                }
            }
        }
        
        task.resume()
    }
    
    func updateReviewer() {
        
        guard let user = Repository.sharedInstance.user
            else {
                print("Failed to get user object")
                return
        }
        
        let parameters = "<token>\(user.token)</token>"
            + "<flowId>\(self.flow!.id)</flowId>"
            + "<staffId>\(self.managerId!)</staffId>"
        
        let request = SoapHelper.getURLRequest(method: soapUpdateMethod, parameters: parameters)
        
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
                if let result = self.updateResul {
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
        if elementName == "\(soapMethod)Result" || elementName == "\(soapUpdateMethod)Result" {
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
            
            guard let resultObject = ResponseResultList<Employee>(json: result!) else {
                print("DECODING FAILURE :(")
                return
            }
            
            self.list = resultObject.list
            
            elementValue = nil;
        }
        else if elementName == "\(soapUpdateMethod)Result" {
            print(elementValue ?? "Not got any data from ws.")
            
            let result = convertStringToDictionary(text: elementValue!)
            print(result ?? "Not got any data from ws.")
            
            guard let resultObject = ResponseBase(json: result!) else {
                print("DECODING FAILURE :(")
                return
            }
            
            self.updateResul = resultObject
            
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
