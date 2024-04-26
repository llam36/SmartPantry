//
//  ProfileView.swift
//  SmartPantry
//
//  Created by Long Lam on 3/6/24.
//

import SwiftUI
import os

struct ProfileView: View {
    @State private var startTime = Date()

    var body: some View {
        Text("Your profile!").onAppear{
            startTime = Date()
        }.onDisappear{
            let timeSpent = Date().timeIntervalSince(startTime)
            logTimeSpent(viewName: "ProfileView", timeSpent: timeSpent)
        }
    }

    private func logTimeSpent(viewName: String, timeSpent: TimeInterval) {
        let logMessage = "Time spent on \(viewName): \(timeSpent) seconds"
        let log = OSLog(subsystem: "com.SmartPantry.SmartPantry", category: "UserInteraction")
        os_log("%{public}@", log: log, type: .info, logMessage)
        appendLogToFile(logMessage: logMessage)
    }

    private func logCurrentSectionTime() {
        let currentSection = "ProfileView"
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

#Preview {
    ProfileView()
}
