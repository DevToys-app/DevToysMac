//
//  Ex+Localize.swift
//  CoreUtil
//
//  Created by yuki on 2022/02/13.
//

import Foundation

extension String {
    public func localized() -> String {
        NSLocalizedString(self, comment: self)
    }
}
