//
//  ViewController.swift
//  Todoey
//
//  Created by Gustavo Dias on 27/12/22.
//

import UIKit

class ViewController: UIViewController {
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.identifier)
        return table
    }()
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            self.itemArray.append(Todo(description: textField.text!, done: false))
            
            self.defaults.set(self.itemArray, forKey: "TodoListArray")
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    var itemArray = [Todo(description: "Find mike", done: false), Todo(description: "Buy eggos", done: false), Todo(description: "Destroy Demogorgon", done: false), Todo(description: "A", done: false), Todo(description: "B", done: false), Todo(description: "C", done: false), Todo(description: "D", done: false), Todo(description: "E", done: false), Todo(description: "F", done: false), Todo(description: "G", done: false), Todo(description: "H", done: false), Todo(description: "I", done: false), Todo(description: "J", done: false), Todo(description: "K", done: false), Todo(description: "L", done: false), Todo(description: "M", done: false), Todo(description: "N", done: false), Todo(description: "X", done: false), Todo(description: "Y", done: false), Todo(description: "Z", done: false)]
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        
        if let items = defaults.array(forKey: "TodoListArray") as? [Todo] {
            itemArray = items
        }
    }
}

//MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CustomTableViewCell.identifier,
            for: indexPath
        ) as! CustomTableViewCell
        
        cell.content = itemArray[indexPath.row].description
        
        if itemArray[indexPath.row].done == true {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(itemArray[indexPath.row])
        
        if itemArray[indexPath.row].done == true {
            itemArray[indexPath.row].done = false
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            itemArray[indexPath.row].done = true
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
