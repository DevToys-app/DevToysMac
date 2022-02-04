//
//  ChecksumGenerator.swift
//  DevToys
//
//  Created by yuki on 2022/02/04.
//

import CoreUtil

final class ChecksumGeneratorViewController: PageViewController {
    private let cell = ChecksumGeneratorView()
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        
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
    
    private lazy var formatNumberArea = Area(icon: R.Image.format, title: "Uppercase", control: formatSwitch)
    private lazy var hashAlgorithmArea = Area(icon: R.Image.convert, title: "Hash Algorithm", message: "Select which algorithm you want to use", control: hashAlgorithmPicker)
    private lazy var configurationSection = Section(title: "Configuration", items: [
        formatNumberArea,
        hashAlgorithmArea
    ])
        
    override func onAwake() {
        self.title = "Checksum Generator"
        
        self.addSection(configurationSection)
    }
}
