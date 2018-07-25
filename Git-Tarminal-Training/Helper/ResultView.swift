//
//  ResultView.swift
//  Git-Tarminal-Training
//
//  Created by kawaharadai on 2018/07/25.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import Foundation
import UIKit

final class ResultView {
    
    /// メモ操作完了を伝えるラベル表示を出します。
    ///
    /// - Parameters:
    ///   - topView: ラベルを表示するView
    ///   - resultMessage: 表示するメッセージ
    static func show(topView: UIView, resultMessage: String) {
        
        let resultLabel = UILabel()
        resultLabel.text = resultMessage
        resultLabel.font = UIFont.boldSystemFont(ofSize: 17)
        resultLabel.textColor = .white
        resultLabel.backgroundColor = .lightGray
        resultLabel.textAlignment = .center
        resultLabel.alpha = 0
        resultLabel.sizeToFit()
        resultLabel.frame.size.width = resultLabel.frame.width * 1.3
        resultLabel.frame.size.height = 40
        resultLabel.center = CGPoint(x: topView.center.x, y: topView.center.y * 1.2)
        topView.addSubview(resultLabel)
        
        resultLabel.layer.masksToBounds = true
        resultLabel.layer.cornerRadius = 5
        
        UIView.animateKeyframes(withDuration: 1.5, delay: 0.0, options: [.autoreverse], animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5, animations: {
                resultLabel.alpha = 0.9
            })
            
            UIView.addKeyframe(withRelativeStartTime: 1.0, relativeDuration: 0.5, animations: {
                resultLabel.alpha = 0.0
            })
            
        }) { _ in
            resultLabel.removeFromSuperview()
        }
    }
    
}
