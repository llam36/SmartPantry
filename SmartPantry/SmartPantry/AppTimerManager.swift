//
//  AppTimerManager.swift
//  SmartPantry
//
//  Created by Long Lam on 4/26/24.
//
import Combine
import Foundation

class AppTimerManager: ObservableObject {
    var timerSubscription: AnyCancellable?

    init() {
        setupTimer()
    }

    func setupTimer() {
        timerSubscription = Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.uploadLogFile()
            }
    }

    func uploadLogFile() {
        guard let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("logs.log") else {
            print("Log file URL could not be constructed.")
            return
        }

        // put URL of server
        guard let url = URL(string: "https://alpine-dogfish-402322.ue.r.appspot.com/upload") else {
            print("Server URL is invalid.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Ensure the file exists before trying to upload
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("Log file does not exist.")
            return
        }

        do {
            let fileData = try Data(contentsOf: fileURL)
            print(fileData)
            let session = URLSession.shared
            let task = session.uploadTask(with: request, from: fileData) { data, response, error in
                if let error = error {
                    print("Upload failed with error: \(error.localizedDescription)")
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("File uploaded successfully.")
                    print(httpResponse)
                } else {
                    print("Upload failed with response: \(response!)")
                }
            }
            task.resume()
        } catch {
            print("Failed to read file data: \(error.localizedDescription)")
        }
    }

    deinit {
        timerSubscription?.cancel()
    }
}
