//
//  String+Date.swift
//  Git-Tarminal-Training
//
//  Created by kawaharadai on 2018/07/29.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import Foundation

extension String {
    
    func strToDate(dateFormat: String) -> Date  {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP") as Locale?
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        dateFormatter.dateFormat = dateFormat
        
        return dateFormatter.date(from: self)!
    }
    
}
