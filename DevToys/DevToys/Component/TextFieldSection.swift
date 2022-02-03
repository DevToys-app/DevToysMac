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

final class TextFieldSection: Section {
    var string: String {
        get { textField.string } set { textField.string = newValue; copyButton.stringContent = newValue }
    }
    var stringPublisher: AnyPublisher<String, Never> {
        textField.changeStringPublisher.merge(with: self.pasteButton.stringPublisher.map{ $0 ?? "" }).eraseToAnyPublisher()
    }
    
    convenience init(title: String, isEditable: Bool) {
        self.init(title: title)
        self.textField.isEditable = isEditable
        if !isEditable {
            self.textField.showCopyButton = true
            self.minTitle = true
            self.removeAllToolbarItem()
        }
    }
    
    let textField = TextField(showCopyButton: false)
    private let pasteButton = PasteSectionButton()
    private let copyButton = CopySectionButton(hasTitle: false)
    
    override func onAwake() {
        super.onAwake()
        self.addStackItem(textField)
        self.addToolbarItem(pasteButton)
        self.addToolbarItem(copyButton)
    }
}
