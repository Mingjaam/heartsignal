//
//  ContentView.swift
//  heartsignal
//
//  Created by 김민재 on 4/21/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: TabItem = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.white.ignoresSafeArea(edges: .top)

            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .record:
                    RecordView()
                case .analyze:
                    placeholderView("분석", icon: "lock.fill")
                case .mypage:
                    MyPageView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(edges: .bottom)

            TabBar(selected: $selectedTab) {}
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private func placeholderView(_ title: String, icon: String) -> some View {
        VStack(spacing: 0) {
            AppNavBar()
            ZStack {
                Color.bg.ignoresSafeArea()
                VStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 36))
                        .foregroundColor(Color.main700)
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.brown700)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
