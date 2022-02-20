//
//  ACOverlayPreview.swift
//  PixelPicker
//
//  Created by yuki on 2020/06/30.
//  Copyright © 2020 yuki. All rights reserved.
//

import Cocoa

class ACOverlayPreview: NSView, CALayerDelegate {

    private var grid: CAShapeLayer = CAShapeLayer()
    private var lastCellSize: CGFloat?
    private var lastNumberOfCells: Int?

    var crosshair: CAShapeLayer = CAShapeLayer()

    override var wantsUpdateLayer: Bool {
        get { return true }
    }

    override func awakeFromNib() {
        wantsLayer = true
        layer?.magnificationFilter = .nearest
        layer?.contentsGravity = .resizeAspectFill
        layer?.delegate = self

        // Add the grid shape layers to the view.
        grid.strokeColor = NSColor.lightGray.cgColor
        grid.fillColor = nil
        layer?.addSublayer(grid)

        // Prepare crosshair shape layers.
        crosshair.strokeColor = NSColor.black.cgColor
        crosshair.fillColor = nil
        layer?.addSublayer(crosshair)
    }

    // Update the crosshair with the correct color, position and size.
    func updateCrosshair(_ pixelSize: CGFloat, _ middle: CGFloat, _ color: CGColor) {
        let pos: CGFloat = (pixelSize * middle) - (pixelSize / 2) + 0.5
        let pixelRect = NSRect(x: pos, y: pos, width: pixelSize, height: pixelSize)

        crosshair.path = CGPath(rect: pixelRect, transform: nil)
        crosshair.strokeColor = color
        setNeedsDisplay(pixelRect)
    }

    // Redraws the grid in the preview.
    func updateGrid(cellSize size: CGFloat, numberOfCells n: Int, shouldDisplay: Bool) {
        // Disable implicit animations within this transaction.
        CATransaction.setDisableActions(true)
        grid.opacity = 0.25

        // Only redraw the grid if we need to display it and the dimensions have changed since last
        // the last time we drew it.
        guard shouldDisplay && (size != lastCellSize || n != lastNumberOfCells) else { return }
        lastCellSize = size
        lastNumberOfCells = n

        let path = NSBezierPath()
        let start = CGFloat(0) + 0.5
        let end = CGFloat(n) * size + 0.5

        for i in 1..<n {
            let pos = CGFloat(i) * size + 0.5
            path.move(to: NSPoint(x: pos, y: start))
            path.line(to: NSPoint(x: pos, y: end))
            path.move(to: NSPoint(x: start, y: pos))
            path.line(to: NSPoint(x: end, y: pos))
        }

        grid.path = path.cgPath
    }
}
