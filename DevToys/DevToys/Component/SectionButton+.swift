//
//  SectionButton+.swift
//  DevToys
//
//  Created by yuki on 2022/01/30.
//

import CoreUtil

final class OpenSectionButton: SectionButton {
    
    let urlPublisher = PassthroughSubject<URL, Never>()
    
    var fileStringPublisher: AnyPublisher<String, Never> {
        urlPublisher.compactMap{ try? String(contentsOf: $0) }.eraseToAnyPublisher()
    }
    var fileDataPublisher: AnyPublisher<Data, Never> {
        urlPublisher.compactMap{ try? Data(contentsOf: $0) }.eraseToAnyPublisher()
    }
    
    @objc private func buttonAction(_: Any) {
        let panel = NSOpenPanel()
        guard panel.runModal() == .OK, let url = panel.url else { return }
        self.urlPublisher.send(url)
    }
    
    override func onAwake() {
        super.onAwake()
        self.title = ""
        self.image = R.Image.open
        self.setTarget(self, action: #selector(buttonAction))
    }
}

final class CopySectionButton: SectionButton {
    
    var stringContent: String?
    
    convenience init(hasTitle: Bool) {
        self.init()
        if hasTitle {
            self.title = "Copy"
        } else {
            self.title = ""
        }
    }
    
    override func onAwake() {
        super.onAwake()
        self.image = R.Image.copy
        
        self.actionPublisher
            .sink{[unowned self] in
                guard let stringContent = self.stringContent else { return NSSound.beep() }
                NSPasteboard.general.prepareForNewContents(with: .none)
                NSPasteboard.general.setString(stringContent, forType: .string)
                Toast.show(message: "Copied!")
            }
            .store(in: &objectBag)
    }
}

final class PasteSectionButton: SectionButton {
    var stringPublisher: AnyPublisher<String?, Never> {
        self.actionPublisher
            .peek{ Toast.show(message: "Pasted!") }
            .map{ return NSPasteboard.general.string(forType: .string) }
            .eraseToAnyPublisher()
    }
    
    override func onAwake() {
        super.onAwake()
        
        self.title = "Paste"
        self.image = R.Image.paste
    }
}
