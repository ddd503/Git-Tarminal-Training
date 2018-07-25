//
//  String+Lines.swift
//  Git-Tarminal-Training
//
//  Created by kawaharadai on 2018/07/24.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import Foundation

public extension String {
    /// 文字列を”１行目”と”２行目以降”に分ける
    ///
    /// - 2行以上の文章　= [１行目, それ以降の文章]
    /// - 1行の文章　= [１行目]
    /// - nil(ありえない)　= []
    func divideFirstLines() -> [String] {
        var lines: [String] = self.components(separatedBy: .newlines)
        guard lines.count >= 1 else { return [] }
        let firstLine = lines[0]
        lines.remove(at: 0)
        guard lines.count >= 1 else { return [firstLine] }
        let otherLine = lines.joined(separator: "\n")
        return [firstLine, otherLine]
    }
}
