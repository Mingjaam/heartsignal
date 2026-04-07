//
//  heartsignalApp.swift
//  heartsignal
//
//  Created by 김민재 on 4/21/26.
//

import SwiftUI

@main
struct heartsignalApp: App {
    @StateObject private var connectivity = PhoneConnectivityManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(connectivity)
        }
    }
}
