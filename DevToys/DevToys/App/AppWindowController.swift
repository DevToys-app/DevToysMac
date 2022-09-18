//
//  AppWindowController.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import CoreUtil
import Darwin
import AppKit

final class AppWindowController: NSWindowController {
    private let appModel = AppModel()
    
    private lazy var separatorItem = NSTrackingSeparatorToolbarItem(
        identifier: AppWindowController.separatorItemIdentifier, splitView: splitViewController.splitView, dividerIndex: 0
    )
    private lazy var disclosureItem = NSToolbarItem(
        itemIdentifier: AppWindowController.disclosureItemIdentifier
    )
    private var splitViewController: NSSplitViewController {
        self.window?.contentViewController as! NSSplitViewController
    }
    
    @objc private func toggleSidebar() {
        splitViewController.splitViewItems[0].animator().isCollapsed.toggle()
    }
    
    override func windowDidLoad() {        
        self.contentViewController?.chainObject = appModel
        
        self.appModel.settings.$appearanceType
            .sink{
                switch $0 {
                case .useSystemSettings: self.window?.appearance = nil
                case .darkMode: self.window?.appearance = NSAppearance(named: .darkAqua)
                case .lightMode: self.window?.appearance = NSAppearance(named: .aqua)
                }
            }
            .store(in: &objectBag)
        self.appModel.$tool
            .sink{[unowned self] in self.window?.title = $0.title }.store(in: &objectBag)
        
        guard let toolbar = self.window?.toolbar else { return assertionFailure() }
        toolbar.delegate = self
        toolbar.allowsUserCustomization = true

        disclosureItem.view = NSButton(title: "Sidebar", image: R.Image.sidebarDisclosure) => {
            $0.bezelStyle = .texturedRounded
            $0.actionPublisher.sink{[unowned self] in toggleSidebar() }.store(in: &objectBag)
        }
    }
}

extension AppWindowController: NSToolbarDelegate {
    
    static let separatorItemIdentifier = NSToolbarItem.Identifier("separator")
    static let disclosureItemIdentifier = NSToolbarItem.Identifier("disclosure")
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        if #available(macOS 11.0, *) {
            return [AppWindowController.disclosureItemIdentifier, AppWindowController.separatorItemIdentifier]
        } else {
            return [AppWindowController.disclosureItemIdentifier]
        }
    }
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        self.toolbarDefaultItemIdentifiers(toolbar)
    }
    func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        []
    }
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        if #available(macOS 11.0, *) {
            if itemIdentifier == AppWindowController.separatorItemIdentifier {
                return self.separatorItem
            }
        }
        if itemIdentifier == AppWindowController.disclosureItemIdentifier {
            return self.disclosureItem
        }
        return nil
    }
}
