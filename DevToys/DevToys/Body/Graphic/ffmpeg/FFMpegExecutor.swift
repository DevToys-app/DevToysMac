//
//  FFMpegExecutor.swift
//  DevToys
//
//  Created by yuki on 2022/02/20.
//

import CoreUtil

enum FFExecutor {
    private static let ffmpegURL = Bundle.current.url(forResource: "ffmpeg", withExtension: nil)!
    
    static func execute(_ arguments: [String], inputURL: URL, destinationURL: URL) -> Promise<FFTask, Never> {
        let arguments = ["-i", inputURL.path, "-y"] + arguments + [destinationURL.path]
                
        let task = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        task.executableURL = ffmpegURL
        task.arguments = arguments
        task.standardOutput = outputPipe
        task.standardError = errorPipe
                        
        var duration: FFTime? { didSet { durationPromise.fullfill(duration) } }
        let durationPromise = Promise<FFTime?, Never>()
                
        let completePromise = Promise<Void, Error>.tryAsync{ resolve, reject in
            try task.run()
            task.waitUntilExit()
            
            if task.terminationStatus != 0 {
                reject(TerminalError.nonZeroExit(errorPipe.readStringToEndOfFile ?? "[binary]"))
            } else {
                resolve(())
            }
        }
        
        let dtask = durationPromise
            .map{ FFTask(duration: $0, complete: completePromise) }
        let ctask = completePromise
            .replaceError(with: ())
            .map{ FFTask(duration: nil, complete: completePromise) }
        
        let taskPromise = Promise.first([dtask, ctask])!
                
        DispatchQueue.global().async {
            while let data = errorPipe.fileHandleForReading.availableData.nonEmptyOrNil() {
                guard let nsString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { continue }
                                
                if duration == nil, let fduration = findDuration(in: nsString) {
                    duration = fduration
                } else if case .fulfilled(let task) = taskPromise.state, let report = FFProgressReport(progressString: nsString as String) {
                    task.sendReport(report)
                }
            }
        }
        
        return taskPromise
    }
    
    private static func findDuration(in nsString: NSString) -> FFTime? {
        enum __ {
            static let rx = try! NSRegularExpression(pattern: "Duration: (.*?),", options: [])
        }
        let matches = __.rx.matches(in: nsString as String, options: [], range: NSRange(location: 0, length: nsString.length))
        guard let match = matches.first, match.numberOfRanges == 2 else { return nil }
        
        let timeString = nsString.substring(with: match.range(at: 1))
        return FFTime(timeString: timeString)
    }
}

extension Data {
    func nonEmptyOrNil() -> Data? {
        if isEmpty { return nil }
        return self
    }
}

extension Promise {
    public static func first(_ promises: [Promise<Output, Failure>]) -> Promise<Output, Failure>? {
        if promises.isEmpty { return nil }
        
        return Promise{ resolve, reject in
            for promise in promises { promise.sink(resolve, reject) }
        }
    }
}
