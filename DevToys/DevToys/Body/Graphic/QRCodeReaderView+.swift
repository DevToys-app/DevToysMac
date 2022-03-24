//
//  QRCodeReaderView+.swift
//  DevToys
//
//  Created by yuki on 2022/02/28.
//

import CoreUtil
import AVFoundation

final class QRCodeReaderViewController: NSViewController {
    private let cell = QRCodeReaderView()
    
    @RestorableState("qrcoder.inputtype") var inputType: QRCodeInputType = .photo
    
    @Observable var image: CIImage? = nil
    @Observable var detectedBound: CIQRCodeFeature?
    @Observable var detectedMessage: String = ""
    
    private let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: nil)!
    private let detectionQueue = DispatchQueue(label: "qr.code.detector", qos: .userInteractive, attributes: .concurrent)
    private let cameraManager = CameraManager()
    private var lastUpdate = Date()
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        self.cell.imageDropView.imagePublisher
            .sink{[unowned self] in self.image = $0.image.ciImage; updateDetection() }.store(in: &objectBag)
        self.cell.inputTypePicker.itemPublisher
            .sink{[unowned self] in self.inputType = $0; updateCameraState() }.store(in: &objectBag)
        
        self.$image.map{ $0.map{ NSImage(ciImage: $0) } }
            .sink{[unowned self] in self.cell.imageDropView.image = $0 }.store(in: &objectBag)
        self.$detectedBound
            .sink{[unowned self] in self.cell.imageDropView.detectionBounds = $0 }.store(in: &objectBag)
        self.$detectedMessage
            .sink{[unowned self] in self.cell.outputTextView.string = $0 }.store(in: &objectBag)
        self.$inputType
            .sink{[unowned self] in self.cell.inputTypePicker.selectedItem = $0 }.store(in: &objectBag)
    }
    
    private func updateCameraState() {
        self.image = nil
        self.detectedBound = nil
        self.detectedMessage = ""
        switch self.inputType {
        case .photo:
            self.cameraManager.stopSession()
        case .camera:
            self.cameraManager.startSession(self)
        }
    }
    
    override func viewDidAppear() {
        if self.inputType == .camera { self.cameraManager.startSession(self) }
    }
    override func viewDidDisappear() {
        self.cameraManager.stopSession()
    }
    
    private func updateDetection() {
        guard abs(lastUpdate.timeIntervalSinceNow) > 1 else { return }
        guard let image = image else { detectedBound = nil; return }
        
        self.lastUpdate = Date()
        self.readQRCode(image)
            .receive(on: .main)
            .sink{[self] in
                guard let feature = $0 else { detectedBound = nil; return }
                
                self.detectedBound = feature
                self.detectedMessage = feature.messageString ?? ""
            }
    }
    
    private func readQRCode(_ ciImage: CIImage) -> Promise<CIQRCodeFeature?, Never> {
        .async(on: detectionQueue){ self.detector.features(in: ciImage).first as? CIQRCodeFeature }
    }
}

extension QRCodeReaderViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.videoOrientation = .portrait
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        DispatchQueue.main.async {
            guard self.inputType == .camera else { return }
            self.image = CIImage(cvPixelBuffer: pixelBuffer).oriented(.upMirrored)
            self.updateDetection()
        }
    }
}

enum QRCodeInputType: String, TextItem {
    case photo = "Photo"
    case camera = "Camera"
    
    var title: String { rawValue }
}

final private class QRCodeReaderView: Page {
    
    let inputTypePicker = EnumPopupButton<QRCodeInputType>()
    let imageDropView = QRImageDropView()
    let outputTextView = TextViewSection(title: "Output".localized(), options: .defaultOutput)
    
    override func layout() {
        super.layout()
        
        self.outputTextView.snp.updateConstraints{ make in
            make.height.equalTo(max(240, self.frame.height - 200))
        }
    }
    
    override func onAwake() {
        self.addSection(Section(title: "Configuration".localized(), items: [
            Area(icon: R.Image.paramators, title: "QR Code Input Type", control: inputTypePicker)
        ]))
        self.addSection2(
            Section(title: "Input".localized(), items: [imageDropView]),
            outputTextView
        )
        
        self.imageDropView.snp.makeConstraints{ make in
            make.height.equalTo(320)
        }
    }
}

final private class QRImageDropView: ImageDropView {
    var detectionBounds: CIQRCodeFeature? = nil { didSet { updateDetectionBounds() } }
    
    private func updateDetectionBounds() {
        guard let image = self.image, let detectionBounds = detectionBounds else {
            return self.detectedBoundLayer.isHidden = true
        }
        self.detectedBoundLayer.isHidden = false
        
        let scale = image.size.aspectFitRatio(fitInside: imageView.frame.size)
        let imageRect = CGRect(center: imageView.bounds.center, size: image.size * scale)
        
        let path = CGMutablePath()
        path.move(to: imageRect.origin + detectionBounds.topLeft * scale)
        path.addLine(to: imageRect.origin + detectionBounds.bottomLeft * scale)
        path.addLine(to: imageRect.origin + detectionBounds.bottomRight * scale)
        path.addLine(to: imageRect.origin + detectionBounds.topRight * scale)
        path.closeSubpath()
        
        detectedBoundLayer.path = path
    }
    
    override func layout() {
        super.layout()
        updateDetectionBounds()
    }
    
    private let detectedBoundView = NSView()
    private let detectedBoundLayer = CAShapeLayer.animationDisabled()
    
    override func onAwake() {
        super.onAwake()
        
        self.wantsLayer = true
        self.imageView.addSubview(detectedBoundView)
        self.imageView.snp.remakeConstraints{ make in
            make.top.bottom.equalToSuperview().inset(16)
            make.centerX.equalToSuperview()
        }
        self.detectedBoundView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
        self.detectedBoundView.wantsLayer = true
        self.detectedBoundLayer.lineWidth = 5
        self.detectedBoundLayer.strokeColor = NSColor.yellow.cgColor
        self.detectedBoundLayer.fillColor = nil
        self.detectedBoundView.layer?.addSublayer(detectedBoundLayer)
    }
}

extension NSImage {
    var ciImage: CIImage? {
        self.cgImage.map{ CIImage(cgImage: $0) }
    }
    
    convenience init(ciImage: CIImage) {
        let rep = NSCIImageRep(ciImage: ciImage)
        self.init(size: rep.size)
        self.addRepresentation(rep)
    }
}
