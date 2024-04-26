//
//  ContentView.swift
//  SmartPantry
//
//  Created by Long Lam on 3/4/24.
//

import AVFoundation
import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject var pantryItemManager = PantryItemManager()
    @StateObject var viewModel = AppTimerManager()
    var body: some View {
        TabView {
            Group {
                PantryView()
                    .tabItem { Label("Home", systemImage: "house") }
                    .environmentObject(pantryItemManager)
                ExpirationView()
                    .tabItem { Label("Expiration", systemImage: "calendar.badge.exclamationmark") }
                    .environmentObject(pantryItemManager)
                CameraView()
                    .tabItem { Label("Scan", systemImage: "camera.metering.matrix") }
                    .environmentObject(pantryItemManager)
                NotificationView()
                    .tabItem { Label("Notification", systemImage: "bell") }
                ProfileView()
                    .tabItem { Label("Profile", systemImage: "person") }
            }
            .toolbar(.visible, for: .tabBar)
            .toolbarBackground(Color.white, for: .tabBar)
        }
        .accentColor(Color("Green"))
        .frame(minWidth: 300, maxWidth: .infinity,
               minHeight: 300, maxHeight: .infinity)
        .onAppear {
            UITabBar.appearance().backgroundColor = UIColor(.white)
            UITabBar.appearance().unselectedItemTintColor =
            UIColor(Color.black)
        }
    }
}

#Preview {
    ContentView()
}
