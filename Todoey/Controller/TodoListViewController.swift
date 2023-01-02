//
//  ViewController.swift
//  Todoey
//
//  Created by Gustavo Dias on 27/12/22.
//

import UIKit
import RealmSwift

class TodoListViewController: UIViewController {
    let realm = try! Realm()
    let search = UISearchController()
    var todoItems: Results<Todo>?
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.identifier)
        return table
    }()
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write{
                        let newItem = Todo()
                        newItem.title = textField.text!
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving context \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = search
    }
}

//MARK: - UITableViewDelegate

extension TodoListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CustomTableViewCell.identifier,
            for: indexPath
        ) as! CustomTableViewCell
        
        if let item = todoItems?[indexPath.row] {
            cell.content = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.content = "No items added"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
//                    delete item when clicked
//                    realm.delete(item)
                    
//                    select/deselect item when clicked
                    item.done = !item.done
                }
            } catch {
                print("error saving done status, \(error)")
            }
        }
        
        tableView.reloadData()
    }
}

//MARK: - UISearchResultsUpdating

extension TodoListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text {
            if text.count > 0 {
                todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchController.searchBar.text!).sorted(byKeyPath: "title", ascending: true)
                tableView.reloadData()
            } else {
                loadItems()
            }
        } else {
            loadItems()
        }
    }
}
