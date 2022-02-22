//
//  FFProgressReport.swift
//  DevToys
//
//  Created by yuki on 2022/02/20.
//

import CoreUtil

struct FFProgressReport {
    let speed: Double
    let time: FFTime
    let progress: Progress
    
    enum Progress {
        case `continue`
        case end
    }
    
    init?(progressData: Data) {
        if progressData.isEmpty { return nil }
        guard let string = String(data: progressData, encoding: .utf8) else { return nil }
        self.init(progressString: string)
    }
    
    init?(progressString: String) {
        enum Rx {
            static let time = try! NSRegularExpression(pattern: "time=(.*)", options: [])
            static let speed = try! NSRegularExpression(pattern: "speed=(.*)", options: [])
        }
        
        let nsString = progressString as NSString
        let range = NSRange(location: 0, length: nsString.length)
        
        guard let timeMatch = Rx.time.matches(in: progressString, options: [], range: range).first,
              let time = FFTime(timeString: nsString.substring(with: timeMatch.range(at: 1)))
        else { return nil }
        self.time = time
  
        guard let speedMatch = Rx.speed.matches(in: progressString, options: [], range: range).first,
              let speed = Scanner(string: nsString.substring(with: speedMatch.range(at: 1))).scanDouble()
        else { return nil }
        self.speed = speed
        
        
        let isEnd = nsString.contains("Lsize")
        if isEnd { self.progress = .end } else { self.progress = .continue }
    }
}
