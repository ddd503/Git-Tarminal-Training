//
//  MemoDataDaoTest.swift
//  Git-Tarminal-TrainingTests
//
//  Created by kawaharadai on 2018/07/29.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import XCTest
@testable import Git_Tarminal_Training

class MemoDataDaoTest: XCTestCase, MemoDataDaoDelegate {
    
    private let newId = 1
    private let newTitle = "テストタイトル"
    private let newContent = "テスト本文"
    private let newDate = "2017/01/01"
    private let editedTitle = "編集済みテストタイトル"
    private let editedContent = "編集済みテスト本文"
    private let editedDate = "2017/02/02"
    
    func result(type: ActionType, error: Error?) {}
    
    /// 各テストの前に走る
    override func setUp() {
        super.setUp()
        MemoDataDao.memoDataDaoDelegate = self
        MemoDataDao.deleteAll()
    }
    
    /// 各テストの終わりに走る
    override func tearDown() {
        super.tearDown()
        MemoDataDao.deleteAll()
    }
    
    /// 新規作成時にユニークのIDを割り振るテスト
    func testCreateNewId() {
        let expectIds = [5, 4, 3, 2, 1] // 取得順はupdateDateが新しい順となるため
        for _ in expectIds {
            MemoDataDao.add(newObject: Memo())
        }
        let memos = MemoDataDao.selectObjects()
        XCTAssertEqual(memos.map { $0.memoId }, expectIds)
    }
    
    /// 新規メモデータをDBに保存するテスト
    func testAdd() {
        let newMemo = Memo()
        newMemo.memoId = newId
        newMemo.title = newTitle
        newMemo.content = newContent
        newMemo.updateDate = newDate.strToDate(dateFormat: "yyyy/MM/dd")
        MemoDataDao.add(newObject: newMemo)
        self.checkItem(memoId: newId, title: newTitle, content: newContent, updateDate: newDate)
    }
    
    /// DBに保存されているメモデータの内容を編集するテスト
    func testUpdate() {
        let newMemo = Memo()
        newMemo.memoId = newId
        newMemo.title = newTitle
        newMemo.content = newContent
        newMemo.updateDate = newDate.strToDate(dateFormat: "yyyy/MM/dd")
        MemoDataDao.add(newObject: newMemo)
        
        let editMemo = MemoDataDao.selectID(memoId: newId)!
        editMemo.memoId = newId
        editMemo.title = editedTitle
        editMemo.content = editedContent
        editMemo.updateDate = editedDate.strToDate(dateFormat: "yyyy/MM/dd")
        MemoDataDao.update(model: editMemo)
        self.checkItem(memoId: newId, title: editedTitle, content: editedContent, updateDate: editedDate)
    }
    
    /// DBに保存されているメモデータを1件指定して削除するテスト
    func testDelete() {
        let newMemo = Memo()
        newMemo.memoId = newId
        newMemo.title = newTitle
        newMemo.content = newContent
        newMemo.updateDate = newDate.strToDate(dateFormat: "yyyy/MM/dd")
        MemoDataDao.add(newObject: newMemo)
        MemoDataDao.delete(model: newMemo)
        self.checkCount(totalCount: 0)
    }
    
    /// DBに保存されているメモデータを全件削除するテスト
    func testDeleteAll() {
        let memos = [Memo(), Memo(), Memo()]
        memos.forEach {
            MemoDataDao.add(newObject: $0)
        }
        self.checkCount(totalCount: memos.count)
        MemoDataDao.deleteAll()
        self.checkCount(totalCount: 0)
    }
    
    /// DBに保存されているメモデータをIDで指定して1件取得するテスト
    func testSelect() {
        let newMemo = Memo()
        newMemo.memoId = newId
        newMemo.title = newTitle
        newMemo.content = newContent
        newMemo.updateDate = newDate.strToDate(dateFormat: "yyyy/MM/dd")
        MemoDataDao.add(newObject: newMemo)
        
        // これではMemo型自体の比較はできない
        let selectedMemo = MemoDataDao.selectID(memoId: newId)
        XCTAssertEqual(newMemo.memoId, selectedMemo!.memoId)
    }
    
    /// DBに保存されているメモデータを全件まとめて取得するテスト
    func testSelectAll() {
        let memos = [Memo(), Memo(), Memo()]
        memos.forEach {
            MemoDataDao.add(newObject: $0)
        }
        let selectedAllMemo = MemoDataDao.selectObjects()
        XCTAssertEqual(selectedAllMemo.count, memos.count)
    }
    
    /// 任意のテキストを１行目と２行目以降で分割してオブジェクトにセットするテスト
    func testSeparate() {
        let targetMemo = Memo()
        MemoDataDao.setTextByLines(memo: targetMemo, text: "テスト1\nテスト2\nテスト3")
        XCTAssertEqual(targetMemo.title, "テスト1")
        XCTAssertEqual(targetMemo.content, "テスト2\nテスト3")
        MemoDataDao.setTextByLines(memo: targetMemo, text: "テスト1")
        XCTAssertEqual(targetMemo.title, "テスト1")
        XCTAssertEqual(targetMemo.content, "")
    }
    
    private func checkItem(memoId: Int, title: String, content: String, updateDate: String) {
        let memos = MemoDataDao.selectObjects()
        XCTAssertEqual(memos.first?.memoId, memoId)
        XCTAssertEqual(memos.first?.title, title)
        XCTAssertEqual(memos.first?.content, content)
        XCTAssertEqual(memos.first?.updateDate.dateStyle(), updateDate)
    }
    
    private func checkCount(totalCount: Int) {
        let memos = MemoDataDao.selectObjects()
        XCTAssertEqual(memos.count, totalCount)
    }
}
