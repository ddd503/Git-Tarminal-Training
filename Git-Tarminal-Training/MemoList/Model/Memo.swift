//
//  Memo.swift
//  Git-Tarminal-Training
//
//  Created by kawaharadai on 2018/07/16.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import Foundation
import RealmSwift

final class Memo: Object {
    @objc dynamic var memoId = 0
    @objc dynamic var updateDate = Date()
    @objc dynamic var title = ""
    @objc dynamic var content = ""

    override static func primaryKey() -> String? {
        return "memoId"
    }
}
