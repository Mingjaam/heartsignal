import SwiftUI

struct ConnectStep4View: View {
    let success: Bool
    let onNext: () -> Void          // 성공 시 step5로 이동 (자동)
    let onRetry: () -> Void         // 실패 시 step1로 돌아가기
    let onTestSuccess: () -> Void   // 테스트: 실패 이미지 3번 탭 → 성공화면

    @State private var testTapCount = 0
    private let circleSize: CGFloat = 136

    var body: some View {
        VStack(spacing: 0) {
            navBar

            GeometryReader { proxy in
                let width = proxy.size.width
                let scale = width / 375

                ZStack(alignment: .top) {
                    stepText(current: "4")
                        .position(x: width / 2, y: 73 * scale)

                    if success {
                        Text("연동 완료!")
                            .font(.system(size: 24, weight: .regular))
                            .foregroundColor(Color(hex: "111111"))
                            .frame(height: 34 * scale)
                            .position(x: width / 2, y: 109 * scale)
                    } else {
                        VStack(spacing: 8) {
                            Text("연동 실패\n다시 시도해보세요")
                                .font(.system(size: 24, weight: .regular))
                                .foregroundColor(Color(hex: "111111"))
                                .lineSpacing(0)
                                .multilineTextAlignment(.center)
                                .frame(width: 183 * scale, height: 68 * scale)

                            Text("더 가까이 휴대폰을 대거나\n코드를 한번 더 확인해주세요.")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(Color.gray900)
                                .lineSpacing(0)
                                .multilineTextAlignment(.center)
                                .frame(width: 183 * scale, height: 44 * scale)
                        }
                        .position(x: width / 2, y: 152 * scale)
                    }

                    Image(success ? "img_connect_success" : "img_connect_fail")
                        .resizable()
                        .frame(width: circleSize * scale, height: circleSize * scale)
                        .position(x: width / 2, y: 289 * scale)
                        .onTapGesture {
                            guard !success else { return }
                            testTapCount += 1
                            if testTapCount >= 3 {
                                onTestSuccess()
                            }
                        }

                    if !success {
                        VStack {
                            Spacer()
                            PrimaryButton(title: "다시 시도하기", isEnabled: true) {
                                onRetry()
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 23)
                        }
                    }
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .task(id: success) {
            guard success else { return }
            try? await Task.sleep(for: .seconds(2.0))
            onNext()
        }
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
    ConnectStep4View(success: false, onNext: {}, onRetry: {}, onTestSuccess: {})
}
