//
//  heartsignalApp.swift
//  heartsignal
//
//  Created by 김민재 on 4/21/26.
//

import SwiftUI
import UserNotifications

@main
struct heartsignalApp: App {
    @StateObject private var connectivity = PhoneConnectivityManager.shared

    init() {
        requestNotificationPermission()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(connectivity)
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}
