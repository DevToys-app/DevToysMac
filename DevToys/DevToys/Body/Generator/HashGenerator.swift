//
//  HashGenerator.swift
//  DevToys
//
//  Created by yuki on 2022/02/01.
//

import CoreUtil
import CryptoSwift

final class HashGeneratorViewController: NSViewController {
    private let cell = HashGeneratorView()
    
    @RestorableState("hash.upper") var isUppercase = false
    @RestorableState("hash.input") var input = "Hello World"
    @RestorableState("hash.md5") var md5 = ""
    @RestorableState("hash.sha1") var sha1 = ""
    @RestorableState("hash.sha256") var sha256 = ""
    @RestorableState("hash.sha512") var sha512 = ""
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        self.updateHash()
        
        self.$isUppercase.sink{[unowned self] in self.cell.formatSwitch.isOn = $0 }.store(in: &objectBag)
        self.$input.sink{[unowned self] in self.cell.textInputSection.string = $0 }.store(in: &objectBag)
        self.$md5.sink{[unowned self] in self.cell.md5Section.string = $0 }.store(in: &objectBag)
        self.$sha1.sink{[unowned self] in self.cell.sha1Section.string = $0 }.store(in: &objectBag)
        self.$sha256.sink{[unowned self] in self.cell.sha256Section.string = $0 }.store(in: &objectBag)
        self.$sha512.sink{[unowned self] in self.cell.sha512Section.string = $0 }.store(in: &objectBag)
        
        self.cell.textInputSection.stringPublisher
            .sink{[unowned self] in self.input = $0; updateHash() }.store(in: &objectBag)
        self.cell.formatSwitch.isOnPublisher
            .sink{[unowned self] in self.isUppercase = $0; updateHash() }.store(in: &objectBag)
    }
    
    private func updateHash() {
        self.md5 = isUppercase ? input.md5().uppercased() : input.md5()
        self.sha1 = isUppercase ? input.sha1().uppercased() : input.sha1()
        self.sha256 = isUppercase ? input.sha256().uppercased() : input.sha256()
        self.sha512 = isUppercase ? input.sha512().uppercased() : input.sha512()
    }
}

final class HashGeneratorView: Page {
    let formatSwitch = NSSwitch()
    
    let textInputSection = TextViewSection(title: "Input".localized(), options: .all)
    
    let md5Section = TextFieldSection(title: "MD5", isEditable: false)
    let sha1Section = TextFieldSection(title: "SHA1", isEditable: false)
    let sha256Section = TextFieldSection(title: "SHA256", isEditable: false)
    let sha512Section = TextFieldSection(title: "SHA512", isEditable: false)
    
    private lazy var formatNumberArea = Area(icon: R.Image.format, title: "Uppercase".localized(), control: formatSwitch)
    private lazy var configurationSection = Section(title: "Configuration".localized(), items: [formatNumberArea])

    override func onAwake() {        
        self.addSection(configurationSection)
        
        self.addSection(textInputSection)
        self.textInputSection.snp.remakeConstraints{ make in
            make.height.equalTo(180)
        }
        
        self.addSection(md5Section)
        self.addSection(sha1Section)
        self.addSection(sha256Section)
        self.addSection(sha512Section)
    }
}

extension NSSwitch {
    var isOn: Bool {
        get { self.state == .on } set { self.state = newValue ? .on : .off }
    }
    
    var isOnPublisher: AnyPublisher<Bool, Never> {
        self.actionPublisher.map{_ in self.state == .on }.eraseToAnyPublisher()
    }
}
