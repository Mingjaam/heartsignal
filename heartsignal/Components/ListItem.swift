import SwiftUI

enum ListItemStyle {
    case navigate                    // 우측 chevron →
    case info(value: String)         // 우측 텍스트 (버전 등)
    case toggle(isOn: Binding<Bool>) // 토글 스위치
}

struct ListItem: View {
    let title: String
    var icon: HSIconName? = nil
    let style: ListItemStyle
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: 12) {
                if let icon {
                    HSIconView(name: icon, color: Color.brown700, size: 22)
                }
                Text(title)
                    .font(.body16R)
                    .foregroundColor(Color.brown700)
                Spacer()
                trailingContent
            }
            .padding(.horizontal, 20)
            .frame(height: 52)
            .background(Color.white)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray500),
                alignment: .bottom
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var trailingContent: some View {
        switch style {
        case .navigate:
            HSIconView(name: .chevronRight, color: Color.gray900, size: 18)
        case .info(let value):
            Text(value)
                .font(.body14R)
                .foregroundColor(Color.gray900)
        case .toggle(let binding):
            ToggleSwitch(isOn: binding)
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        ListItem(title: "공지사항", icon: .post, style: .navigate) {}
        ListItem(title: "알림설정", icon: .bellOff, style: .navigate) {}
        ListItem(title: "앱 버전", icon: .app, style: .info(value: "v4.04"))
        ListItem(title: "알림", style: .toggle(isOn: .constant(true)))
    }
}
