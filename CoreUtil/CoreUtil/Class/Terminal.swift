//
//  Terminal.swift
//  CoreUtil
//
//  Created by yuki on 2022/02/11.
//

import Foundation

public enum TerminalError: Error, CustomStringConvertible {
    case nonZeroExit(String)
    
    public var description: String {
        switch self {
        case .nonZeroExit(let string): return string
        }
    }
}

public enum Terminal {
    public struct ExecuteOption: OptionSet {
        public let rawValue: UInt64
        
        public init(rawValue: UInt64) { self.rawValue = rawValue }
        
        public static let standardOutput = ExecuteOption(rawValue: 1 << 0)
        public static let standardError = ExecuteOption(rawValue: 1 << 1)
    }
    
    public static func run(_ executableURL: URL, arguments: [String], queue: DispatchQueue = .global(), options: ExecuteOption = .all) -> Promise<String, Error> {
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

extension Pipe {
    public var readStringToEndOfFile: String? {
        String(data: self.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
    }
}
