//
//  Terminal.swift
//  CoreUtil
//
//  Created by yuki on 2022/02/11.
//

import Foundation

enum TerminalError: Error {
    case nonZeroExit(String)
}

enum Terminal {
    static func run(_ executableURL: URL, arguments: [String], queue: DispatchQueue = .global()) -> Promise<String, Error> {
        let task = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        task.executableURL = executableURL
        task.arguments = arguments
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        return Promise<String, Error>.asyncError(on: queue) { resolve, reject in
            try task.run()
            task.waitUntilExit()
            
            if task.terminationStatus != 0 {
                reject(errorPipe.readStringToEndOfFile ?? "[binary]")
            } else {
                resolve(outputPipe.readStringToEndOfFile ?? "[binary]")
            }
        }
    }
}

extension Pipe {
    public var readStringToEndOfFile: String? {
        String(data: self.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
    }
}
