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
    @State private var selectedTab: TabItem = ContentView.initialTab
    @State private var showSendSheet = ContentView.initiallyShowsQuickSend
    @State private var quickSendText = ContentView.initialQuickSendText
    @State private var showQuickSendToast = ContentView.initiallyShowsQuickSendToast
    @State private var hidesTabBar = false
    @StateObject private var connectivityService = ConnectivityService()

    private var bypassOnboarding: Bool {
#if DEBUG
        ProcessInfo.processInfo.arguments.contains("-figmaPreview")
#else
        false
#endif
    }

    var body: some View {
        if !bypassOnboarding && !isLoggedIn {
            LoginView(onTestMode: { isLoggedIn = true })
        } else if !bypassOnboarding && !termsAccepted {
            TermsAgreementView(onNext: { termsAccepted = true })
        } else if !bypassOnboarding && !isConnected {
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
                    MyPageView { isSubpageVisible in
                        hidesTabBar = isSubpageVisible
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(edges: .bottom)
            .onChange(of: selectedTab) { _, newValue in
                if newValue != .mypage {
                    hidesTabBar = false
                }
            }

            // 하단 탭바
            if !hidesTabBar {
                TabBar(selected: $selectedTab) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        showSendSheet = true
                    }
                }
            }

            if showSendSheet {
                Color.black.opacity(0.22)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.2)) {
                            showSendSheet = false
                            showQuickSendToast = false
                        }
                    }

                QuickSendOverlay(
                    text: $quickSendText,
                    showToast: $showQuickSendToast
                )
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
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

    private static var initialTab: TabItem {
#if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        if let index = arguments.firstIndex(of: "-figmaTab"),
           arguments.indices.contains(index + 1),
           let tab = TabItem(rawValue: arguments[index + 1]) {
            return tab
        }
#endif
        return .home
    }

    private static var figmaRoute: String? {
#if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        if let index = arguments.firstIndex(of: "-figmaRoute"),
           arguments.indices.contains(index + 1) {
            return arguments[index + 1]
        }
#endif
        return nil
    }

    private static var initiallyShowsQuickSend: Bool {
        guard let route = figmaRoute else { return false }
        return ["quickSend", "quickSendInput", "quickSendComplete"].contains(route)
    }

    private static var initialQuickSendText: String {
        figmaRoute == "quickSendInput" ? "너에게 가는 중" : ""
    }

    private static var initiallyShowsQuickSendToast: Bool {
        figmaRoute == "quickSendComplete"
    }
}

private struct QuickSendOverlay: View {
    @Binding var text: String
    @Binding var showToast: Bool

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                quickSendCard(width: min(geometry.size.width - 32, 343))
                    .padding(.top, 228)

                if showToast {
                    Text("💌 전송완료!")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 220, height: 53)
                        .background(Color.main700)
                        .cornerRadius(10)
                        .padding(.top, 521)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
        }
    }

    private func quickSendCard(width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("빠르게 입력하기")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.brown700)
                .padding(.top, 18)
                .padding(.horizontal, 20)

            HStack(spacing: 10) {
                quickTemplateCard
                addTemplateCard
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)

            HStack(spacing: 4) {
                Capsule()
                    .fill(Color.main700)
                    .frame(width: 16, height: 5)
                Circle()
                    .fill(Color.gray800)
                    .frame(width: 5, height: 5)
                Circle()
                    .fill(Color.gray800)
                    .frame(width: 5, height: 5)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)

            HStack(spacing: 4) {
                TextField("상태를 입력해주세요.", text: $text)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(Color.brown700)
                    .padding(.horizontal, 12)
                    .frame(height: 55)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.brown700, lineWidth: 1)
                    )

                Button {
                    guard canSend else { return }
                    withAnimation(.easeOut(duration: 0.2)) {
                        text = ""
                        showToast = true
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(canSend ? Color.main700 : Color.gray800)
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 25, weight: .semibold))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(7))
                    }
                    .frame(width: 55, height: 55)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.top, 17)

            Text("현재 심박수와 함께 전송돼요!")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color.gray900)
                .padding(.horizontal, 26)
                .padding(.top, 10)

            Spacer(minLength: 0)
        }
        .frame(width: width, height: 268)
        .background(Color.white)
        .cornerRadius(24)
    }

    private var quickTemplateCard: some View {
        Button {
            text = "너에게 가는 중"
            showToast = false
        } label: {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.main700, lineWidth: 1)
                    )

                Image(systemName: "square.and.pencil")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(Color.brown700)
                    .padding(.top, 12)
                    .padding(.trailing, 12)

                Text("너에게 가는 중 💞")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color.brown700)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .padding(.leading, 10)
                    .padding(.bottom, 13)
            }
            .frame(height: 85)
            .frame(width: 146)
        }
        .buttonStyle(.plain)
    }

    private var addTemplateCard: some View {
        Button {} label: {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                Color.main600,
                                style: StrokeStyle(lineWidth: 1, dash: [5, 5])
                            )
                    )

                Image(systemName: "plus")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundColor(Color.brown700)
            }
            .frame(height: 85)
            .frame(width: 146)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}
