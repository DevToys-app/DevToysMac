//
//  MovieToGifView.swift
//  DevToys
//
//  Created by yuki on 2022/02/20.
//

import CoreUtil

final class GifConverterViewController: NSViewController {
    private let cell = GifConverterView()
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        
    }
}

final private class GifConverterView: Page {
    override func onAwake() {
        
    }
}
