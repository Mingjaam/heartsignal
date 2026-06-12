import SwiftUI

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    var onBack: (() -> Void)? = nil

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
                VStack(spacing: 0) {
                    sectionHeader("전체 알림")
                    settingRow("전체 알림", isOn: $allNotifications)

                    sectionGap

                    sectionHeader("감정&반응")
                    settingRow("자동 감정 전송", isOn: $autoEmotion)
                    settingRow("심박 상승 알림", isOn: $heartRateRise)
                    settingRow("둘 다 반응 알림", isOn: $bothReaction)

                    sectionGap

                    sectionHeader("상황 감지")
                    settingRow("통화 시 감지", isOn: $callDetection)
                    settingRow("거리 기반 감지", isOn: $distanceDetection)
                    settingRow("근접 알림", isOn: $proximityAlert)

                    sectionGap

                    sectionHeader("상호작용")
                    settingRow("감정 메세지 알림", isOn: $emotionMessage)
                }
                .padding(.bottom, 112)
            }
            .background(Color.bg)
        }
        .background(Color.bg)
    }

    private var navBar: some View {
        ZStack {
            Color.white.ignoresSafeArea(edges: .top)

            Text("알림설정")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color(hex: "111111"))

            HStack {
                Button {
                    if let onBack {
                        onBack()
                    } else {
                        dismiss()
                    }
                } label: {
                    HSIconView(name: .chevronLeft, color: Color.gray900, size: 24)
                }
                .padding(.leading, 16)

                Spacer()
            }
        }
        .frame(height: 50)
    }

    private var sectionGap: some View {
        Color.bg
            .frame(height: 16)
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color.gray900)
            Spacer()
        }
        .padding(.horizontal, 24)
        .frame(height: 52)
        .background(Color.bg)
    }

    private func settingRow(_ title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color.brown700)
            Spacer()
            ToggleSwitch(isOn: isOn)
        }
        .padding(.horizontal, 24)
        .frame(height: 52)
        .background(Color.white)
        .overlay(
            Rectangle()
                .fill(Color.gray500)
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

#Preview {
    NotificationSettingsView()
}
