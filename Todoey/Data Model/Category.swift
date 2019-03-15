//
//  Category.swift
//  Todoey
//
//  Created by Prince Thomas on 13/3/19.
//  Copyright © 2019 Prince Thomas. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    @objc dynamic var name : String = ""
    let items = List<Item>()
}
