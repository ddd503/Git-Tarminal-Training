//
//  RealmDaoHelper.swift
//  Git-Tarminal-Training
//
//  Created by kawaharadai on 2018/07/16.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import Foundation
import RealmSwift

final class RealmDaoHelper <T: RealmSwift.Object> {
    
    let realm: Realm
    
    // MARK: - 初期化
    init() {
        do {
            realm = try Realm()
        } catch(let error) {
            print("initエラー：\(error)")
            fatalError("RealmDaoHelper initialize error.")
        }
    }
    
    // MARK: - 新規登録
    func newId() -> Int? {
        guard let key = T.primaryKey() else {
            //primaryKey未設定
            return nil
        }
        return (realm.objects(T.self).max(ofProperty: key) as Int? ?? 0) + 1
    }
    
    // MARK: - 一括取得
    func findAll() -> Results<T> {
        return realm.objects(T.self)
    }
    
    // MARK: - 一番先頭のみ取得
    func findFirst() -> T? {
        return findAll().first
    }
    
    // MARK: - 任意の場所のオブジェクトを取得
    func findFirst(key: AnyObject) -> T? {
        return realm.object(ofType: T.self, forPrimaryKey: key)
    }
    
    // MARK: - 一番最後のオブジェクトを取得
    func findLast() -> T? {
        return findAll().last
    }
    
    // MARK: - 新規作成
    func add(d :T) -> Error? {
        do {
            try realm.write {
                realm.add(d)
            }
            return nil
        } catch let error {
            return error
        }
    }
    
    // MARK: - 更新
    func update(d: T, block:(() -> Void)? = nil) -> Error? {
        do {
            try realm.write {
                block?()
                realm.add(d, update: true)
            }
            return nil
        } catch let error {
            return error
        }
    }
    
    // MARK: - 削除
    func delete(d: T) -> Error? {
        do {
            try realm.write {
                realm.delete(d)
            }
            return nil
        } catch let error {
            return error
        }
    }
    
    // MARK: - 全削除
    func deleteAll() -> Error? {
        let allObject = realm.objects(T.self)
        do {
            try realm.write {
                realm.delete(allObject)
            }
            return nil
        } catch let error {
            return error
        }
    }
}
