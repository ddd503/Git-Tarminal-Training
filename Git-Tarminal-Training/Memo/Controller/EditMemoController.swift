//
//  EditMemoController.swift
//  Git-Tarminal-Training
//
//  Created by kawaharadai on 2018/07/20.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import Foundation
import UIKit

class EditMemoController: UIViewController {

    @IBOutlet weak var memoTextView: UITextView!
    
    // テキストビューの行間
    private let lineSpacing: CGFloat = 15
    private let fontSize: CGFloat = 16
    var memoData: Memo?
    var isEditingMemo = false
    // 編集時に変更の有無をチェックする用
    var beforeText = ""
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    // MARK: - Private
    private func setup() {
        // 編集の場合は、編集元のテキストを入れる
        if let memoData = self.memoData {
            self.beforeText = memoData.content == "" ?
                memoData.title : memoData.title + "\n" + memoData.content
            self.memoTextView.text = self.beforeText
        }
        self.setupBarButton()
        self.setupTextView()
        MemoDataDao.memoDataDaoDelegate = self
    }
    
    private func setupBarButton() {
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(EditMemoController.saveMemo(sender:)))
        rightBarButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    private func setupTextView() {
        self.memoTextView.delegate = self
        self.memoTextView.becomeFirstResponder()
        // 行間を設定
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing
        let attributes = [kCTParagraphStyleAttributeName : style]
        self.memoTextView.attributedText = NSAttributedString(string: self.memoTextView.text,
                                                              attributes: attributes as [NSAttributedStringKey : Any])
        // フォントはattributedTextをいじった後に変更しないとリセットされてしまう
        self.memoTextView.font = UIFont.systemFont(ofSize: fontSize)
    }
    
    /// 完了ボタンを押せるかどうかを判定する
    ///
    /// - Parameter text: Memoが持っているテキスト情報
    /// - Returns: 完了ボタンを押せるかどうか
    private func isEnabledDoneButton(text: String) -> Bool {
        // 空文字チェック
        guard text.count > 0 else {
            return false
        }
        
        // 変更前の文字列とのかぶりチェック
        if isEditingMemo {
            return text != self.beforeText
        }
        
        return true
    }
    
    // MARK: - Action
    /// メモ編集画面の右上の完了を押した場合に走る処理（作成処理or編集処理）
    ///
    /// - Parameter sender:
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

extension EditMemoController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        // テキストの入力状況によって完了ボタンの活性を管理
        self.navigationItem.rightBarButtonItem?.isEnabled = self.isEnabledDoneButton(text: textView.text)
    }
    
}
