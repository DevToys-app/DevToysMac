//
//  Action.swift
//  CoreUtil
//
//  Created by yuki on 2022/01/16.
//  Copyright © 2022 yuki. All rights reserved.
//

public struct Action {
    public let title: String
    public let action: () -> ()
    
    public init(title: String, action: @escaping () -> ()) {
        self.title = title
        self.action = action
    }
}
