//
//  ManagerViewController.swift
//  PerkingOpera
//
//  Created by admin on 12/15/16.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import UIKit

class ManagerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var submitHandler: ((ManagerViewController?) -> Void)?
    
    var list = [Employee]()

    var selectedManagerId: Int?

    
    // MARK: - Actions
    
    @IBAction func ok(_ sender: Any) {
        
        if let index = self.list.index(where: {
            (item) -> Bool in
            item.selected
        }) {
            self.selectedManagerId = self.list[index].id
            
            self.submitHandler!(self)
        }
        
        let controller = UIAlertController(
            title: "请选择分管领导",
            message: "", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(
            title: "Ok",
            style: .cancel, handler: nil)
        
        controller.addAction(cancelAction)
        
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - View events
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableCell", for: indexPath)
        
        let item = list[indexPath.row]
        
        cell.textLabel?.text = item.realName
        
        setFlag(cell, item: item)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
//            var item = list[indexPath.row]
            
            list[indexPath.row].selected = !list[indexPath.row].selected
            
            setFlag(cell, item: list[indexPath.row])
        }
    }
    
    func setFlag (_ cell: UITableViewCell, item: Employee) {
        
        if item.selected {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
    }
    
    func resetFlags() {
        for i in (0 ..< tableView.numberOfSections) {
            for j in (0 ..< tableView.numberOfRows(inSection: i)) {
                if let cell = tableView.cellForRow(at: IndexPath(row: j, section: i)) {
                    var item = list[j]
                    
                    item.selected = false
                    cell.accessoryType = .none
                }
            }
        }
    }
}
