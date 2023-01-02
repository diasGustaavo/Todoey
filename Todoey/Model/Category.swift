//
//  Category.swift
//  Todoey
//
//  Created by Gustavo Dias on 29/12/22.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Todo>()
}
