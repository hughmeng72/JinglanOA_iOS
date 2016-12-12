//
//  LoginViewController.swift
//  PerkingOpera
//
//  Created by admin on 28/11/2016.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import Gloss
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, XMLParserDelegate {

    private let soapMethod = "GetTokenByUserNameAndPassword"
    
    var elementValue: String?
    
    @IBOutlet weak var UserName: UITextField!
    
    @IBOutlet weak var Password: UITextField!
    
    @IBOutlet weak var savePassword: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadAccountInfo()
        
        registerDismissKeyboardEvent()

        self.UserName.delegate = self
        self.Password.delegate = self

        if self.UserName.text == "" {
            UserName.becomeFirstResponder()
        }
    }
    
    func loadAccountInfo() {
        
        let passwordSaved = UserDefaults.standard.bool(forKey: "SavePassword")
        self.savePassword.isOn = passwordSaved
        
        if passwordSaved {
            self.UserName.text = UserDefaults.standard.string(forKey: "UserName")
            self.Password.text = UserDefaults.standard.string(forKey: "Password")
        }
    }
    
    // Dismiss keyboard when user click anyplace else
    func registerDismissKeyboardEvent() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == UserName {
            Password.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    @IBAction func Login(_ sender: Any) {
        
        let userName = UserName.text!
        let password = Password.text!
        
        let parameters = "<userName>\(userName)</userName>"
            + "<password>\(password)</password>"
       
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
                if let user = Repository.sharedInstance.user, user.error.result == 1 {
                    UserDefaults.standard.set(self.savePassword.isOn, forKey: "SavePassword")
                    
                    if self.savePassword.isOn {
                        UserDefaults.standard.set(self.UserName.text, forKey: "UserName")
                        UserDefaults.standard.set(self.Password.text, forKey: "Password")
                    }
                    else {
                        UserDefaults.standard.set("", forKey: "UserName")
                        UserDefaults.standard.set("", forKey: "Password")
                    }
                    
                    UserDefaults.standard.synchronize()
                    
                    self.performSegue(withIdentifier: "showMain", sender: nil)
                }
                else {
                        UserDefaults.standard.set("", forKey: "UserName")
                        UserDefaults.standard.set("", forKey: "Password")
                        UserDefaults.standard.synchronize()
                    
                    let controller = UIAlertController(
                            title: "用户名或密码错误",
                            message: "", preferredStyle: .alert)
                        
                        let cancelAction = UIAlertAction(
                            title: "Ok",
                            style: .cancel, handler: nil)
                        
                        controller.addAction(cancelAction)
                        
                        self.present(controller, animated: true, completion: nil)
                        
                        return
                }
            }
        }
        
        task.resume()
    }
    
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
           
            guard let user = User(json: result!) else {
                print("DECODING FAILURE :(")
                return
            }
            
            Repository.sharedInstance.user = user;
            
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
