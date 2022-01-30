//
//  ExceptionHandler.swift
//  CoreUtil
//
//  Created by yuki on 2021/06/26.
//  Copyright © 2021 yuki. All rights reserved.
//

@inlinable public func objc_try(_ tryBlock: () -> (), catch catchBlock: (NSException) -> (), finally finallyBlock: () -> () = {}) {                _ExceptionHandler.objc_try(tryBlock, objc_catch: catchBlock, objc_finally: finallyBlock)
}
