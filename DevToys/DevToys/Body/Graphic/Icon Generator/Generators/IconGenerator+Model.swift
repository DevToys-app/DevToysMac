//
//  IconGenerator+Model.swift
//  DevToys
//
//  Created by yuki on 2022/02/26.
//

import CoreUtil

struct IconGenerateTask {
    let imageItem: ImageItem
    let complete: Promise<Void, Error>
}

enum IconGenerateError: Error {
    case convertError
    case exportError(Error)
}
