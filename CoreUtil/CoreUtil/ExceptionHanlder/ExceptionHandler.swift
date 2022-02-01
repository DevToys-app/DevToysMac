//
//  ExceptionHandler.swift
//  CoreUtil
//
//  Created by yuki on 2021/06/26.
//  Copyright © 2021 yuki. All rights reserved.
//

@inlinable public func objc_try(_ tryBlock: () -> ()) throws {
    var error: NSError?
    _ExceptionHandler.objc_try(tryBlock, objc_catch: {
        error = NSError(domain: "NSException", code: 999, userInfo: $0.userInfo?.reduce(into: [:]) { $0["\($1.key)"] = $1.value })
    }, objc_finally: {})
    if let error = error { throw error }
}

@inlinable public func objc_try<T>(_ tryBlock: () -> T) throws -> T {
    var value: T?
    var error: NSError?
    _ExceptionHandler.objc_try({
        value = tryBlock()
    }, objc_catch: {
        error = NSError(domain: "NSException", code: 999, userInfo: $0.userInfo?.reduce(into: [:]) { $0["\($1.key)"] = $1.value })
    }, objc_finally: {})
    if let error = error { throw error }
    return value!
}

@inlinable public func objc_try(_ tryBlock: () -> (), catch catchBlock: (NSException) -> (), finally finallyBlock: () -> () = {}) {
    _ExceptionHandler.objc_try(tryBlock, objc_catch: catchBlock, objc_finally: finallyBlock)
}

@inlinable public func objc_try<T>(_ tryBlock: () -> T, catch catchBlock: (NSException) -> T, finally finallyBlock: () -> () = {}) -> T {
    var value: T!
    
    _ExceptionHandler.objc_try({
        value = tryBlock()
    }, objc_catch: {
        value = catchBlock($0)
    }, objc_finally: finallyBlock)
    
    return value
}
