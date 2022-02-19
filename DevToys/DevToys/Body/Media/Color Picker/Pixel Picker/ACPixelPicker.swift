//
//  ACPixelPicker.swift
//  AxComponents
//
//  Created by yuki on 2020/06/30.
//  Copyright © 2020 yuki. All rights reserved.
//

import Cocoa

class ACPixelPicker {

    private var controller: ACOverlayController!

    init() {
        let nib = NSNib(nibNamed: "ACOverlayController", bundle: .current)!
        var topLevelObjects: NSArray? = []
        nib.instantiate(withOwner: self, topLevelObjects: &topLevelObjects)

        guard let controller = topLevelObjects?.compactMap({ $0 as? ACOverlayController }).first else { fatalError() }

        self.controller = controller
    }

    func show(_ completion: @escaping (Color?) -> Void) {
        controller.showPicker {
            completion(Color(nsColor: $0))
        }
    }
}
