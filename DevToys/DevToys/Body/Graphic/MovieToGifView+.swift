//
//  MovieToGifView.swift
//  DevToys
//
//  Created by yuki on 2022/02/20.
//

import CoreUtil

final class MovieToGifViewController: NSViewController {
    private let cell = MovieToGitView()
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        
    }
}

final private class MovieToGifView: Page {
    override func onAwake() {
        
    }
}
