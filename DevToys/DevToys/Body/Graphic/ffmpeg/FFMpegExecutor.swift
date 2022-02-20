//
//  FFMpegExecutor.swift
//  DevToys
//
//  Created by yuki on 2022/02/20.
//

import CoreUtil

enum FFMpegExecutor {
    static let ffmpegURL = Bundle.current.url(forResource: "ffmpeg", withExtension: nil)!
    
    static func execute(_ arguments: [String]) -> Promise<String, Error> {
        let task = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        task.executableURL = executableURL
        task.arguments = arguments
        
        if options.contains(.standardOutput) {
            task.standardOutput = outputPipe
        }
        if options.contains(.standardError) {
            task.standardError = errorPipe
        }
        
        return Promise<String, Error>.tryAsync(on: queue) { resolve, reject in
            try task.run()
            task.waitUntilExit()
            
            if task.terminationStatus != 0 {
                reject(TerminalError.nonZeroExit(errorPipe.readStringToEndOfFile ?? "[binary]"))
            } else {
                resolve(outputPipe.readStringToEndOfFile ?? "[binary]")
            }
        }
    }
}


public final class Progress {
    public let taskCount: Int
    
    @Observable public var completedTaskCount = 0
    @Observable public var isCompleted = false
    @Observable public var progress = 0.0
    
    public func complete(_ count: Int) {
        self.completedTaskCount = min(taskCount, completedTaskCount + count)
        self.progress = Double(completedTaskCount) / Double(taskCount)
        
        if !self.isCompleted, self.completedTaskCount == self.taskCount {
            self.isCompleted = true
        }
    }
    
    public init(taskCount: Int) {
        assert(taskCount > 0)
        self.taskCount = taskCount
    }
}
