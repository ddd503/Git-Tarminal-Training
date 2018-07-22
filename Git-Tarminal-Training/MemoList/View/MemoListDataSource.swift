//
//  MemoListDataSource.swift
//  Git-Tarminal-Training
//
//  Created by kawaharadai on 2018/07/16.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import UIKit

protocol MemoListDataSourceDelegate {
    func delete(index: Int)
}

final class MemoListDataSource: NSObject {
    var memoList: [Memo] = []
    var delegate: MemoListDataSourceDelegate?
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.delegate?.delete(index: indexPath.row)
        }
    }
}
