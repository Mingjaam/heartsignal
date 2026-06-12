import SwiftUI

struct LoginView: View {
    var onTestMode: (() -> Void)? = nil

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let scale = width / 375

            ZStack(alignment: .top) {
            Color.white.ignoresSafeArea()

                VStack(spacing: 10) {
                    Text("심박수로 알아보는\n우리사이")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundColor(Color(hex: "111111"))
                        .lineSpacing(0)
                        .multilineTextAlignment(.center)
                        .frame(width: 172 * scale, height: 68 * scale)

                    HStack(spacing: 5) {
                        Image("ic_appmain")
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        Text("하트시그널")
                            .font(.body14R)
                            .foregroundColor(Color.brown700)
                    }
                }
                .position(x: width / 2, y: 190 * scale)

                Image("img_login_watch")
                    .resizable()
                    .frame(width: width, height: 266 * scale)
                    .position(x: width / 2, y: 369 * scale)

                VStack(spacing: 14) {
                    Button {
                        // TODO: Apple Sign In
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "apple.logo")
                                .font(.system(size: 17, weight: .semibold))
                            Text("APPLE 로그인")
                                .font(.system(size: 17, weight: .semibold))
                                .kerning(0.5)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(hex: "1C1C1E"))
                        .cornerRadius(10)
                    }

                    if let onTestMode {
                        Button {
                            onTestMode()
                        } label: {
                            Text("테스트 모드로 시작")
                                .font(.system(size: 13))
                                .foregroundColor(Color.gray900)
                                .underline()
                        }
                    }
                }
                .padding(.horizontal, 16)
                .position(x: width / 2, y: 683 * scale)
            }
        }
    }
}

#Preview {
    LoginView(onTestMode: {})
}
