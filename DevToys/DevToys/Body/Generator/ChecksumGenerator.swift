//
//  ChecksumGenerator.swift
//  DevToys
//
//  Created by yuki on 2022/02/04.
//

import CoreUtil

final class ChecksumGeneratorViewController: PageViewController {
    
    @RestorableState("checksum.uppercase") private var isUppercase = false
    @RestorableState("checksum.alg") private var hashAlgorithm = HashAlgorithm.md5
    @RestorableState("checksum.comparer") private var comparer = ""
    
    @Observable private var output = ""
    @Observable var isError = true
    @Observable var fileURL: URL?
    
    private let cell = ChecksumGeneratorView()
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        self.$isUppercase
            .sink{[unowned self] in cell.formatSwitch.isOn = $0 }.store(in: &objectBag)
        self.$hashAlgorithm
            .sink{[unowned self] in cell.hashAlgorithmPicker.selectedItem = $0 }.store(in: &objectBag)
        self.$output
            .sink{[unowned self] in cell.outputFieldSection.string = $0 }.store(in: &objectBag)
        self.$comparer
            .sink{[unowned self] in cell.compareFieldSection.string = $0 }.store(in: &objectBag)
        self.$isError
            .sink{[unowned self] in cell.compareFieldSection.textField.isError = $0 }.store(in: &objectBag)
        
        self.cell.formatSwitch.isOnPublisher
            .sink{[unowned self] in self.isUppercase = $0; updateHash() }.store(in: &objectBag)
        self.cell.hashAlgorithmPicker.itemPublisher
            .sink{[unowned self] in self.hashAlgorithm = $0; updateHash() }.store(in: &objectBag)
        self.cell.compareFieldSection.stringPublisher
            .sink{[unowned self] in self.comparer = $0; updateComparer() }.store(in: &objectBag)
        self.cell.fileSection.urlsPublisher.compactMap{ $0.first }
            .sink{[unowned self] in fileURL = $0; self.updateHash() }.store(in: &objectBag)
    }
    
    private func updateHash() {
        guard let url = self.fileURL, let data = try? Data(contentsOf: url) else { return NSSound.beep() }
        
        switch hashAlgorithm {
        case .md5: self.output = data.md5().hexString(uppercase: isUppercase)
        case .sha1: self.output = data.sha1().hexString(uppercase: isUppercase)
        case .sha256: self.output = data.sha256().hexString(uppercase: isUppercase)
        case .sha384: self.output = data.sha384().hexString(uppercase: isUppercase)
        case .sha512: self.output = data.sha512().hexString(uppercase: isUppercase)
        }
        self.updateComparer()
    }
    
    private func updateComparer() {
        self.isError = comparer.lowercased() != output.lowercased()
    }
}

extension Data {
    func hexString(uppercase: Bool) -> String {
        self.map{ String($0, radix: 16, uppercase: uppercase) }.joined()
    }
}

private enum HashAlgorithm: String, TextItem {
    case md5 = "MD5"
    case sha1 = "SHA1"
    case sha256 = "SHA256"
    case sha384 = "SHA384"
    case sha512 = "SHA512"
    var title: String { rawValue }
}

final private class ChecksumGeneratorView: Page {
    let formatSwitch = NSSwitch()
    let hashAlgorithmPicker = EnumPopupButton<HashAlgorithm>()
    let fileSection = FileDropSection()
    let outputFieldSection = TextFieldSection(title: "Output", isEditable: false)
    let compareFieldSection = TextFieldSection(title: "Output Comparer", isEditable: true)
    
    private lazy var formatNumberArea = Area(icon: R.Image.format, title: "Uppercase", control: formatSwitch)
    private lazy var hashAlgorithmArea = Area(icon: R.Image.convert, title: "Hash Algorithm", message: "Select which algorithm you want to use", control: hashAlgorithmPicker)
    private lazy var configurationSection = Section(title: "Configuration", items: [
        formatNumberArea,
        hashAlgorithmArea
    ])
        
    override func onAwake() {
        self.title = "Checksum Generator"
        
        self.addSection(configurationSection)
        self.addSection(fileSection)
        
        self.addSection(outputFieldSection)
        self.addSection(compareFieldSection)
    }
}
