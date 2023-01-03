//
//  Category.swift
//  Todoey
//
//  Created by Gustavo Dias on 29/12/22.
//

import RealmSwift
import UIKit

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colour: String?
    let items = List<Todo>()
}
