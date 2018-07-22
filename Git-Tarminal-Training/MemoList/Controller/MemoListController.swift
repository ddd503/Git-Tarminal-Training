//
//  MemoListController.swift
//  Git-Tarminal-Training
//
//  Created by kawaharadai on 2018/07/16.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import UIKit

class MemoListController: UIViewController {
    
    @IBOutlet weak var memoList: UITableView!
    @IBOutlet weak var memoCountLabel: UILabel!
    
    private let dataSource = MemoListDataSource()
    var databaseActionType: ActionType?
    var databaseError: Error?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // データソース取得
        self.dataSource.memoList = MemoDataDao.selectObjects()
        DispatchQueue.main.async {
            self.memoList.reloadData()
        }
       
        // DB操作後の処理
        if let databaseActionType = self.databaseActionType {
            // エラーチェック
            if let databaseError = self.databaseError {
                self.failureDatabaseAction(type: databaseActionType, error: databaseError)
                return
            }
            // 成功
            self.successDatabaseAction(databaseActionType: databaseActionType)
            self.databaseActionType = nil
        }
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        memoList.isEditing = editing
    }
    
    // MARK: - Private
    private func setup() {
        memoList.dataSource = dataSource
        memoList.delegate = self
        dataSource.delegate = self
        navigationItem.rightBarButtonItem = editButtonItem
        self.updateMemoCount()
    }
    
    private func transitionMemoDetail(memoData: Memo?) {
        guard let editMemoController = UIStoryboard(name: "EditMemoController", bundle: nil)
            .instantiateInitialViewController() as? EditMemoController else {
                return
        }
        editMemoController.memoData = memoData
        editMemoController.isEditingMemo = memoData != nil
        self.navigationController?.pushViewController(editMemoController, animated: true)
    }
    
    private func updateMemoCount() {
        let memoCount = MemoDataDao.selectObjects().count
        self.memoCountLabel.text = memoCount > 0 ? "\(memoCount)件のメモ" : "メモなし"
    }
    
    private func successDatabaseAction(databaseActionType: ActionType) {
        switch databaseActionType {
        case .add:
            print("追加成功")
        case .update:
            print("更新成功")
        case .delete:
            print("削除成功")
        case .deleteAll:
            print("全削除成功")
        }
        // 件数表示を更新
        self.updateMemoCount()
    }
    
    private func failureDatabaseAction(type: ActionType, error: Error) {}
    
    // MARK: - Action
    @IBAction func addMemo(_ sender: UIBarButtonItem) {
        transitionMemoDetail(memoData: nil)
    }
    
}

extension MemoListController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        transitionMemoDetail(memoData: self.dataSource.memoList[indexPath.row])
    }
    
}

extension MemoListController: MemoListDataSourceDelegate {
    
    func delete(index: Int) {
        MemoDataDao.memoDataDaoDelegate = self
        MemoDataDao.delete(model: self.dataSource.memoList[index])
        self.dataSource.memoList.remove(at: index)
        self.memoList.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
    }
    
}

extension MemoListController: MemoDataDaoDelegate {
    
    func result(type: ActionType, error: Error?) {
        // DB操作がエラーした場合
        if let databaseError = error {
            print(databaseError)
            return
        }
        
        self.successDatabaseAction(databaseActionType: type)
    }
    
}
