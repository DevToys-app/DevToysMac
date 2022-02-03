//
//  RegexTesterView+.swift
//  DevToys
//
//  Created by yuki on 2022/02/03.
//

import CoreUtil

final class RegexTesterViewController: ToolPageViewController {
    private let cell = RegexTesterView()
    
    @RestorableState("regex.pattern") var pattern = #"\d+.\d"#
    @RestorableState("regex.sample") var text = #"100, 3.141, "Hello World""#
    
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

final private class RegexTesterView: ToolPage {
    let regexField = TextField(showCopyButton: false)
    let textView = RegexTextView()
    
    override func layout() {
        super.layout()
        self.textView.snp.remakeConstraints{ make in
            make.height.equalTo(max(240, self.frame.height - 150))
        }
    }
    
    override func onAwake() {
        self.title = "Regex Tester"
        
        self.regexField.isError = true
        self.regexField.font = .monospacedSystemFont(ofSize: R.Size.controlTitleFontSize, weight: .regular)
        self.addSection(Section(title: "Reguler expression", items: [regexField]))
        self.addSection(Section(title: "Text", items: [textView]))
    }
}
