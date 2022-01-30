//
//  Ex+NSPopover.swift
//  CoreUtil
//
//  Created by yuki on 2021/05/31.
//  Copyright © 2021 yuki. All rights reserved.
//

import Cocoa
import Combine

extension NSPopover {
    public var willClosePublisher: AnyPublisher<Void, Never> { publisherDelegate.willClosePublisher.eraseToAnyPublisher() }
    public var willShowPublisher: AnyPublisher<Void, Never> { publisherDelegate.willShowPublisher.eraseToAnyPublisher() }
    public var didClosePublisher: AnyPublisher<Void, Never> { publisherDelegate.didClosePublisher.eraseToAnyPublisher() }
    public var didShowPublisher: AnyPublisher<Void, Never> { publisherDelegate.didShowPublisher.eraseToAnyPublisher() }
    public var didDetachPublisher: AnyPublisher<Void, Never> { publisherDelegate.didDetachPublisher.eraseToAnyPublisher() }
    
    private static var delegateKey = 0
    private var publisherDelegate: PublisherDelegate {
        if let delegate = objc_getAssociatedObject(self, &Self.delegateKey) as? PublisherDelegate { return delegate }
        
        let delegate = PublisherDelegate()
        self.delegate = delegate
        objc_setAssociatedObject(self, &Self.delegateKey, delegate, .OBJC_ASSOCIATION_RETAIN)
        return delegate
    }
    
    final private class PublisherDelegate: NSObject, NSPopoverDelegate {
        let willClosePublisher = PassthroughSubject<Void, Never>()
        let willShowPublisher = PassthroughSubject<Void, Never>()
        let didClosePublisher = PassthroughSubject<Void, Never>()
        let didShowPublisher = PassthroughSubject<Void, Never>()
        let didDetachPublisher = PassthroughSubject<Void, Never>()
        
        func popoverWillClose(_ notification: Notification) { willClosePublisher.send() }
        func popoverWillShow(_ notification: Notification) { willShowPublisher.send() }
        func popoverDidDetach(_ popover: NSPopover) { didDetachPublisher.send() }
        func popoverDidShow(_ notification: Notification) { didShowPublisher.send() }
        func popoverDidClose(_ notification: Notification) { didClosePublisher.send() }
    }
}

