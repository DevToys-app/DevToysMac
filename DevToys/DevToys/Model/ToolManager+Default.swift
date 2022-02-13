//
//  ToolManager+Default.swift
//  DevToys
//
//  Created by yuki on 2022/02/13.
//

import CoreUtil

extension ToolManager {
    static let shared = ToolManager() => { toolManager in
        toolManager.registerTool(.home)

        toolManager.registerTool(.jsonYamlConverter)
        toolManager.registerTool(.numberBaseConverter)
        toolManager.registerTool(.dateConverter)

        toolManager.registerTool(.htmlCoder)
        toolManager.registerTool(.urlCoder)
        toolManager.registerTool(.base64Coder)
        toolManager.registerTool(.jwtCoder)

        toolManager.registerTool(.jsonFormatter)
        toolManager.registerTool(.xmlFormatter)

        toolManager.registerTool(.hashGenerator)
        toolManager.registerTool(.uuidGenerator)
        toolManager.registerTool(.loremIpsumGenerator)
        toolManager.registerTool(.checksumGenerator)

        toolManager.registerTool(.textInspector)
        toolManager.registerTool(.regexTester)
        toolManager.registerTool(.hyphenationRemover)

        toolManager.registerTool(.imageOptimizer)
        toolManager.registerTool(.pdfGenerator)
        toolManager.registerTool(.imageConverter)
    }
}
