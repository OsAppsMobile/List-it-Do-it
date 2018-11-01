//
//  DoModel.swift
//  List it Do it
//
//  Created by Osman Dönmez on 1.11.2018.
//  Copyright © 2018 Osman Dönmez. All rights reserved.
//

import Foundation
import RealmSwift

class DoModel: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var currentDate = Date()
    var parentCategory = LinkingObjects(fromType: ListModel.self, property: "doItems")
}
