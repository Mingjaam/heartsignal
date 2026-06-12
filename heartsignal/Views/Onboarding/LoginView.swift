import SwiftUI

struct LoginView: View {
    var onTestMode: (() -> Void)? = nil

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // 타이틀
                VStack(spacing: 10) {
                    Text("심박수로 알아보는\n우리사이")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(Color.brown700)
                        .multilineTextAlignment(.center)

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

                Spacer()

                // 워치 + 심박선 이미지 (풀 width, 가로 패딩 없음)
                Image("img_login_watch")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)

                Spacer()

                // 하단 버튼
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
                        .padding(.vertical, 17)
                        .background(Color(hex: "1C1C1E"))
                        .cornerRadius(14)
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
                .padding(.horizontal, 24)
                .padding(.bottom, 44)
            }
        }
    }
}

#Preview {
    LoginView(onTestMode: {})
}
