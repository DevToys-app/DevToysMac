//
//  PPOverlayController.swift
//  Pixel Picker
//

import Cocoa
import Carbon.HIToolbox

private let magnification = CGFloat(12)

class ACOverlayController: NSWindowController {

    // ================================================================================================== //
    // MARK: - Outlet -

    @IBOutlet weak var overlayPanel: ACOverlayPanel!
    @IBOutlet weak var wrapper: PPOverlayWrapper!
    @IBOutlet weak var preview: ACOverlayPreview!

    @IBOutlet weak var infoPanel: ACOverlayPanel!
    @IBOutlet weak var infoWrapper: NSView!
    @IBOutlet weak var infoDetailField: NSTextField!

    // ================================================================================================== //
    // MARK: - Properties -

    private var completion: (NSColor) -> Void = {_ in }
    private static let panelSizeNormal: CGFloat = 150
    private static let panelSizeLarge: CGFloat = 300
    private var panelSize: CGFloat = ACOverlayController.panelSizeNormal

    private var lastActiveApp: NSRunningApplication?
    private var lastMouseLocation = NSEvent.mouseLocation
    private var lastHighlightedColor: NSColor = NSColor.black
    private var eventMonitor: Any?

    private var isEnabled: Bool = false {
        didSet {
            if isEnabled {
                lastMouseLocation = NSEvent.mouseLocation
                startMonitoringEvents()
            } else {
                stopMonitoringEvents()
            }
        }
    }

    // ================================================================================================== //
    // MARK: - View Cycle -
    override func awakeFromNib() {
        infoDetailField.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        infoDetailField.textColor = .white
        infoWrapper.layer?.backgroundColor = #colorLiteral(red: 0.1315930784, green: 0.1315930784, blue: 0.1315930784, alpha: 1)
        infoWrapper.wantsLayer = true
        infoWrapper.layer?.cornerRadius = R.Size.corner
        infoWrapper.layer?.backgroundColor = NSColor.black.cgColor

        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) {[weak self] in
            guard let self = self else { return nil }

            if self.isEnabled { self.keyDown(with: $0) }
            return nil
        }
    }

    private var globalMonitors: [Any] = []
    private func startMonitoringEvents() {
        stopMonitoringEvents()
        globalMonitors.append(NSEvent.addGlobalMonitorForEvents(matching: [.flagsChanged]) { self.flagsChanged(with: $0) }!)
        globalMonitors.append(NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved]) { self.mouseMoved(with: $0) }!)
    }
    private func stopMonitoringEvents() {
        while globalMonitors.count > 0 { NSEvent.removeMonitor(globalMonitors.popLast()!) }
    }

    // ================================================================================================== //
    // MARK: - Control -
    override func mouseDown(with event: NSEvent) {
        hidePicker()
        pickColor()
    }

    override func keyDown(with event: NSEvent) {
        switch Int(event.keyCode) {
        case kVK_Escape:
            hidePicker()
        case kVK_Space:
            hidePicker()
            pickColor()
        default: break
        }
    }
    override func mouseMoved(with event: NSEvent) {
        if isEnabled {
            let currentMouseLocation = NSEvent.mouseLocation
            let nextMouseLocation = currentMouseLocation
            updatePreview(aroundPoint: nextMouseLocation)
            lastMouseLocation = nextMouseLocation
        }
    }

    // ================================================================================================== //
    // MARK: - Privtaes -
    private func moveByPixel(dx: CGFloat, dy: CGFloat) {
        var mouseLoc = lastMouseLocation
        let currentScreen = getScreenWithMouse()
        guard let screenFrame = currentScreen?.frame, let screenScale = currentScreen?.backingScaleFactor else {
            return
        }
        mouseLoc.x += dx / screenScale
        mouseLoc.y += dy / screenScale
        lastMouseLocation = mouseLoc
        updatePreview(aroundPoint: mouseLoc)
        mouseLoc.y = screenFrame.maxY - mouseLoc.y
        CGDisplayMoveCursorToPoint(0, mouseLoc)
    }

    func pickColor() {
        completion(lastHighlightedColor)
    }

    func showPicker(_ completion: @escaping (NSColor) -> Void) {
        self.completion = completion
        if overlayPanel.isVisible || infoPanel.isVisible { return }
        isEnabled = true
        overlayPanel.activate(withSize: panelSize, infoPanel: infoPanel)

        if NSWorkspace.shared.frontmostApplication?.bundleIdentifier != Bundle.main.bundleIdentifier {
            lastActiveApp = NSWorkspace.shared.frontmostApplication
        }

        wrapper.layer?.cornerRadius = panelSize / 2
        updatePreview(aroundPoint: NSEvent.mouseLocation)
        hideCursor()
    }

    private func hidePicker() {
        isEnabled = false

        showCursor()
        self.overlayPanel.orderOut(self)
        self.infoPanel.orderOut(self)

        if self.lastActiveApp != nil, self.lastActiveApp != NSRunningApplication.current {
            self.lastActiveApp!.activate(options: .activateAllWindows)
            self.lastActiveApp = nil
        }

        self.close()
        if let eventMonitor = eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
    }

    private func getScreenWithMouse() -> NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        let screens = NSScreen.screens
        let screenWithMouse = screens.first { NSMouseInRect(mouseLocation, $0.frame, false) }

        return screenWithMouse
    }

    private func updateInfoPanel(_ color: NSColor) {
        infoDetailField.stringValue = color.hexColorCode()
    }

    private func getScreenShot(aroundPoint point: NSPoint) -> CGImage? {
        let cgPoint = convertToCGCoordinateSystem(point)
        let rect = CGRect(x: cgPoint.x - panelSize / 2, y: cgPoint.y - panelSize / 2, width: panelSize, height: panelSize)
        return CGWindowListCreateImage(rect, [.optionOnScreenBelowWindow], CGWindowID(overlayPanel.windowNumber), .bestResolution)
    }

    private func updatePreview(aroundPoint point: NSPoint) {
        if !overlayPanel.isKeyWindow {
            overlayPanel.activate(withSize: panelSize, infoPanel: infoPanel)
            showCursor()
            hideCursor()
        }

        overlayPanel.setFrameOrigin(NSPoint(x: point.x - (panelSize / 2), y: point.y - (panelSize / 2)))
        let normalisedPoint = NSPoint(x: round(point.x * 2) / 2, y: round(point.y * 2) / 2)
        guard let screenShot = getScreenShot(aroundPoint: normalisedPoint) else { return }

        let zoomReciprocal: CGFloat = 1.0 / magnification
        let currentSize = CGFloat(screenShot.width) + 1
        let origin = floor(currentSize * ((1 - zoomReciprocal) / 2))
        let x = origin + (isHalf(normalisedPoint.x) ? 1 : 0)
        let y = origin + (isHalf(normalisedPoint.y) ? 1 : 0)

        let zoomedSize = floor(ensureOdd(currentSize * zoomReciprocal))
        let croppedRect = CGRect(x: x, y: y, width: zoomedSize, height: zoomedSize)
        let zoomedImage: CGImage = screenShot.cropping(to: croppedRect)!
        let pixelSize = panelSize / zoomedSize

        return updatePreview(zoomedImage, pixelSize, zoomedSize)
    }

    private func updatePreview(_ image: CGImage, _ pixelSize: CGFloat, _ numberOfPixels: CGFloat) {
        let middlePosition = numberOfPixels / 2

        let colorAtPixel = image.colorAt(x: Int(middlePosition), y: Int(middlePosition))
        let contrastingColor = colorAtPixel.bestContrastingColor()

        updateInfoPanel(colorAtPixel)

        preview.layer?.contents = image
        preview.updateCrosshair(pixelSize, middlePosition, contrastingColor.cgColor)
        preview.updateGrid(cellSize: pixelSize, numberOfCells: Int(numberOfPixels), shouldDisplay: true)

        lastHighlightedColor = colorAtPixel
    }
}

extension NSColor {
    public func hexColorCode() -> String {
        String(format: "%02X%02X%02X", Int(round(self.redComponent * 255)), Int(round(self.greenComponent * 255)), Int(round(self.blueComponent * 255)))
    }
    
    public convenience init?(colorSpace: NSColorSpace, hexColorCode: String) {
        guard hexColorCode.count == 6 else { return nil }
        
        let scanner = Scanner(string: hexColorCode)
        var value = UInt64.zero
        scanner.scanHexInt64(&value)
        
        let r = CGFloat((value & 0xFF0000) >> 16) / 255
        let g = CGFloat((value & 0x00FF00) >>  8) / 255
        let b = CGFloat((value & 0x0000FF) >>  0) / 255
        
        self.init(colorSpace: colorSpace, red: r, green: g, blue: b, alpha: 1)
    }
}
