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
    
    // MARK: - Lifecycle
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
                self.failureDatabaseAction(databaseActionType: databaseActionType, error: databaseError)
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
        // 編集中かつデータが0件の場合にすべて削除を押せないようにする
        if editing {
            self.addMemoButton.isEnabled = !self.dataSource.memoList.isEmpty
        } else {
            self.addMemoButton.isEnabled = true
        }
    }
    
    // MARK: - Private
    private func setup() {
        self.memoList.dataSource = dataSource
        self.memoList.delegate = self
        dataSource.delegate = self
        navigationItem.rightBarButtonItem = editButtonItem
        self.updateMemoCount()
        self.updateTableViewSeparator(isEmpty: self.dataSource.memoList.isEmpty)
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
            ResultView.show(topView: self.view, resultMessage: "メモを作成しました。")
        case .update:
            ResultView.show(topView: self.view, resultMessage: "メモを編集しました。")
        case .delete:
            ResultView.show(topView: self.view, resultMessage: "メモを削除しました。")
        case .deleteAll:
            // アニメーション付きで削除
            for _ in self.dataSource.memoList {
                self.dataSource.memoList.remove(at: 0)
                self.memoList.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            }
            self.memoList.reloadData() // 編集で単数削除選択時に全削除すると固まる問題への対応
            self.addMemoButton.isEnabled = false // すべて削除成功時は続けて押せないようにする
            ResultView.show(topView: self.view, resultMessage: "メモをすべて削除しました。")
        }
        // 件数表示を更新
        self.updateMemoCount()
    }
    
    private func failureDatabaseAction(databaseActionType: ActionType, error: Error) {
        // 現状error自体をハンドリングしていない
        var errorMessage = ""
        switch databaseActionType {
        case .add:
            errorMessage = "メモの作成に失敗しました。"
        case .update:
            errorMessage = "メモの編集に失敗しました。"
        case .delete:
            errorMessage = "メモの削除に失敗しました。"
        case .deleteAll:
           errorMessage = "メモの全削除に失敗しました。"
        }
        let errorAlert = UIAlertController(title: "エラー", message: errorMessage, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        errorAlert.addAction(alertAction)
        self.present(errorAlert, animated: true, completion: nil)
    }
    
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
    
    // スワイプでの編集モード開始時
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        self.addMemoButton.isEnabled = false
    }
    
    // スワイプでの編集モード終了時
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        self.addMemoButton.isEnabled = true
    }
    
}

extension MemoListController: MemoListDataSourceDelegate {
    
    func delete(index: Int) {
        MemoDataDao.memoDataDaoDelegate = self
        MemoDataDao.delete(model: self.dataSource.memoList[index])
        self.dataSource.memoList.remove(at: index)
        self.memoList.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
    }
    
    func updateTableViewSeparator(isEmpty: Bool) {
        self.memoList.separatorStyle = isEmpty ? .singleLine : .none
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
