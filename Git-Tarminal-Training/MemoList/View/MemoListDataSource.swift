//
//  MemoListDataSource.swift
//  Git-Tarminal-Training
//
//  Created by kawaharadai on 2018/07/16.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import UIKit

protocol MemoListDataSourceDelegate: class {
    func delete(index: Int)
    func updateTableViewSeparator(isEmpty: Bool)
}

final class MemoListDataSource: NSObject {
    var memoList: [Memo] = [] {
        didSet {
            // memoListが0件になる or 0件から増える時にupdateをかける
            if self.delegate != nil, self.isHiddenTableViewSeparator != self.memoList.isEmpty {
                self.delegate?.updateTableViewSeparator(isEmpty: self.memoList.isEmpty)
                self.isHiddenTableViewSeparator = self.memoList.isEmpty
            }
        }
    }
    weak var delegate: MemoListDataSourceDelegate?
    // tableViewのSeparatorの表示状態を管理
    var isHiddenTableViewSeparator = true
}

extension MemoListDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MemoCell.identifier, for: indexPath) as? MemoCell else {
            fatalError("cell is nil")
        }
        cell.setMemoData(memo: memoList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.delegate?.delete(index: indexPath.row)
        }
    }
}
