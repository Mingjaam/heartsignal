import SwiftUI

struct ConnectStep5View: View {
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            navBar

            GeometryReader { proxy in
                let width = proxy.size.width
                let scale = width / 375

                ZStack(alignment: .top) {
                    stepText(current: "5")
                        .position(x: width / 2, y: 73 * scale)

                    Text("지금, 상대와 나의 심박수를\n체크해볼게요!")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundColor(Color(hex: "111111"))
                        .lineSpacing(0)
                        .multilineTextAlignment(.center)
                        .frame(width: 253 * scale, height: 68 * scale)
                        .position(x: width / 2, y: 126 * scale)

                    Text("위치를 꼭 착용해주세요!")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(Color(hex: "111111"))
                        .frame(width: 253 * scale, height: 25 * scale)
                        .position(x: width / 2, y: 201 * scale)

                    Image("img_connect_beat")
                        .resizable()
                        .frame(width: width, height: 83 * scale)
                        .position(x: width / 2, y: 279 * scale)

                    VStack {
                        Spacer()
                        PrimaryButton(title: "시작하기", isEnabled: true) {
                            onStart()
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 23)
                    }
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
    }

    private func stepText(current: String) -> some View {
        HStack(spacing: 4) {
            Text(current)
                .foregroundColor(Color(hex: "111111"))
            Text("/")
                .foregroundColor(Color.gray700)
            Text("5")
                .foregroundColor(Color.gray700)
            Text("단계")
                .foregroundColor(Color.gray700)
        }
        .font(.body14R)
        .frame(height: 20)
    }

    private var navBar: some View {
        ZStack {
            Color.white.ignoresSafeArea(edges: .top)
            HStack {
                Spacer()
                HStack(spacing: 6) {
                    Image("ic_appmain")
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text("하트시그널")
                        .font(.body18M)
                        .foregroundColor(Color.brown700)
                }
                Spacer()
            }
        }
        .frame(height: 50)
        .shadow(color: Color.gray500, radius: 0, x: 0, y: 1)
    }
}

#Preview {
    ConnectStep5View(onStart: {})
}
