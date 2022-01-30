//
//  NSButton+Combine.swift
//  CoreUtil
//
//  Created by yuki on 2021/07/23.
//  Copyright © 2021 yuki. All rights reserved.
//

import Cocoa
import Combine

private var actionPublisherKey = 0

extension NSControl {
    
    final public class Publisher: Combine.Publisher {
        public typealias Output = Void
        public typealias Failure = Never
        
        final class Target: NSObject {
            let subject = PassthroughSubject<Void, Never>()
            @objc func action(_ sender: NSControl) { self.subject.send() }
        }
        
        let target: Target
        
        init(control: NSControl) {
            let target = Target()
            control.target = target
            control.action = #selector(Target.action)
            self.target = target
        }
        
        public func receive<S: Subscriber>(subscriber: S) where S.Failure == Failure, S.Input == Output {
            self.target.subject.receive(subscriber: subscriber)
        }
    }
    
    // actionとtargetを設定してpublisherとして出力できるようにします。
    public var actionPublisher: Publisher {
        if let publisher = objc_getAssociatedObject(self, &actionPublisherKey) as? Publisher { return publisher }
        let publisher = Publisher(control: self)
        objc_setAssociatedObject(self, &actionPublisherKey, publisher, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return publisher
    }
}
