//
//  FFTime.swift
//  DevToys
//
//  Created by yuki on 2022/02/20.
//

import Foundation

struct FFTime: CustomStringConvertible {
    let hour: Int
    let minute: Int
    let second: Int
    let ds: Int
    
    var timeInterval: TimeInterval {
        Double(hour)*60*60 + Double(minute)*60 + Double(second) + Double(ds)/100
    }
    var description: String {
        "FFTime(\(hour):\(minute):\(second).\(ds))"
    }
    
    init?(timeString: String) {
        let scanner = Scanner(string: timeString)
        
        guard let hour = scanner.scanInt(), let s1 = scanner.scanCharacter(), s1 == ":",
              let minute = scanner.scanInt(), let s2 = scanner.scanCharacter(), s2 == ":",
              let second = scanner.scanInt(), let s3 = scanner.scanCharacter(), s3 == ".",
              let ds = scanner.scanInt()
        else { return nil }
        
        self.hour = hour
        self.minute = minute
        self.second = second
        self.ds = ds
    }
}
