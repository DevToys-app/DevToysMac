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


public final class Progress<Failure: Error> {
    public enum State {
        case progressing(Double)
        case rejected(Failure)
        case completed
    }
    
    struct Subscriber {
        let progress: (Double) -> ()
        let complete: () -> ()
        let reject: (Failure) -> ()
    }
    
    public let taskCount: Int
    public private(set) var completedTaskCount = 0
    public private(set) var state: State = .progressing(0)
    
    var subscribers = [Subscriber]()
    
    public init(taskCount: Int) {
        assert(taskCount > 0)
        self.taskCount = taskCount
    }
        
    public func reject(_ failure: Failure) {
        guard case .progressing = state else { return }
        self.state = .rejected(failure)
        for subscriber in subscribers { subscriber.reject(failure) }
        self.subscribers.removeAll()
    }
    
    public func progress(_ count: Int) {
        guard case .progressing = state else { return }
        
        self.completedTaskCount = min(taskCount, completedTaskCount + count)
        
        if self.completedTaskCount == self.taskCount {
            self.state = .completed
            for subscriber in subscribers { subscriber.complete() }
            self.subscribers.removeAll()
        } else {
            let progress = Double(completedTaskCount) / Double(taskCount)
            self.state = .progressing(progress)
            for subscriber in subscribers { subscriber.progress(progress) }
        }
    }
    
    func subscribe(_ resolve: @escaping (Output) -> (), _ reject: @escaping (Failure) -> ()) {
        switch self.state {
        case .pending: self.subscribers.append(Subscriber(resolve: resolve, reject: reject))
        case .fulfilled(let output): resolve(output)
        case .rejected(let failure): reject(failure)
        }
    }
}
