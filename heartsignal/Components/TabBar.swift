import SwiftUI

enum TabItem: String, CaseIterable {
    case home, record, analyze, mypage

    var title: String {
        switch self {
        case .home:    return "홈"
        case .record:  return "기록"
        case .analyze: return "분석"
        case .mypage:  return "마이"
        }
    }

    var iconOff: HSIconName {
        switch self {
        case .home:    return .homeOff
        case .record:  return .dateOff
        case .analyze: return .lockOff
        case .mypage:  return .mypageOff
        }
    }

    var iconOn: HSIconName {
        switch self {
        case .home:    return .homeOn
        case .record:  return .dateOn
        case .analyze: return .lockOn
        case .mypage:  return .mypageOn
        }
    }
}

struct TabBar: View {
    @Binding var selected: TabItem
    var onFABTap: () -> Void = {}

    private let fabRadius:   CGFloat = 30
    private let notchRadius: CGFloat = 38
    private let barHeight:   CGFloat = 65

    private let leftTabs:  [TabItem] = [.home, .record]
    private let rightTabs: [TabItem] = [.analyze, .mypage]

    var body: some View {
        ZStack(alignment: .top) {
            ZStack(alignment: .top) {
                Rectangle()
                    .fill(Color.white)

                Circle()
                    .frame(width: notchRadius * 2, height: notchRadius * 2)
                    .offset(y: -notchRadius)
                    .blendMode(.destinationOut)
            }
            .frame(height: barHeight + 28)
            .compositingGroup()
            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: -3)

            HStack(spacing: 0) {
                ForEach(leftTabs,  id: \.rawValue) { tabButton($0) }
                Spacer().frame(width: notchRadius * 2 + 16)
                ForEach(rightTabs, id: \.rawValue) { tabButton($0) }
            }
            .frame(height: barHeight)
            .padding(.top, 4)
            .padding(.horizontal, 24)

            Button(action: onFABTap) {
                ZStack {
                    Circle()
                        .fill(Color.main700)
                        .shadow(color: Color.main700.opacity(0.4), radius: 10, x: 0, y: 5)
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                .frame(width: fabRadius * 2, height: fabRadius * 2)
            }
            .offset(y: -fabRadius)
        }
    }

    private func tabButton(_ tab: TabItem) -> some View {
        let active = selected == tab
        return Button { selected = tab } label: {
            VStack(spacing: 3) {
                HSIconView(
                    name: active ? tab.iconOn : tab.iconOff,
                    color: active ? Color.main700 : Color.brown700,
                    size: 24
                )
                Text(tab.title)
                    .font(.system(size: 14, weight: active ? .semibold : .regular))
                    .foregroundColor(active ? Color.main700 : Color.brown700)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
        TabBar(selected: .constant(.home))
    }
    .ignoresSafeArea(edges: .bottom)
}
