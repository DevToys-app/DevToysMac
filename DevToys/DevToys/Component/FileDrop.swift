//
//  FileDrop.swift
//  DevToys
//
//  Created by yuki on 2022/02/02.
//

import CoreUtil

final class FileDropSection: Section {
    
    var urlsPublisher: AnyPublisher<[URL], Never> {
        fileDrop.urlsPublisher.merge(with: openButton.urlPublisher.map{ [$0] }).eraseToAnyPublisher()
    }
    
    private let fileDrop = FileDrop()
    private let openButton = OpenSectionButton(title: "Open".localized(), image: R.Image.open)
    
    override func onAwake() {
        super.onAwake()
        self.title = "File".localized()
        self.addToolbarItem(openButton)
        self.addStackItem(fileDrop)
        self.snp.makeConstraints{ make in
            make.height.equalTo(160)
        }
    }
}

final class FileDrop: NSLoadView {
    
    let urlsPublisher = PassthroughSubject<[URL], Never>()
    
    private let backgroundLayer = ControlBackgroundLayer.animationDisabled()
    private let imageView = NSImageView(image: R.Image.drop)
    private let titleLabel = NSTextField(labelWithString: "Drop Files Here".localized())
    private let stackView = NSStackView()
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        sender.draggingPasteboard.canReadTypes([.fileURL]) ? .copy : .none
    }
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let urls = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] else { return false }
        urlsPublisher.send(urls)
        return true
    }
    
    override func layout() {
        super.layout()
        self.backgroundLayer.frame = bounds
    }
    
    override func updateLayer() {
        backgroundLayer.update()
    }

    override func onAwake() {
        self.wantsLayer = true
        self.layer?.addSublayer(backgroundLayer)
        
        self.addSubview(stackView)
        self.stackView.orientation = .vertical
        self.stackView.snp.makeConstraints{ make in
            make.center.equalToSuperview()
        }
        
        self.stackView.addArrangedSubview(imageView)
        self.stackView.addArrangedSubview(titleLabel)
        self.registerForDraggedTypes([.fileURL])
    }
}
