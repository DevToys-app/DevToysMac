//
//  ImageBoxView.swift
//  DevToys
//
//  Created by yuki on 2022/02/25.
//

import CoreUtil
import AppKit

protocol DragImageViewDelegate: NSObjectProtocol {
    func dragImageView(_ dragImageView: DragImageView, draggingFilenameFor image: NSImage) -> String
}

final class DragImageViewBlockDelegate: NSObject, DragImageViewDelegate {
    private let filename: () -> String
    
    init(_ filename: @escaping () -> String) { self.filename = filename }
    
    func dragImageView(_ dragImageView: DragImageView, draggingFilenameFor image: NSImage) -> String { filename() }
}

final class DragImageView: NSLoadImageView, NSDraggingSource {

    weak var delegate: DragImageViewDelegate?
    
    private var mouseDownLocation: CGPoint?
    private static let temporaryDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("DragDropImageView") => {
        try? FileManager.default.createDirectory(at: $0, withIntermediateDirectories: true, attributes: nil)
    }
    
    override func onAwake() {
        self.isEnabled = true
    }

    func draggingSession(_: NSDraggingSession, sourceOperationMaskFor _: NSDraggingContext) -> NSDragOperation {
        return NSDragOperation.copy
    }

    func draggingSession(_: NSDraggingSession, endedAt _: NSPoint, operation: NSDragOperation) {}

    override func mouseDown(with event: NSEvent) {
        self.mouseDownLocation = event.location(in: self)
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard let delegate = self.delegate else { return }
        guard let mouseDownLocation = mouseDownLocation else { return }
        
        let dragPoint = event.locationInWindow
        let dragDistance = hypot(mouseDownLocation.x - dragPoint.x, mouseDownLocation.y - dragPoint.y)
        
        if dragDistance < 3 { return }

        guard let image = self.image else { return }
        
        let filename = delegate.dragImageView(self, draggingFilenameFor: image)
        let imageURL = Self.temporaryDirectory.appendingPathComponent(filename)
        
        try! image.tiffRepresentation?.write(to: imageURL)

        let draggingItem = NSDraggingItem(pasteboardWriter: imageURL as NSURL)

        let draggingFrame = bounds
        draggingItem.draggingFrame = draggingFrame
        draggingItem.imageComponentsProvider = {
            let component = NSDraggingImageComponent(key: NSDraggingItem.ImageComponentKey.icon)
            component.contents = image
            component.frame = draggingFrame
            return [component]
        }
        beginDraggingSession(with: [draggingItem], event: event, source: self)
    }
}
