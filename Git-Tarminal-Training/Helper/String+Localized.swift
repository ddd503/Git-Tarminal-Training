//
//  String+Localized.swift
//  Git-Tarminal-Training
//
//  Created by kawaharadai on 2018/07/28.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import Foundation

extension String {
    
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
    
}
