//
//  AppWindowController.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import Cocoa

final class AppWindowController: NSWindowController {
    let appModel = AppModel()
    
    override func windowDidLoad() {
        self.appModel.toolManager.registerTool(.home)
        
        self.appModel.toolManager.registerTool(.jsonYamlConverter)
        self.appModel.toolManager.registerTool(.numberBaseConverter)
        self.appModel.toolManager.registerTool(.dateConverter)
        
        self.appModel.toolManager.registerTool(.htmlCoder)
        self.appModel.toolManager.registerTool(.urlCoder)
        self.appModel.toolManager.registerTool(.base64Coder)
        self.appModel.toolManager.registerTool(.jwtCoder)
        
        self.appModel.toolManager.registerTool(.jsonFormatter)
        self.appModel.toolManager.registerTool(.xmlFormatter)
        
        self.appModel.toolManager.registerTool(.hashGenerator)
        self.appModel.toolManager.registerTool(.uuidGenerator)
        self.appModel.toolManager.registerTool(.loremIpsumGenerator)
        self.appModel.toolManager.registerTool(.checksumGenerator)
        
        self.appModel.toolManager.registerTool(.textInspector)
        self.appModel.toolManager.registerTool(.regexTester)
        self.appModel.toolManager.registerTool(.hyphenationRemover)
        
        self.contentViewController?.chainObject = appModel
        
        appModel.$tool
            .sink{[unowned self] in self.window?.title = $0.title }.store(in: &objectBag)
    }
}
