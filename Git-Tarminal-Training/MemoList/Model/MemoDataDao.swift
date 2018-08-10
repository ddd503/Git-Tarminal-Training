//
//  MemoDataDao.swift
//  Git-Tarminal-Training
//
//  Created by kawaharadai on 2018/07/16.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import RealmSwift
import Foundation

protocol MemoDataDaoDelegate: class {
    func result(type: ActionType, error: Error?)
}

enum ActionType {
    case add
    case update
    case delete
    case deleteAll
    case none
}

final class MemoDataDao {
    
    // ジェネリクスにMemoを指定
    static let daoHelper = RealmDaoHelper<Memo>()
    
    // プロトコルプロパティを用意
    static weak var memoDataDaoDelegate: MemoDataDaoDelegate?
    
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
    static func add(newObject: Memo) {
        if let newId = daoHelper.newId() {
            newObject.memoId = newId
        }
        MemoDataDao.memoDataDaoDelegate?.result(type: .add, error: daoHelper.add(d: newObject))
    }
    
    // 更新
    static func update(model: Memo) {
        MemoDataDao.memoDataDaoDelegate?.result(type: .update, error: daoHelper.update(d: model, block: nil))
    }
    
    // 削除
    static func delete(model: Memo) {
        // 一度フェッチした上でデリートを行わないとクラッシュする（reason: 'Can only delete an object from the Realm it belongs to.'）
        guard let deleteObject = daoHelper.findFirst(key: model.memoId as AnyObject) else { return }
        MemoDataDao.memoDataDaoDelegate?.result(type: .delete, error: daoHelper.delete(d: deleteObject))
    }
    
    // 全削除
    static func deleteAll() {
        MemoDataDao.memoDataDaoDelegate?.result(type: .deleteAll, error: daoHelper.deleteAll())
    }
    
    /// Memoモデルのtitleとcontentに文字列を分割してセットする（title = １行目, content = ２行目以降）
    ///
    /// - Parameters:
    ///   - memo: 値をセットするMemoオブジェクト
    ///   - text: セットする文字列
    static func setTextByLines(memo: Memo, text: String) {
        let lines = text.divideFirstLines()
        memo.title = lines[0]
        memo.content = lines.count >= 2 ? lines[1] : "" // 2行目以降が存在しない場合は空文字挿入
    }
}
