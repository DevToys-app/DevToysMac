//
//  TextFieldSection.swift
//  DevToys
//
//  Created by yuki on 2022/02/01.
//

import CoreUtil

struct TextFieldSectionOptions: OptionSet {
    let rawValue: UInt64
}

final class TextFieldSection: ControlSection {
    var string: String {
        get { textView.string } set { textView.string = newValue; copyButton.stringContent = newValue }
    }
    var stringPublisher: AnyPublisher<String, Never> {
        textView.changeStringPublisher.merge(with: self.pasteButton.stringPublisher.map{ $0 ?? "" }).eraseToAnyPublisher()
    }
    
    func setMinified() {
        self.textView.showCopyButton = true
        self.minTitle = true
        self.removeAllToolbarItem()
    }
    
    convenience init(title: String, isEditable: Bool) {
        self.init(title: title)
        self.textView.isEditable = isEditable
        if !isEditable {
            self.setMinified()
        }
    }
    
    let textView = TextField(showCopyButton: false)
    private let pasteButton = PasteSectionButton()
    private let copyButton = CopySectionButton(hasTitle: false)
    
    override func onAwake() {
        super.onAwake()
        self.addStackItem(textView)
        self.addToolbarItem(pasteButton)
        self.addToolbarItem(copyButton)
    }
}
