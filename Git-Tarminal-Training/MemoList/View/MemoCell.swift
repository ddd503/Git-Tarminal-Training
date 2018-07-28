//
//  MemoCell.swift
//  Git-Tarminal-Training
//
//  Created by kawaharadai on 2018/07/16.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import UIKit

class MemoCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    static var identifier: String {
        return String(describing: self)
    }
    
    /// タイトル、本文、更新日時を画面表示に反映（タイトルがない場合は”タイトルなし”とする）
    ///
    /// - Parameter memo: 表示するメモ情報
    func setMemoData(memo: Memo) {
        self.titleLabel.text = hasText(title: memo.title) ? "タイトルなし" : memo.title
        self.contentLabel.text = memo.content
        self.dateLabel.text = memo.updateDate.dateStyle()
    }
    
    /// 文字列が「空文字orスペースのみ」でないかを判定
    ///
    /// - Parameter title: チェックする文字列
    /// - Returns: true: 空文字orスペースのみ、false: スペースではないテキストが1文字以上入っている
    private func hasText(title: String) -> Bool {
        var checkTitle = title
        while true {
            guard let range = checkTitle.range(of: " ") else {
                break
            }
            checkTitle.removeSubrange(range)
        }
        return checkTitle.isEmpty
    }
}
