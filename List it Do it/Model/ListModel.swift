//
//  ListModel.swift
//  List it Do it
//
//  Created by Osman Dönmez on 1.11.2018.
//  Copyright © 2018 Osman Dönmez. All rights reserved.
//

import Foundation
import RealmSwift

class ListModel: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var backgroundColor: String = ""
    let doItems = List<DoModel>()
}
