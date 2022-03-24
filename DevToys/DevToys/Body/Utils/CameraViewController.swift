//
//  ViewController.swift
//  macOS Camera
//
//  Created by Mihail Șalari. on 4/24/17.
//  Copyright © 2017 Mihail Șalari. All rights reserved.
//

import CoreUtil
import AVFoundation

final class CameraManager {
    
    let videoSession = AVCaptureSession()
    
    private var cameraDevice: AVCaptureDevice!
    private let sessionQueue = DispatchQueue(label: "buffer.queue")
    private var isPrepared = false
    
    func startSession(_ delegate: AVCaptureVideoDataOutputSampleBufferDelegate) {
        if !isPrepared {
            self.prepareCamera(delegate)
            isPrepared = true
        }
        if !videoSession.isRunning { videoSession.startRunning() }
    }
    
    func stopSession() {
        if videoSession.isRunning { videoSession.stopRunning() }
    }
    
    private func findCameraDevice() -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        guard let device = discoverySession.devices.first, device.hasMediaType(AVMediaType.video) else { return nil }
        return device
    }
    
    private func prepareCamera(_ delegate: AVCaptureVideoDataOutputSampleBufferDelegate) {
        guard let device = self.findCameraDevice() else { return }
        self.cameraDevice = device
        self.videoSession.sessionPreset = .photo
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if videoSession.canAddInput(input) { videoSession.addInput(input) }
        } catch {
            print(error.localizedDescription)
        }
               
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(delegate, queue: sessionQueue)
        if videoSession.canAddOutput(videoOutput) { videoSession.addOutput(videoOutput) }
    }
}

extension AVAuthorizationStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notDetermined: return "notDetermined"
        case .restricted: return "restricted"
        case .denied: return "denied"
        case .authorized: return "authorized"
        @unknown default: fatalError()
        }
    }
}
