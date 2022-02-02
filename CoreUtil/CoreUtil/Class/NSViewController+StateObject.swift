//
//  NSViewController+StateObject.swift
//  CoreUtil
//
//  Created by yuki on 2021/06/24.
//  Copyright © 2021 yuki. All rights reserved.
//

import Cocoa
import Combine

public struct StateChannel<Value> {
    let rawValue: String
    
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

extension NSViewController {
    public func getState<Value>(for channel: StateChannel<Value?>) -> Value? {
        getState(for: channel).flatMap{ $0 }
    }
    public func getState<Value>(for channel: StateChannel<Value>) -> Value? {
        publisher(for: channel.rawValue).value as? Value
    }

    public func setState<Value>(_ value: Value?, for channel: StateChannel<Value>) {
        Self.activateStateObject()
        _setState(value, for: channel.rawValue)
    }
    
    public func getStatePublisher<Value>(for channel: StateChannel<Value>) -> AnyPublisher<Value?, Never> {
        publisher(for: channel.rawValue).map{ $0 as? Value }.eraseToAnyPublisher()
    }
    public func getStatePublisher<Value>(for channel: StateChannel<Value>) -> AnyPublisher<Value?, Never> where Value: AnyObject {
        publisher(for: channel.rawValue).map{ $0 as? Value }.removeDuplicates(by: ===).eraseToAnyPublisher()
    }
    public func getStatePublisher<Value>(for channel: StateChannel<Value?>) -> AnyPublisher<Value?, Never> where Value: AnyObject {
        publisher(for: channel.rawValue).map{ $0 as? Value }.removeDuplicates(by: ===).eraseToAnyPublisher()
    }
    
    public func linkState<Value>(for channel: StateChannel<Value>, to viewController: NSViewController) {
        getStatePublisher(for: channel).sink{ viewController.setState($0, for: channel) }.store(in: &self.objectBag)
    }
}

extension NSViewController {
    private static func activateStateObject() {
        enum __ {
            static let __: () = method_exchangeImplementations(
                class_getInstanceMethod(NSViewController.self, #selector(addChild))!,
                class_getInstanceMethod(NSViewController.self, #selector(_addChild))!
            )
        }
        __.__
    }
    
    private func _setState(_ value: Any?, for channel: String) {
        publisher(for: channel).send(value)
        
        for child in children {
            child._setState(value, for: channel)
        }
    }
    
    private static var envContainerKey = 0
    
    private var envContainer: [String: CurrentValueSubject<Any?, Never>] {
        get { objc_getAssociatedObject(self, &Self.envContainerKey) as? [String: CurrentValueSubject<Any?, Never>] ?? [:] }
        set { objc_setAssociatedObject(self, &Self.envContainerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    private func publisher(for channel: String) -> CurrentValueSubject<Any?, Never> {
        return envContainer[channel] ?? CurrentValueSubject(nil) => { envContainer[channel] = $0 }
    }
    
    @objc private dynamic func _addChild(_ childViewController: NSViewController) {
        for channel in envContainer.keys {
            guard let value = publisher(for: channel).value else { continue }
            
            childViewController._setState(value, for: channel)
        }
                
        self._addChild(childViewController)
    }
}
