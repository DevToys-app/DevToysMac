//
//  Combine+TextField.swift
//  CoreUtil
//
//  Created by yuki on 2021/01/03.
//  Copyright © 2021 yuki. All rights reserved.
//

import Cocoa
import Combine

private var delegateKey = 0

extension NSTextField {
    
    public var endEditingStringPublisher: AnyPublisher<String, Never> { pubilsherDelegate.endEditingPublisher.map{ $0.stringValue }.eraseToAnyPublisher() }
    public var changeStringPublisher: AnyPublisher<String, Never> { pubilsherDelegate.changePublisher.map{ $0.stringValue }.eraseToAnyPublisher() }
    public var beginEditingStringPublisher: AnyPublisher<String, Never> { pubilsherDelegate.beginEditingPublisher.map{ $0.stringValue }.eraseToAnyPublisher() }
    
    public var endEditingPublisher: AnyPublisher<NSTextField, Never> { pubilsherDelegate.endEditingPublisher.eraseToAnyPublisher() }
    public var changePublisher: AnyPublisher<NSTextField, Never> { pubilsherDelegate.changePublisher.eraseToAnyPublisher() }
    public var beginEditingPublisher: AnyPublisher<NSTextField, Never> { pubilsherDelegate.beginEditingPublisher.eraseToAnyPublisher() }
    
    final private class PublisherDelegate: NSObject, NSTextFieldDelegate {
        let endEditingPublisher = PassthroughSubject<NSTextField, Never>()
        let changePublisher = PassthroughSubject<NSTextField, Never>()
        let beginEditingPublisher = PassthroughSubject<NSTextField, Never>()
        
        func controlTextDidBeginEditing(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }
            beginEditingPublisher.send(textField)
        }
        func controlTextDidChange(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }
            changePublisher.send(textField)
        }
        func controlTextDidEndEditing(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }
            endEditingPublisher.send(textField)
        }
    }
    
    private var pubilsherDelegate: PublisherDelegate {
        if let delegate = objc_getAssociatedObject(self, &delegateKey) as? PublisherDelegate { return delegate }
        let delegate = PublisherDelegate()
        objc_setAssociatedObject(self, &delegateKey, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        assert(self.delegate == nil, "Publisher delegate is not averable. \(delegate)")
        self.delegate = delegate
        return delegate
    }
}
