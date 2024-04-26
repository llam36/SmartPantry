//
//  CameraView.swift
//  SmartPantry
//
//  Created by Tuan Cai on 3/6/24.
//

import AVFoundation
import SwiftUI
import UIKit
import os

struct CameraView: View {
    @StateObject var camera = CameraModel()
    @EnvironmentObject var pantryItemManager: PantryItemManager
    @State private var startTime = Date()
    
    var body: some View {
        ZStack {
            CameraPreview(camera: self.camera).ignoresSafeArea(.all, edges: .all).onAppear{
                startTime = Date()
            }.onDisappear{
                let timeSpent = Date().timeIntervalSince(startTime)
                logTimeSpent(viewName: "CameraView", timeSpent: timeSpent)
            }
            VStack {
                if self.camera.isTaken {
                    HStack {
                        Spacer()
                        Button(action: self.camera.reTake, label: {
                            Image(systemName: "arrow.triangle.2.circlepath.camera").foregroundColor(.black).padding().background(Color.white).clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        }).padding(.trailing, 10)
                    }
                    Spacer()
                }
                Spacer()
                HStack {
                    if self.camera.isTaken {
                        Button(action: { if !self.camera.isSaved { self.camera.savePic(pantryItemManager: self.pantryItemManager) }}, label: {
                            Text(self.camera.isSaved ? "Processed" : "Process").foregroundColor(.black).fontWeight(.semibold).padding(.vertical, 10).padding(.horizontal, 20).background(Color.white).clipShape(Capsule())
                        }).padding(.leading)
                        Spacer()
                    } else {
                        Button(action: self.camera.takePic, label: {
                            ZStack {
                                Circle().fill(Color.white).frame(width: 65, height: 65)
                                Circle().stroke(Color.white, lineWidth: 2).frame(width: 75, height: 75)
                            }
                        })
                    }
                }.frame(height: 75)
                    .padding(.bottom, 20)
            }
        }.onAppear(perform: {
            self.camera.Check()
        })
    }
    
    private func logTimeSpent(viewName: String, timeSpent: TimeInterval) {
            let logMessage = "Time spent on \(viewName): \(timeSpent) seconds"
            let log = OSLog(subsystem: "com.SmartPantry.SmartPantry", category: "UserInteraction")
            os_log("%{public}@", log: log, type: .info, logMessage)
            appendLogToFile(logMessage: logMessage)
        }

        private func logCurrentSectionTime() {
            let currentSection = "CameraView"
            let timeSpent = Date().timeIntervalSince(startTime)
            logTimeSpent(viewName: currentSection, timeSpent: timeSpent)
        }

        private func appendLogToFile(logMessage: String) {
            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("logs.log")

            // Ensure unwrapping of the URL, since it's optional
            if let fileURL = fileURL {
                let timeStamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .long)
                let finalLogMessage = "\(timeStamp): \(logMessage)\n"

                if let data = finalLogMessage.data(using: .utf8) {
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        // Append to existing file
                        if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                            fileHandle.seekToEndOfFile()
                            fileHandle.write(data)
                            fileHandle.closeFile()
                        }
                    } else {
                        // Create new file
                        try? data.write(to: fileURL, options: .atomicWrite)
                    }
                }
            }
        }

}

import Foundation

class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var isTaken = false
    @Published var session = AVCaptureSession()
    @Published var alert = false
    @Published var output = AVCapturePhotoOutput()
    @Published var preview: AVCaptureVideoPreviewLayer!
    @Published var isSaved = false
    @Published var picData = Data(count: 0)
    
    func Check() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // Setting up session
            self.setUp()
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { status in
                if status {
                    self.setUp()
                }
            }
        case .denied:
            self.alert.toggle()
            return
        default:
            return
        }
    }
    
    func setUp() {
        // setting up the camera
        do {
            self.session.beginConfiguration()
            let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
            let input = try AVCaptureDeviceInput(device: device!)
            if self.session.canAddInput(input) {
                self.session.addInput(input)
            }
            if self.session.canAddOutput(self.output) {
                self.session.addOutput(self.output)
            }
            self.session.commitConfiguration()
            self.logCameraEvent(message: "Camera session started")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func takePic() {
        DispatchQueue.global(qos: .background).async {
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            DispatchQueue.main.async {
                withAnimation { self.isTaken.toggle()
                self.logCameraEvent(message: "Picture taken")
                }
            }
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil {
            print(error?.localizedDescription ?? "Unknown error")
            self.session.stopRunning() // Stop the session after the photo capture process has completed
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("Unable to get file data representation")
            self.session.stopRunning()
            return
        }
        self.picData = imageData
        self.session.stopRunning()
    }
    
    func reTake() {
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
            DispatchQueue.main.async {
                withAnimation { self.isTaken.toggle() }
                // clearing
                self.isSaved = false
                self.logCameraEvent(message: "Picture retaken")
            }
        }
    }
    
    func savePic(pantryItemManager: PantryItemManager) {
        // Modify this URL to your local URL
        guard let url = URL(string: "https://alpine-dogfish-402322.ue.r.appspot.com/get-pantry") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let imageData = self.picData
        let body = NSMutableData()
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpeg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body as Data
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
                    
            if response.statusCode == 200 {
                let decoder = JSONDecoder()
                do {
                    let list = try decoder.decode([PantryItemJson].self, from: data)
                    DispatchQueue.main.async {
                        pantryItemManager.addPantry(pantriesJson: list)
                        print(pantryItemManager.pantries)
                    }
                    print(list)
                } catch {
                    print(String(describing: error))
                }
                self.isSaved = true
                  
            } else {
                print("Failed to process image. Status code: \(response.statusCode)")
            }
        }
        
        task.resume()
    }
    
    private func logCameraEvent(message: String) {
            let logMessage = "\(Date()): \(message)"
            appendLogToFile(logMessage: logMessage)
        }

        private func appendLogToFile(logMessage: String) {
            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("logs.log")

            // Ensure unwrapping of the URL, since it's optional
            if let fileURL = fileURL {
                let finalLogMessage = "\(logMessage)\n"

                if let data = finalLogMessage.data(using: .utf8) {
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        // Append to existing file
                        if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                            fileHandle.seekToEndOfFile()
                            fileHandle.write(data)
                            fileHandle.closeFile()
                        }
                    } else {
                        // Create new file
                        try? data.write(to: fileURL, options: .atomicWrite)
                    }
                }
            }
        }
}

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var camera: CameraModel
    func makeUIView(context: Context) -> UIView {
        let view = UIViewType(frame: UIScreen.main.bounds)
        self.camera.preview = AVCaptureVideoPreviewLayer(session: self.camera.session)
        self.camera.preview.frame = view.frame
        self.camera.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(self.camera.preview)
        self.camera.session.startRunning()
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // No need to add any code here
    }
}

#Preview {
    CameraView()
}
