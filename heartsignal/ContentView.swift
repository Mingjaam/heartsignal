//
//  ContentView.swift
//  heartsignal
//
//  Created by 김민재 on 4/21/26.
//

import SwiftUI

private enum ConnectStep {
    case step1
    case step2Code
    case step2Nearby
    case step3(isNearby: Bool, partnerCode: String?)
    case step4(success: Bool)
    case step5
}

struct ContentView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("termsAccepted") private var termsAccepted = false
    @AppStorage("isConnected") private var isConnected = false
    @State private var connectStep: ConnectStep = .step1
    @State private var selectedTab: TabItem = .home
    @State private var showSendSheet  = false
    @StateObject private var connectivityService = ConnectivityService()

    var body: some View {
        if !isLoggedIn {
            LoginView(onTestMode: { isLoggedIn = true })
        } else if !termsAccepted {
            TermsAgreementView(onNext: { termsAccepted = true })
        } else if !isConnected {
            switch connectStep {
            case .step1:
                ConnectStep1View(
                    onStart: { connectStep = .step2Code },
                    onNearby: { connectStep = .step2Nearby }
                )
            case .step2Code:
                ConnectStep2View(
                    myCode: connectivityService.myCode,
                    onBack: { connectStep = .step1 },
                    onNext: { code in
                        connectStep = .step3(isNearby: false, partnerCode: code)
                    }
                )
            case .step2Nearby:
                ConnectStep2NearbyView(
                    onBack: {
                        connectivityService.stopConnecting()
                        connectStep = .step1
                    },
                    onPeerFound: {
                        connectStep = .step3(isNearby: true, partnerCode: nil)
                    }
                )
                .environmentObject(connectivityService)
            case .step3(let isNearby, let partnerCode):
                ConnectStep3View(
                    isNearby: isNearby,
                    partnerCode: partnerCode,
                    onBack: {
                        connectivityService.stopConnecting()
                        connectStep = isNearby ? .step2Nearby : .step2Code
                    },
                    onSuccess: { connectStep = .step4(success: true) },
                    onFailure: { connectStep = .step4(success: false) }
                )
                .environmentObject(connectivityService)
            case .step4(let success):
                ConnectStep4View(
                    success: success,
                    onNext: { connectStep = .step5 },
                    onRetry: { connectStep = .step1 },
                    onTestSuccess: { connectStep = .step4(success: true) }
                )
            case .step5:
                ConnectStep5View(onStart: { isConnected = true })
            }
        } else {
            mainApp
        }
    }

    private var mainApp: some View {
        ZStack(alignment: .bottom) {
            // 상단 safe area 흰색 고정
            Color.white.ignoresSafeArea(edges: .top)

            // 탭 컨텐츠
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

            // 하단 탭바
            TabBar(selected: $selectedTab) {
                showSendSheet = true
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $showSendSheet) {
            Text("보내기")
                .font(.system(size: 20, weight: .semibold))
                .presentationDetents([.medium])
        }
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
