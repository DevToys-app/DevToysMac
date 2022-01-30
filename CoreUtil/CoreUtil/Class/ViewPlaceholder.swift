//
//  ViewPlaceholder.swift
//  CoreUtil
//
//  Created by yuki on 2021/06/03.
//  Copyright © 2021 yuki. All rights reserved.
//

import Cocoa
import Combine

open class NSPlaceholderView<View: NSView>: NSLoadView {
    public var contentView: View? {
        didSet {
            oldValue?.removeFromSuperview()
            if let contentView = contentView {
                self.addSubview(contentView)
                contentView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    contentView.rightAnchor.constraint(equalTo: self.rightAnchor),
                    contentView.leftAnchor.constraint(equalTo: self.leftAnchor),
                    contentView.topAnchor.constraint(equalTo: self.topAnchor),
                    contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                ])
            }
        }
    }
}
