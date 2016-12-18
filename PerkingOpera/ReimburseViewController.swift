//
//  ReimburseViewController.swift
//  PerkingOpera
//
//  Created by admin on 12/17/16.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import UIKit
import Gloss
import Alamofire
import DLRadioButton
import DropDown

class ReimburseViewController: UIViewController, XMLParserDelegate, UINavigationControllerDelegate,  UIImagePickerControllerDelegate {
    
    @IBOutlet weak var formNameTextField: UITextField!
    
    @IBOutlet weak var remarkTextField: UITextField!

    @IBOutlet weak var amountTextField: UITextField!

    @IBOutlet weak var docBodyTextView: UITextView!
    
    @IBOutlet weak var Pic1ImageView: UIImageView!
    
    @IBOutlet weak var Pic2ImageView: UIImageView!
    
    @IBOutlet weak var Pic3ImageView: UIImageView!
    
    @IBOutlet var paymentTermButton: DLRadioButton!
    
    @IBOutlet weak var itemButton: DropDownButton!
    
    let itemDropDown = DropDown()
    
    private let soapMethod = "GetBudgetItems"
    private let soapMethodSubmit = "SaveFlow"
    
    var elementValue: String?
    
    private var budgetItems: [String]?
    
    private let modelName = "报销申请"
    
    private let flowFilePrefix = "~/Files/FlowFiles/Mobile/"
    
    // Format: "?|?|"
    private var flowFiles = "?|?|"

    private var saveResult: ResponseBase?
    
    
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadBudgetItems()
        
        setupItemDropDown()

        registerDismissKeyboardEvent()
    }
    
    func loadBudgetItems() {
        guard let user = Repository.sharedInstance.user
            else {
                print("Failed to get user object")
                return
        }
        
        let parameters = "<token>\(user.token)</token>"
            + "<depId>\(user.depId)</depId>"
        
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
                
                if let items = self.budgetItems {
                    // You can also use localizationKeysDataSource instead. Check the docs.
                    self.itemDropDown.dataSource = items
                }
            }
        }
        
        task.resume()
    }
    
    func setupItemDropDown() {
        
        itemDropDown.bottomOffset = CGPoint(x: 0, y: itemButton.bounds.height)
        
        // Action triggered on selection
        itemDropDown.selectionAction = { [unowned self] (index, item) in
            self.itemButton.setTitle(item, for: .normal)
        }
        
        itemDropDown.dismissMode = .onTap
        itemDropDown.direction = .any
    }

    // Dismiss keyboard when user click anyplace else
    func registerDismissKeyboardEvent() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    
    // MARK: - Actions

    @IBAction func pickItem(_ sender: Any) {
        
        if self.budgetItems != nil && self.budgetItems!.count > 0 {
            itemDropDown.show()
        }
    }
    
    @IBAction func submit(_ sender: Any) {
        
//        if !isValidated() {
//            return
//        }
        
        update()
    }
    
    func isValidated() -> Bool {
        
        if self.formNameTextField.text == "" {
            alert("请输入名称")
            
            return false
        }
        
        if self.remarkTextField.text == "" {
            alert("请输入摘要")
            
            return false
        }
        
        if self.amountTextField.text == "" {
            alert("请输入金额")
            
            return false
        }
        
        if self.itemDropDown.selectedItem == nil {
            alert("请选择报销项目")
            
            return false
        }
        
        if self.paymentTermButton.selectedButtons().count == 0 {
            alert("请选择付款方式")
            
            return false
        }
        
        return true
    }
    
    func alert(_ string: String) {
        
        let controller = UIAlertController(
            title: string,
            message: "", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(
            title: "Ok",
            style: .cancel, handler: nil)
        
        controller.addAction(cancelAction)
        
        self.present(controller, animated: true, completion: nil)
    }
    
    func update() {
        
        uploadImage1()
        
    }
    
    func uploadImage1() {
        
        self.flowFiles = ""
        
        if let image1 = self.Pic1ImageView.image, let base64String = UIImagePNGRepresentation(image1)?.base64EncodedString() {
            
            let fileName = "\(NSUUID().uuidString).png"
            flowFiles += "\(self.flowFilePrefix)\(fileName)|"
            
            print("Uploading file \(self.flowFiles)")
            
            // Upload to server
            let parameters  = [
                "FileName": fileName,
                "image_data": base64String
            ]
            
            Alamofire.request(SoapHelper.uploadUrl, method: .post, parameters: parameters)
                .responseData(completionHandler: { (response) in
                    switch response.result {
                    case .success:
                        self.uploadImage2()
                    case .failure(let error):
                        print("Uploading failed: \(error)")
                    }
                })
        }
        else {
            self.uploadRequest()
        }
    }
    
    func uploadImage2() {
        
        if let image2 = self.Pic2ImageView.image, let base64String = UIImagePNGRepresentation(image2)?.base64EncodedString() {
            
            let fileName = "\(NSUUID().uuidString).png"
            flowFiles += "\(self.flowFilePrefix)\(fileName)|"
            
            print("Uploading file \(self.flowFiles)")
            
            // Upload to server
            let parameters  = [
                "FileName": fileName,
                "image_data": base64String
            ]
            
            Alamofire.request(SoapHelper.uploadUrl, method: .post, parameters: parameters)
                .responseData(completionHandler: { (response) in
                    switch response.result {
                    case .success:
                        self.uploadImage3()
                    case .failure(let error):
                        print("Uploading failed: \(error)")
                    }
                    
                })
        }
        else {
            self.uploadRequest()
        }
    }

    func uploadImage3() {
        
        if let image3 = self.Pic3ImageView.image, let base64String = UIImagePNGRepresentation(image3)?.base64EncodedString() {
            
            let fileName = "\(NSUUID().uuidString).png"
            flowFiles += "\(self.flowFilePrefix)\(fileName)|"
            
            print("Uploading file \(self.flowFiles)")
            
            // Upload to server
            let parameters  = [
                "FileName": fileName,
                "image_data": base64String
            ]
            
            Alamofire.request(SoapHelper.uploadUrl, method: .post, parameters: parameters)
                .responseData(completionHandler: { (response) in
                    switch response.result {
                    case .success:
                        self.uploadRequest()
                    case .failure(let error):
                        print("Uploading failed: \(error)")
                    }
                    
                })
        }
        else {
            self.uploadRequest()
        }
    }
    
    func uploadRequest() {
        
        guard let user = Repository.sharedInstance.user
            else {
                print("Failed to get user object")
                return
        }
        
        let parameters = "<token>\(user.token)</token>"
            + "<modelName>\(self.modelName)</modelName>"
            + "<id>0</id>"
            + "<userId>\(user.userId)</userId>"
            + "<creatorRealName>\(user.realName!)</creatorRealName>"
            + "<creatorDepName>\(user.depName!)</creatorDepName>"
            + "<flowName>\(self.formNameTextField.text!)</flowName>"
            + "<docBody>\(self.docBodyTextView.text!)</docBody>"
            + "<remark>\(self.remarkTextField.text!)</remark>"
            + "<flowFiles>\(self.flowFiles)</flowFiles>"
            + "<amount>\(self.amountTextField.text!)</amount>"
            + "<projectId>\(user.depId)</projectId>"
            + "<budgetItemName>\(self.itemDropDown.selectedItem!)</budgetItemName>"
            + "<paymentMethod>\(self.paymentTermButton.selected()!.titleLabel!.text!)</paymentMethod>"
        
        let request = SoapHelper.getURLRequest(method: soapMethodSubmit, parameters: parameters)
        
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
                
                if let result = self.saveResult {
                    if result.result != 1 {
                        self.alert("操作失败，稍后请重试。如果问题依然存在，请联系管理员。")
                        
                        return
                    }
                    
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
        task.resume()
    }
    
    @IBAction func takePicture(_ sender: UIBarButtonItem) {

        let imagePicker = UIImagePickerController()
        
        // If the device has a camera, take a picture, otherwise,
        // just pick from photo library
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        }
        else {
            imagePicker.sourceType = .photoLibrary
        }
        
        imagePicker.delegate = self
        
        // Place image picker on the screen
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String: Any]) {
        
        // Get picked image from info dictionary
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Put that image onto the screen in our image view
        if Pic1ImageView.image == nil {
            Pic1ImageView.image = image
        }
        else if Pic2ImageView.image == nil {
            Pic2ImageView.image = image
        }
        else {
            Pic3ImageView.image = image
        }
        
        // Take image picker off the screen -
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - XML Parser
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "\(soapMethod)Result" || elementName == "\(soapMethodSubmit)Result" {
            elementValue = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        elementValue? += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "\(soapMethod)Result" {
            let result = convertStringToDictionary(text: elementValue!)
            print(result ?? "Not got any data from ws.")
            
            guard let resultObject = ResponseResultList<BudgetItem>(json: result!) else {
                print("DECODING FAILURE :(")
                return
            }
            
            self.budgetItems = [String]()
            
            for item in resultObject.list {
                self.budgetItems!.append(item.itemName)
            }
            
            elementValue = nil;
        }
        else if elementName == "\(soapMethodSubmit)Result" {
            let result = convertStringToDictionary(text: elementValue!)
            print(result ?? "Not got any data from ws.")
            
            guard let resultObject = ResponseBase(json: result!) else {
                print("DECODING FAILURE :(")
                return
            }
            
            self.saveResult = resultObject
           
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
