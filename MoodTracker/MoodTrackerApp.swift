//
//  MoodTrackerApp.swift
//  MoodTracker
//
//  Created by Kai Speidel on 21.09.25.
//
import SwiftUI

@main
struct MoodTrackerApp: App {
    @AppStorage("appAppearance") private var appAppearanceRaw: String = AppAppearance.system.rawValue

    var body: some Scene {
        WindowGroup {
            HomeView()
                .applyPreferredColorScheme(AppAppearance(rawValue: appAppearanceRaw) ?? .system)
        }
    }
}
