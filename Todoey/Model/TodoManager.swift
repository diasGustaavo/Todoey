//
//  TodoManager.swift
//  Todoey
//
//  Created by Gustavo Dias on 04/01/23.
//

import UIKit
import RealmSwift

struct TodoManager {
    let realm = try! Realm()
    var todoItems: Results<Todo>?
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    func getItemsCounter() -> Int {
        return todoItems?.count ?? 1
    }
    
    mutating func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
    }
    
    func saveItem(title: String){
        do {
            try self.realm.write{
                let newItem = Todo()
                newItem.title = title
                newItem.dateCreated = Date()
                let colourPercentage = 10 * (self.todoItems?.count ?? 0)
                newItem.backgroundColour = UIColor(self.selectedCategory?.colour ?? "#FFF").toColor(color: UIColor.black, percentage: CGFloat(colourPercentage)).hexString()
                newItem.textColour = getNewItemTextColour(indexRow: self.todoItems!.count)
                selectedCategory?.items.append(newItem)
            }
        } catch {
            print("Error saving context \(error)")
        }
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
    
    func getItemBackgroundColour(indexRow: Int) -> UIColor {
        return UIColor(todoItems?[indexRow].backgroundColour ?? "#FFF")
    }
    
    func getItemTextColour(indexRow: Int) -> UIColor {
        return UIColor(todoItems?[indexRow].textColour ?? "#FFF")
    }
    
    func getNewItemTextColour(indexRow: Int) -> String {
        var colourPercentage = (10 * indexRow) + 25
        if colourPercentage >= 60 && colourPercentage <= 70 {
            colourPercentage = 80
        }
        let selectedCatColour = UIColor(selectedCategory?.colour ?? "#FFF")
        return UIColor(.black).toColor(color: selectedCatColour, percentage: CGFloat(colourPercentage)).hexString()
    }
    
    func selectedItem(indexRow: Int) {
        if let item = todoItems?[indexRow] {
            do {
                try realm.write {
                    //                    select/deselect item when clicked
                    item.done = !item.done
                }
            } catch {
                print("error saving done status, \(error)")
            }
        }
    }
    
    mutating func filterItems(with text: String) {
        if text.count > 0 {
            todoItems = todoItems?.filter("title CONTAINS[cd] %@", text).sorted(byKeyPath: "dateCreated", ascending: false)
        } else {
            self.loadItems()
        }
    }
}
