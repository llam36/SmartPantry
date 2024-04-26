//
//  FileProcessor.swift
//  DashBoard
//
//  Created by Tuan Cai on 4/23/24.
//

// FileProcessor.swift
// DashBoard

import Foundation

class FileProcessor {
    static func processLogFile(selectedDate: Date) -> [(name: String, seconds: Double)] {
        guard let fileURL = Bundle.main.url(forResource: "logs", withExtension: "txt") else {
            print("logs.txt file not found.")
            return []
        }
        
        do {
            print("passed in SelectedDate = \(selectedDate)")
            let fileContent = try String(contentsOf: fileURL)
            return processContent(fileContent, selectedDate: selectedDate)
        } catch {
            print("Error reading file: \(error)")
            return []
        }
    }
    
    private static func processContent(_ content: String, selectedDate: Date) -> [(name: String, seconds: Double)] {
        // Split the content into lines
        let lines = content.components(separatedBy: .newlines)
        
        // Filter out lines based on the selected date
        let filteredLines = lines.filter { line in
            guard let lineDate = line.components(separatedBy: ",").first,
                  let lineDateFormatted = DateFormatter(dateFormat: "M/dd/yy").date(from: lineDate) else {
                return false
            }
            return Calendar.current.isDate(selectedDate, inSameDayAs: lineDateFormatted)
        }
        
        // Dictionary to store the sum of seconds for each screen
        var screenSum: [String: Double] = [:]
        
        // Iterate through each line in the content
        for line in filteredLines {
            // Check if the line contains any of the specified screen names
            for screenName in ["ExpiringItemCardSection", "PantryView", "ExpirationView", "ProfileView", "NotificationView", "ExpiringItemScrollSection", "CameraView"] {
                if line.contains(screenName) {
                    let components = line.components(separatedBy: ":")
                    if components.count > 1 {
                        let timeString = components.last ?? ""
                        let timeComponents = timeString.components(separatedBy: .whitespaces)
                        if let timeValue = Double(timeComponents[1]) {
                            // Add the time spent to the corresponding screen's
                            screenSum[screenName, default: 0] += timeValue
                        }
                    }
                }
            }
        }
        
        for screenName in ["ExpiringItemCardSection", "PantryView", "ExpirationView", "ProfileView", "NotificationView", "ExpiringItemScrollSection", "CameraView"] {
            if screenSum[screenName] == nil {
                screenSum[screenName] = 0
            }
        }
        
        let result = screenSum.map { (name: $0.key, seconds: $0.value) }
        print(result)
        return result
    }
}

extension DateFormatter {
    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
    }
}




// Define a main function to encapsulate the executable code
//func main() {
//    print("Test file processor")
//    
//    // Create an instance of FileProcessor and call the processLogFile method
//    let fileProcessor = FileProcessor()
//    fileProcessor.processLogFile()
//}



