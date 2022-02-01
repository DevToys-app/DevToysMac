//
//  TextFieldSection.swift
//  DevToys
//
//  Created by yuki on 2022/02/01.
//

import CoreUtil

final class TextFieldSection: ControlSection {
    var string: String {
        get { textView.string } set { textView.string = newValue; copyButton.stringContent = newValue }
    }
    var stringPublisher: AnyPublisher<String, Never> {
        textView.changeStringPublisher.merge(with: self.pasteButton.stringPublisher.map{ $0 ?? "" }).eraseToAnyPublisher()
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
