//
//  CategoryFile.swift
//  Todoey
//
//  Created by Gustavo Dias on 04/01/23.
//

import UIKit
import RealmSwift
import RandomColor

struct CategoryManager {
    let realm = try! Realm()
    var categories: Results<Category>?
    
    func getCategoriesCounter() -> Int {
        return categories?.count ?? 1
    }
    
    func getCategoryName(index: Int) -> String {
        return categories?[index].name ?? "No category registred"
    }
    
    func getCategoryColour(index: Int) -> UIColor {
        return UIColor(categories?[index].colour ?? "#FFF")
    }
    
    mutating func loadCategories() {
        categories = realm.objects(Category.self)
    }
    
    func addCategory(title: String) {
        let newCategory = Category()
        newCategory.name = title
        newCategory.colour = self.generateRandomHEXColor()
        
        self.save(category: newCategory)
    }
    
    func generateRandomHEXColor() -> String {
        return randomColor(hue: .random, luminosity: .light).hexString()
    }
    
    func getNewNavColour() -> UIColor {
        return UIColor(self.categories?[(self.categories?.count ?? 1) - 1 ].colour ?? "#FFF")
    }
    
    func save(category: Category) {
        do {
            try realm.write{
                realm.add(category)
            }
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    func deleteCategory(row: Int) {
        if let cat = categories?[row] {
            do {
                try realm.write {
//                    delete item when clicked
                    realm.delete(cat)
                }
            } catch {
                print("error deleting item, \(error)")
            }
        }
    }
}
