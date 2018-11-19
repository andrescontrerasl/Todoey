//
//  Category.swift
//  Todoey
//
//  Created by Andres Contreras on 14/11/18.
//  Copyright © 2018 Andres Contreras. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
}
