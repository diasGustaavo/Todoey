//
//  ViewController.swift
//  Todoey
//
//  Created by Gustavo Dias on 27/12/22.
//

import UIKit
import RealmSwift
import RandomColor
import UIColorHexSwift

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
                        newItem.dateCreated = Date()
                        let colourPercentage = 10 * (self.todoItems?.count ?? 0)
                        newItem.colour = UIColor(self.selectedCategory?.colour ?? "#FFF").toColor(color: UIColor.black, percentage: CGFloat(colourPercentage)).hexString()
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
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    func deleteItem(row: Int) {
        if let item = todoItems?[row] {
            do {
                try realm.write {
                    //                    delete item when clicked
                    realm.delete(item)
                }
            } catch {
                print("error deleting item, \(error)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = selectedCategory?.name
        
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = search
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.scrollEdgeAppearance?.backgroundColor = UIColor(selectedCategory?.colour ?? "#FFF")
        self.navigationController?.navigationBar.standardAppearance.backgroundColor = UIColor(selectedCategory?.colour ?? "#FFF")
        self.title = selectedCategory?.name
    }
}

//MARK: - UITableViewDelegate

extension TodoListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CustomTableViewCell.identifier,
            for: indexPath
        ) as! CustomTableViewCell
        
        if let item = todoItems?[indexPath.row] {
            cell.content = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            cell.backgroundColor = UIColor(todoItems?[indexPath.row].colour ?? "#FFF")
            
            var colourPercentage = (10 * indexPath.row) + 25
            if colourPercentage >= 60 && colourPercentage <= 70 {
                colourPercentage = 80
            }
            let selectedCatColour = UIColor(selectedCategory?.colour ?? "#FFF")
            cell.textColor = UIColor(.black).toColor(color: selectedCatColour, percentage: CGFloat(colourPercentage))
        } else {
            cell.content = "No items added"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    //                    select/deselect item when clicked
                    item.done = !item.done
                }
            } catch {
                print("error saving done status, \(error)")
            }
        }
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            self?.deleteItem(row: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.bottom)
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
}

//MARK: - UISearchResultsUpdating

extension TodoListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text {
            if text.count > 0 {
                todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchController.searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: false)
                tableView.reloadData()
            } else {
                loadItems()
            }
        } else {
            loadItems()
        }
    }
}

//MARK: - UIColor

extension UIColor {
    func toColor(color: UIColor, percentage: CGFloat) -> UIColor {
        let percentage = max(min(percentage, 100), 0) / 100
        switch percentage {
        case 0: return self
        case 1: return color
        default:
            var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            guard self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1) else { return self }
            guard color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2) else { return self }
            
            return UIColor(red: CGFloat(r1 + (r2 - r1) * percentage),
                           green: CGFloat(g1 + (g2 - g1) * percentage),
                           blue: CGFloat(b1 + (b2 - b1) * percentage),
                           alpha: CGFloat(a1 + (a2 - a1) * percentage))
        }
    }
    
    var isDarkColor: Bool {
        var r, g, b, a: CGFloat
        (r, g, b, a) = (0, 0, 0, 0)
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        let lum = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return  lum < 0.50
    }
}
