//
//  Item.swift
//  Todoey
//
//  Created by Gustavo Dias on 29/12/22.
//

import UIKit
import RealmSwift

class Todo: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    @objc dynamic var colour: String?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
