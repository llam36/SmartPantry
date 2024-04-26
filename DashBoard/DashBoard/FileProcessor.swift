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
            
            // Fetch data from URL
            let result = fetchDataFromURL()
            
            // Handle the result of fetchDataFromURL()
            switch result {
            case .success(let fileContent):
                // Process the file content
                return processContent(fileContent, selectedDate: selectedDate)
            case .failure(let error):
                // Handle the error
                print("Error fetching data: \(error)")
                return []
            }
        }
    static func fetchDataFromURL() -> Result<String, Error> {
        guard let url = URL(string: "https://alpine-dogfish-402322.ue.r.appspot.com/get-logs") else {
            return .failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil))
        }
        
        var result: Result<String, Error>!
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            defer {
                semaphore.signal()
            }
            
            if let error = error {
                result = .failure(error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                result = .failure(NSError(domain: "Invalid HTTP response", code: 0, userInfo: nil))
                return
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                result = .failure(NSError(domain: "HTTP status code: \(httpResponse.statusCode)", code: 0, userInfo: nil))
                return
            }
            
            guard let data = data else {
                result = .failure(NSError(domain: "No data received", code: 0, userInfo: nil))
                return
            }
            
            if let responseDataString = String(data: data, encoding: .utf8) {
                result = .success(responseDataString)
            } else {
                result = .failure(NSError(domain: "Failed to convert data to string", code: 0, userInfo: nil))
            }
        }
        
        task.resume()
        semaphore.wait()
        
        return result
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



