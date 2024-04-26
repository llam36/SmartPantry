//
//  ContentView.swift
//  DashBoard
//
//  Created by Tuan Cai on 4/21/24.
//
import SwiftUI
import Charts

struct ContentView: View {
    @State private var selectedCount: Int?
    @State private var selectedSector: String?
    @State private var selectedDate = Date()
    @State private var views: [(name: String, seconds: Double)] = []

    private func findSelectedSector(value: Int) -> String? {
        var accumulatedSeconds = 0
        let view = views.first { (_, seconds) in
            accumulatedSeconds += Int(seconds)
            return value <= accumulatedSeconds
        }
        return view?.name
    }
    
    var body: some View {
        ScrollView {
            VStack {
                DatePicker(
                    "Date:",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .foregroundColor(.white)
                .fontWeight(.bold)
                .padding()
                
                if !views.isEmpty {
                    VStack {
                        HStack{
                            Spacer()
                            HStack{
                                Spacer()
                                Button(action: {
                                    views = FileProcessor.processLogFile(selectedDate: selectedDate)
                                }) {
                                    Text("Refresh")
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                }
                                .padding()
                            }
                        }
                        Chart {
                            ForEach(views, id: \.name) { view in
                                let percentage = (view.seconds / views.map(\.seconds).reduce(0, +)) * 100
                                SectorMark(
                                    angle: .value("Cup", view.seconds),
                                    innerRadius: .ratio(0.65),
                                    angularInset: 6.0
                                )
                                .opacity(selectedSector == nil ? 1.0 : (selectedSector == view.name ? 1.0 : 0.5))
                                .foregroundStyle(by: .value("Type", view.name))
                                .cornerRadius(10.0)
                                .annotation(position: .overlay) {
                                            if percentage > 0 {
                                                VStack {
                                                    Text("\(String(format: "%.1f", percentage))%")
                                                        .font(.caption)
                                                        .fontWeight(.bold)
                                                        .foregroundColor(.white)
                                                }
                                            }
                                        }
                            }
                        }
                        .chartLegend(position: .bottom, alignment: .center, spacing: 25)
                        .frame(width: UIScreen.main.bounds.width - 60, height: 500)
                        .chartAngleSelection(value: $selectedCount)
                        .onChange(of: selectedCount) { _, newValue in
                            if let newValue {
                                selectedSector = findSelectedSector(value: newValue)
                            } else {
                                selectedSector = nil
                            }
                        }
                        .padding()
                    }
                }
                
                if !views.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Views:")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        ForEach(views, id: \.name) { view in
                            Card(name: view.name, seconds: view.seconds)
                                .padding(.horizontal)
                        }
                    }
                    .padding()
                    .frame(width: UIScreen.main.bounds.width - 20)
                    .cornerRadius(10)
                }
            }
        }
        .background(
            Image("dashboard-background")
                .resizable()
                .scaledToFill()
                .blur(radius: 10)
                .edgesIgnoringSafeArea(.all)
                .colorMultiply(Color.gray.opacity(0.5))
        )
        .onChange(of: selectedDate) { newDate in
            print(newDate)
            print(selectedDate)
            views = FileProcessor.processLogFile(selectedDate: newDate)
        }
    }
}

struct Card: View {
    let name: String
    let seconds: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("\(name): \(String(format: "%.1f", seconds)) seconds")
                .padding()
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .background(Color(red: 0, green: 144 / 255, blue: 0, opacity: 0.55))
        .cornerRadius(10)
    }
}

#Preview {
    ContentView()
}
