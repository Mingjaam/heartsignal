import SwiftUI

struct ConnectStep1View: View {
    let onStart: () -> Void
    let onNearby: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            AppNavBar()

            GeometryReader { proxy in
                let width = proxy.size.width
                let scale = width / 375

                ZStack(alignment: .top) {
                    stepText(current: "1")
                        .position(x: width / 2, y: 73 * scale)

                    Text("심박수로 알아보는\n우리사이")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundColor(Color(hex: "111111"))
                        .lineSpacing(0)
                        .multilineTextAlignment(.center)
                        .frame(width: 172 * scale, height: 68 * scale)
                        .position(x: width / 2, y: 126 * scale)

                    Image("img_connect_watch")
                        .resizable()
                        .frame(width: width, height: 266 * scale)
                        .position(x: width / 2, y: 302 * scale)

                    PrimaryButton(title: "시작하기", isEnabled: true) {
                        onStart()
                    }
                    .padding(.horizontal, 16)
                    .position(x: width / 2, y: 633 * scale)
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
    }

    private func stepText(current: String) -> some View {
        HStack(spacing: 4) {
            Text(current)
                .foregroundColor(Color(hex: "434343"))
            Text("/")
                .foregroundColor(Color(hex: "A6A6A6"))
            Text("5")
                .foregroundColor(Color(hex: "A6A6A6"))
            Text("단계")
                .foregroundColor(Color(hex: "A6A6A6"))
        }
        .font(.body14R)
        .frame(height: 20)
    }
}

#Preview {
    ConnectStep1View(onStart: {}, onNearby: {})
}
