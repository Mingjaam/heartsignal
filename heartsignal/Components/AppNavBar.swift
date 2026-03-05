import SwiftUI

struct AppNavBar<Trailing: View>: View {
    let trailing: Trailing

    init(@ViewBuilder trailing: () -> Trailing = { EmptyView() }) {
        self.trailing = trailing()
    }

    var body: some View {
        ZStack {
            // 흰 배경 + 상단 safe area까지 확장
            Color.white.ignoresSafeArea(edges: .top)

            // 중앙: 앱 아이콘 + 하트시그널
            HStack(spacing: 6) {
                Image("ic_appmain")
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                Text("하트시그널")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.brown700)
            }

            // 우측 액션
            HStack {
                Spacer()
                trailing.padding(.trailing, 16)
            }
        }
        .frame(height: 50)
        .shadow(color: Color.gray500, radius: 0, x: 0, y: 1)
    }
}
