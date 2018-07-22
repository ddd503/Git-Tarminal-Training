//
//  MemoDataDao.swift
//  Git-Tarminal-Training
//
//  Created by kawaharadai on 2018/07/16.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import RealmSwift
import Foundation

protocol MemoDataDaoDelegate {
    func result(type: ActionType, error: Error?)
}

enum ActionType {
    case add
    case update
    case delete
    case deleteAll
}

final class MemoDataDao {
    
    // ジェネリクスにMemoを指定
    static let daoHelper = RealmDaoHelper<Memo>()
    
    // プロトコルプロパティを用意
    static var memoDataDaoDelegate: MemoDataDaoDelegate?
    
    // 1件取得
    static func selectID(memoId: Int) -> Memo? {
        guard let object = daoHelper.findFirst(key: memoId as AnyObject) else { return nil }
        return Memo(value: object)
    }
    
    // 全件取得
    static func selectObjects() -> [Memo] {
        let objects =  daoHelper.findAll().sorted(byKeyPath: "updateDate", ascending: false)
        return objects.map { Memo(value: $0) }
    }
    
    // 新規作成
    static func add(memoText: String) {
        let newObject = Memo()
        if let newId = daoHelper.newId() {
            newObject.memoId = newId
        }
        newObject.updateDate = Date()
        newObject.memoText = memoText
       
        MemoDataDao.memoDataDaoDelegate?.result(type: .add, error: daoHelper.add(d: newObject))
    }
    
    // 更新
    static func update(model: Memo) {
        MemoDataDao.memoDataDaoDelegate?.result(type: .update, error: daoHelper.update(d: model, block: nil))
    }
    
    // 削除
    static func delete(model: Memo) {
        // これいる？？
        guard let deleteObject = daoHelper.findFirst(key: model.memoId as AnyObject) else { return }
        MemoDataDao.memoDataDaoDelegate?.result(type: .delete, error: daoHelper.delete(d: deleteObject))
    }
    
    // 全削除
    static func deleteAll() {
        MemoDataDao.memoDataDaoDelegate?.result(type: .deleteAll, error: daoHelper.deleteAll())
    }
}
