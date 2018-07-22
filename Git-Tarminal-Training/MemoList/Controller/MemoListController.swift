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
    @IBOutlet weak var addMemoButton: UIBarButtonItem!
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
        self.reloadMemoList()
        
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
        self.memoList.isEditing = editing
        self.addMemoButton.title = editing ? "すべて削除" : "メモ追加"
    }
    
    // MARK: - Private
    private func setup() {
        self.memoList.dataSource = dataSource
        self.memoList.delegate = self
        dataSource.delegate = self
        navigationItem.rightBarButtonItem = editButtonItem
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
    
    private func reloadMemoList() {
        self.dataSource.memoList = MemoDataDao.selectObjects()
        DispatchQueue.main.async {
            self.memoList.reloadData()
        }
    }
    
    private func deleteAllAlert() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAllAction = UIAlertAction(title: "すべて削除", style: .destructive) { _ in
            MemoDataDao.memoDataDaoDelegate = self
            MemoDataDao.deleteAll()
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        actionSheet.addAction(deleteAllAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true)
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
            // アニメーション付きで削除
            for _ in self.dataSource.memoList {
                self.dataSource.memoList.remove(at: 0)
                self.memoList.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            }
        }
    }
    
    private func failureDatabaseAction(type: ActionType, error: Error) {}
    
    // MARK: - Action
    @IBAction func addMemo(_ sender: UIBarButtonItem) {
        if self.memoList.isEditing {
            // 全削除
            self.deleteAllAlert()
        } else {
            // 新規追加
            self.transitionMemoDetail(memoData: nil)
        }
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
