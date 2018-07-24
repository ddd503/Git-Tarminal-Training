//
//  EditMemoController.swift
//  Git-Tarminal-Training
//
//  Created by kawaharadai on 2018/07/20.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import UIKit

class EditMemoController: UIViewController {

    @IBOutlet weak var memoTextView: UITextView!
    
    var memoData: Memo?
    var isEditingMemo = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    // MARK: - Private
    private func setup() {
        // 編集の場合は、編集元のテキストを入れる
        if let memoData = self.memoData {
            self.memoTextView.text = memoData.content == "" ?
                memoData.title : memoData.title + "\n" + memoData.content
        }
        self.setupBarButton()
        self.memoTextView.becomeFirstResponder()
        MemoDataDao.memoDataDaoDelegate = self
    }
    
    private func setupBarButton() {
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(EditMemoController.saveMemo(sender:)))
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    // MARK: - Action
    @objc func saveMemo(sender: UIBarButtonItem) {
        if self.isEditingMemo {
            guard let memoData = self.memoData else { return }
            memoData.updateDate = Date()
            MemoDataDao.setTextByLines(memo: memoData, text: self.memoTextView.text)
            MemoDataDao.update(model: memoData)
        } else {
            MemoDataDao.add(memoText: self.memoTextView.text)
        }
    }
}

extension EditMemoController: MemoDataDaoDelegate {
   // データベース処理完了通知
    func result(type: ActionType, error: Error?) {
        // 遷移元のVCを取得して値渡し
        guard
            let navigationController = self.navigationController,
            let memoListController = navigationController.viewControllers[navigationController.viewControllers.count - 2] as? MemoListController else {
            // 何もせずに戻る
            self.navigationController?.popViewController(animated: true)
            return
        }
        // 結果をリスト画面に渡して戻る
        memoListController.databaseActionType = type
        memoListController.databaseError = error
        
        self.navigationController?.popViewController(animated: true)
    }
    
}
