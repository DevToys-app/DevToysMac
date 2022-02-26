//
//  FFTask.swift
//  DevToys
//
//  Created by yuki on 2022/02/21.
//

import CoreUtil

final class FFTask {
    let duration: FFTime?
    let complete: Promise<Void, Error>
    
    @Observable var progress = 0.0

    func sendReport(_ report: FFProgressReport) {
        guard let duration = duration else { return }
        let durationInterval = duration.timeInterval
        let reportInterval = report.time.timeInterval
        self.progress = reportInterval / durationInterval
    }
    
    init(duration: FFTime?, complete: Promise<Void, Error>) {
        self.duration = duration
        self.complete = complete
        
        self.complete.finally { self.progress = 1 }
    }
}

