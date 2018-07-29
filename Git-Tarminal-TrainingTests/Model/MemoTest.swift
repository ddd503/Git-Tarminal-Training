//
//  MemoTest.swift
//  Git-Tarminal-TrainingTests
//
//  Created by kawaharadai on 2018/07/29.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import XCTest
@testable import Git_Tarminal_Training

class MemoTest: XCTestCase {
    
    // テスト用オブジェクト
    let memo = Memo()
    
    /// Memoオブジェクトに初期値が正しくセットされるかのテスト
    func testInitMemo() {
        XCTAssertEqual(memo.memoId, 0)
        XCTAssertEqual(memo.title, "")
        XCTAssertEqual(memo.content, "")
        XCTAssertNotNil(memo.updateDate)
    }
    
    /// Memoオブジェクトに任意の値をセットするテスト
    func testSetMemoData() {
        memo.memoId = 10
        memo.title = "タイトル"
        memo.content = "本文"
        memo.updateDate = "2017/01/01".strToDate(dateFormat: "yyyy/MM/dd")
        
        XCTAssertEqual(memo.memoId, 10)
        XCTAssertEqual(memo.title, "タイトル")
        XCTAssertEqual(memo.content, "本文")
        XCTAssertEqual(memo.updateDate.dateStyle(), "2017/01/01")
    }
}
