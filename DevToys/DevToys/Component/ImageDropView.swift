//
//  ImageDropView.swift
//  DevToys
//
//  Created by yuki on 2022/02/28.
//

import CoreUtil

class ImageDropView: NSLoadView {
    
    var image: NSImage? {
        get { imageView.image }
        set {
            self.imageView.image = newValue
            self.dropIndicator.isHidden = newValue != nil
        }
    }
    
    let imagePublisher = PassthroughSubject<ImageItem, Never>()
    let imageView = NSImageView()
    
    private let backgroundLayer = ControlBackgroundLayer.animationDisabled()
    private let dropIndicator = DropIndicatorView(title: "Drop Image Here")
    
    override func layout() {
        super.layout()
        self.backgroundLayer.frame = bounds
    }
    
    override func updateLayer() {
        self.backgroundLayer.update()
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation { return .copy }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let images = ImageDropper.images(fromPasteboard: sender.draggingPasteboard)
        guard let image = images.first else { return false }
        
        imagePublisher.send(image)
        
        return true
    }
    
    override func onAwake() {
        self.imageView.unregisterDraggedTypes()
        self.registerForDraggedTypes([.fileURL, .URL, .fileContents])
        self.wantsLayer = true
        self.layer?.addSublayer(backgroundLayer)
        
        self.addSubview(imageView)
        self.imageView.snp.makeConstraints{ make in
            make.width.equalTo(180)
            make.top.bottom.equalToSuperview().inset(16)
            make.centerX.equalToSuperview()
        }
        
        self.addSubview(dropIndicator)
        self.dropIndicator.snp.makeConstraints{ make in
            make.center.equalToSuperview()
        }
    }
}

