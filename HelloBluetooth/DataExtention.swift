//
//  DataExtentions.swift
//  HelloBluetooth
//
//  Created by Paul Ventisei on 03/02/2017.
//  Copyright © 2017 Personal. All rights reserved.
//

import Foundation

extension Data {
    
    static func dataWithArray(value: [[UInt8]]) -> Data {
        
        var data = Data()
        for i in value {
            data.append(i, count: i.count)
        }
        return data
    }
 }
