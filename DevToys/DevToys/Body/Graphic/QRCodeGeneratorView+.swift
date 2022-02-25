//
//  QLCodeGeneratorView+.swift
//  DevToys
//
//  Created by yuki on 2022/02/23.
//

import CoreUtil
import CoreImage

final class QRCodeGeneratorViewController: NSViewController {
    private let cell = URLDecoderView()
    
    @RestorableState("qrcode.rawString") var rawString = "Hello World"
    @Observable var qrimage: NSImage? = nil
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        self.$rawString
            .sink{[unowned self] in self.cell.inputTextSection.string = $0 }.store(in: &objectBag)
        self.$qrimage
            .sink{[unowned self] in self.cell.imageView.image = $0 }.store(in: &objectBag)
        
        self.cell.inputTextSection.stringPublisher
            .sink{[unowned self] in self.rawString = $0; updateQRCode() }.store(in: &objectBag)
        
        self.updateQRCode()
    }
    
    private func updateQRCode() {
        self.qrimage = generateQRCode(from: rawString)
    }
    
    private func generateQRCode(from string: String) -> NSImage? {
        if string.isEmpty { return nil }
        
        let data = string.data(using: .utf8)
        
        guard let qrfilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        qrfilter.setValue(data, forKey: "inputMessage")
        
        let transform = CGAffineTransform(scaleX: 3, y: 3)
        
        guard let output = qrfilter.outputImage?.transformed(by: transform) else { return nil }
        
        let rep = NSCIImageRep(ciImage: output)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        return nsImage
    }
}

enum QRInputCorrectionLevel: String, TextItem {
    case high
    case medium
    case low
}

final private class URLDecoderView: Page {
    let inputTextSection = TextViewSection(title: "Input".localized(), options: .defaultInput)
    let imageView = NSImageView()
    
    override func onAwake() {
        self.addSection(inputTextSection)
        self.inputTextSection.snp.makeConstraints{ make in
            make.height.equalTo(320)
        }
        
        self.addSection(Section(title: "QR Code", items: [
            NSStackView() => {
                $0.alignment = .centerX
                $0.addArrangedSubview(imageView)
//                imageView.__setBackgroundColor(.red)
//                imageView.snp.makeConstraints{ make in
//                    make.size.equalTo(180)
//                }
            }
        ]))
    }
}

