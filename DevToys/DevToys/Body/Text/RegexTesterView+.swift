//
//  RegexTesterView+.swift
//  DevToys
//
//  Created by yuki on 2022/02/03.
//

import CoreUtil

final class RegexTesterViewController: NSViewController {
    private let cell = RegexTesterView()
    
    @RestorableState("rx.pattern") var pattern = #"(macOS|OS X) \d+\.\d+"#
    @RestorableState("rx.sample") var text = defaultText
    
    @Observable var regex: NSRegularExpression? = nil
    @Observable var isError = false
    @Observable var matches = [NSRange]()
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        self.cell.regexField.changeStringPublisher
            .sink{[unowned self] in self.pattern = $0; self.updateRegex() }.store(in: &objectBag)
        self.cell.textView.stringPublisher
            .sink{[unowned self] in self.text = $0; self.executeRegex() }.store(in: &objectBag)
        
        self.$isError.sink{[unowned self] in self.cell.regexField.isError = $0 }.store(in: &objectBag)
        self.$pattern.sink{[unowned self] in self.cell.regexField.string = $0 }.store(in: &objectBag)
        self.$text.sink{[unowned self] in self.cell.textView.string = $0 }.store(in: &objectBag)
        self.$matches.sink{[unowned self] in self.cell.textView.highlightRanges = $0 }.store(in: &objectBag)
        
        self.updateRegex()
    }
    
    private func updateRegex() {
        do {
            self.regex = try NSRegularExpression(pattern: pattern, options: .none)
            self.isError = false
        } catch {
            self.isError = true
            self.matches = []
            self.regex = nil
        }
        self.executeRegex()
    }
    
    private func executeRegex() {
        guard let regex = self.regex else { return }
        let nsstring = text as NSString
        
        let matches = regex.matches(in: text, options: .none, range: NSRange(location: 0, length: nsstring.length))
        var ranges = [NSRange]()
        for matche in matches {
            ranges.append(matche.range)
        }
        
        self.matches = ranges
    }
}

final private class RegexTesterView: Page {
    let regexField = TextField(showCopyButton: false)
    let textView = RegexTextView()
    
    override func layout() {
        super.layout()
        self.textView.snp.remakeConstraints{ make in
            make.height.equalTo(max(240, self.frame.height - 150))
        }
    }
    
    override func onAwake() {        
        self.regexField.isError = true
        self.regexField.font = .monospacedSystemFont(ofSize: R.Size.controlTitleFontSize, weight: .regular)
        self.addSection(Section(title: "Reguler expression".localized(), items: [regexField]))
        self.addSection(Section(title: "Text".localized(), items: [textView]))
    }
}

private let defaultText = """
OS X 10.9 Mavericks
OS X 10.10 Yosemite
OS X 10.11 El Capitan
macOS 10.12 Sierra
macOS 10.13 High Sierra
macOS 10.14 Mojave
macOS 10.15 Catalina
macOS 11.0 Big Sur
macOS 12.0 Monterey
"""
