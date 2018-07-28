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
    var databaseActionType: ActionType = .none
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
        // DB操作を行っていた場合は完了後の処理を行う
        if self.databaseActionType != .none {
            self.result(type: self.databaseActionType, error: self.databaseError)
            self.databaseActionType = .none
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.memoList.isEditing = editing
        self.addMemoButton.title = editing ? "delete all".localized() : "add memo".localized()
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
    
    /// メモ編集画面Memo型変数を渡した上で遷移する
    ///
    /// - Parameter memoData: 編集するMemoクラスのデータ
    private func transitionMemoDetail(memoData: Memo?) {
        guard let editMemoController = UIStoryboard(name: EditMemoController.identifier, bundle: nil)
            .instantiateInitialViewController() as? EditMemoController else {
                print("EditMemoController is nil")
                return
        }
        editMemoController.memoData = memoData
        editMemoController.isEditingMemo = memoData != nil
        self.navigationController?.pushViewController(editMemoController, animated: true)
    }
    
    /// メモ一覧画面のメモ件数を更新する
    private func updateMemoCount() {
        let memoCount = MemoDataDao.selectObjects().count
        self.memoCountLabel.text = memoCount > 0 ? "\(memoCount)件のメモ" : "nothing memo".localized()
    }
    
    /// アプリ側のデータソースを更新する
    private func reloadMemoList() {
        self.dataSource.memoList = MemoDataDao.selectObjects()
        DispatchQueue.main.async {
            self.memoList.reloadData()
        }
    }
    
    /// 『すべて削除』を行うためのアクションシートを表示する
    private func deleteAllAlert() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAllAction = UIAlertAction(title: "delete all".localized(), style: .destructive) { _ in
            MemoDataDao.memoDataDaoDelegate = self
            MemoDataDao.deleteAll()
        }
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil)
        
        actionSheet.addAction(deleteAllAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true)
    }
    
    /// DB操作に成功した場合に各操作アクションに応じた成功後処理を行う
    ///
    /// - Parameter databaseActionType: 成功したDB操作
    private func successDatabaseAction(databaseActionType: ActionType) {
        switch databaseActionType {
        case .add:
            ResultView.show(topView: self.view, resultMessage: "did add memo".localized())
        case .update:
            ResultView.show(topView: self.view, resultMessage: "did edit memo".localized())
        case .delete:
            ResultView.show(topView: self.view, resultMessage: "did delete memo".localized())
        case .deleteAll:
            // アニメーション付きで削除
            for _ in self.dataSource.memoList {
                self.dataSource.memoList.remove(at: 0)
                self.memoList.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            }
            self.memoList.reloadData() // 編集で単数削除選択時に全削除すると固まる問題への対応
            self.addMemoButton.isEnabled = false // すべて削除成功時は続けて押せないようにする
            ResultView.show(topView: self.view, resultMessage: "did delete all memo".localized())
        case .none:
            break
        }
        // 件数表示を更新
        self.updateMemoCount()
    }
    
    /// DB操作に失敗した場合に、各アクションに応じたアラートを出す
    ///
    /// - Parameters:
    ///   - databaseActionType: DB操作種別
    ///   - error: 発生したエラー
    private func failureDatabaseAction(databaseActionType: ActionType, error: Error) {
        // 現状error自体をハンドリングしていない
        var errorMessage = ""
        switch databaseActionType {
        case .add:
            errorMessage = "failed add memo".localized()
        case .update:
            errorMessage = "failed edit memo".localized()
        case .delete:
            errorMessage = "failed delete memo".localized()
        case .deleteAll:
           errorMessage = "failed delete all memo".localized()
        case .none:
            break
        }
        let errorAlert = UIAlertController(title: "error".localized(), message: errorMessage, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "ok".localized(), style: .default, handler: nil)
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
    
    /// 削除操作のリクエスト
    ///
    /// - Parameter index: 削除する要素のindex
    func delete(index: Int) {
        MemoDataDao.memoDataDaoDelegate = self
        MemoDataDao.delete(model: self.dataSource.memoList[index])
        self.dataSource.memoList.remove(at: index)
        self.memoList.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
    }
    
    /// テーブルビューのSeparatorの表示非表示を管理（セルが0件の時：表示、セルが1件以上の時：非表示）
    ///
    /// - Parameter isEmpty: データソース(セル)が0件かどうか
    func updateTableViewSeparator(isEmpty: Bool) {
        self.memoList.separatorStyle = isEmpty ? .singleLine : .none
    }
    
}

extension MemoListController: MemoDataDaoDelegate {
    
    /// DB操作の完了通知
    ///
    /// - Parameters:
    ///   - type: DB操作種別
    ///   - error: 操作失敗時はErrorを取得しています
    func result(type: ActionType, error: Error?) {
        // DB操作がエラーした場合
        if let databaseError = error {
            self.failureDatabaseAction(databaseActionType: type, error: databaseError)
            return
        }
        
        self.successDatabaseAction(databaseActionType: type)
    }
    
}
