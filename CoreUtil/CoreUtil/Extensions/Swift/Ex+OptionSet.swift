//
//  Ex+OptionSet.swift
//  CoreUtil
//
//  Created by yuki on 2020/04/13.
//  Copyright © 2020 yuki. All rights reserved.
//

extension OptionSet where RawValue: FixedWidthInteger {
    public static var all: Self { Self(rawValue: RawValue.max) }
    public static var none: Self { [] }
}
