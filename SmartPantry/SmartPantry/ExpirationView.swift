//
//  ExpirationView.swift
//  SmartPantry
//
//  Created by Long Lam on 3/27/24.
//

import SwiftUI
import os

struct ExpirationView: View {
    @State private var isCardViewDisplayed = true
    @State private var startTime = Date()
    var body: some View {
        VStack {
            TitleBar()
            if isCardViewDisplayed {
                ExpiringItemCardSection().onAppear{
                    startTime = Date()
                }.onDisappear{
                    let timeSpent = Date().timeIntervalSince(startTime)
                    logTimeSpent(viewName: "ExpiringItemCardSection", timeSpent: timeSpent)
                }
            } else {
                ExpiringItemScrollSection().onAppear{
                    startTime = Date()
                }.onDisappear{
                    let timeSpent = Date().timeIntervalSince(startTime)
                    logTimeSpent(viewName: "ExpiringItemScrollSection", timeSpent: timeSpent)
                }
            }

            Button(action: {
                self.logCurrentSectionTime()
                isCardViewDisplayed.toggle()
            }) {
                Text(isCardViewDisplayed ? "Show Scroll" : "Show Card")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.red)
                    .cornerRadius(10)
            }
        }
        .background(Color(white: 0.95))
    }
    
    private func logTimeSpent(viewName: String, timeSpent: TimeInterval) {
            let logMessage = "Time spent on \(viewName): \(timeSpent) seconds"
            let log = OSLog(subsystem: "com.SmartPantry.SmartPantry", category: "UserInteraction")
            os_log("%{public}@", log: log, type: .info, logMessage)
            appendLogToFile(logMessage: logMessage)
        }

        private func logCurrentSectionTime() {
            let currentSection = isCardViewDisplayed ? "ExpiringItemCardSection" : "ExpiringItemScrollSection"
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

struct ExpirationView_Previews: PreviewProvider {
    static var previews: some View {
        ExpirationView()
            .environmentObject(PantryItemManager())
    }
}
