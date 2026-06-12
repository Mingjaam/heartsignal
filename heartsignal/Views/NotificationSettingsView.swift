import SwiftUI

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Toggle States
    @State private var allNotifications = true
    @State private var autoEmotion = true
    @State private var heartRateRise = true
    @State private var bothReaction = true
    @State private var callDetection = true
    @State private var distanceDetection = true
    @State private var proximityAlert = true
    @State private var emotionMessage = true
    
    var body: some View {
        VStack(spacing: 0) {
            navBar
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    allNotificationsSection
                    emotionSection
                    situationSection
                    interactionSection
                }
                .padding(.bottom, 40)
            }
            .background(Color.bg)
        }
        .background(Color.bg)
    }
    
    // MARK: - Navigation Bar
    private var navBar: some View {
        ZStack {
            Color.white.ignoresSafeArea(edges: .top)
            HStack {
                Button { dismiss() } label: {
                    HSIconView(name: .chevronLeft, color: Color.brown700, size: 24)
                }
                .padding(.leading, 16)
                Spacer()
                Text("알림설정")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(hex: "111111"))
                Spacer()
                // 우측 대칭 여백
                Color.clear.frame(width: 24, height: 24)
                    .padding(.trailing, 16)
            }
        }
        .frame(height: 50)
        .shadow(color: Color.gray500, radius: 0, x: 0, y: 1)
    }
    
    // MARK: - Section Header
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color.gray900)
            Spacer()
            HSIconView(name: .chevronDown, color: Color.gray900, size: 20)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(Color.white)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray500),
            alignment: .bottom
        )
    }
    
    // MARK: - Sections
    private var allNotificationsSection: some View {
        VStack(spacing: 0) {
            sectionHeader("전체 알림")
            ListItem(title: "전체 알림", style: .toggle(isOn: $allNotifications)) {}
        }
    }
    
    private var emotionSection: some View {
        VStack(spacing: 0) {
            sectionHeader("감정&반응")
            ListItem(title: "자동 감정 전송", style: .toggle(isOn: $autoEmotion)) {}
            ListItem(title: "심박 상승 알림", style: .toggle(isOn: $heartRateRise)) {}
            ListItem(title: "둘 다 반응 알림", style: .toggle(isOn: $bothReaction)) {}
        }
    }
    
    private var situationSection: some View {
        VStack(spacing: 0) {
            sectionHeader("상황 감지")
            ListItem(title: "통화 시 감지", style: .toggle(isOn: $callDetection)) {}
            ListItem(title: "거리 기반 감지", style: .toggle(isOn: $distanceDetection)) {}
            ListItem(title: "근접 알림", style: .toggle(isOn: $proximityAlert)) {}
        }
    }
    
    private var interactionSection: some View {
        VStack(spacing: 0) {
            sectionHeader("상호작용")
            ListItem(title: "감정 메세지 알림", style: .toggle(isOn: $emotionMessage)) {}
        }
    }
}

#Preview {
    NotificationSettingsView()
}
