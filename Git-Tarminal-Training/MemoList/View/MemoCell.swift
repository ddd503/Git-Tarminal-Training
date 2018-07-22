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
    
    func setMemoData(memo: Memo) {
        // TODO: １行目を取り出してタイトルに
        // TODO: 日付データをStringに変換して日付ラベルに
        // TODO: 2行目以降を本文ラベルに
        
        let linesArray = memo.memoText.components(separatedBy: "\n")
        if linesArray.count >= 2 {
            self.titleLabel.text = linesArray[0] == "" ? "タイトルなし" : linesArray[0]
            self.contentLabel.text = linesArray[1]
        } else if linesArray.count >= 1 {
            self.titleLabel.text = linesArray[0] == "" ? "タイトルなし" : linesArray[0]
            self.contentLabel.text = ""
        }
        
    }
}
