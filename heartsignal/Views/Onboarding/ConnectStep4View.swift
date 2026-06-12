import SwiftUI

struct ConnectStep4View: View {
    let success: Bool
    let onNext: () -> Void          // 성공 시 step5로 이동 (자동)
    let onRetry: () -> Void         // 실패 시 step1로 돌아가기
    let onTestSuccess: () -> Void   // 테스트: 실패 이미지 3번 탭 → 성공화면

    @State private var testTapCount = 0
    private let circleSize: CGFloat = 160

    var body: some View {
        VStack(spacing: 0) {
            navBar

            VStack(spacing: 0) {
                Text("4 / 5 단계")
                    .font(.system(size: 13))
                    .foregroundColor(Color.gray900)
                    .padding(.top, 36)
                    .padding(.bottom, 12)

                if success {
                    Text("연동 완료!")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color.brown700)
                } else {
                    Text("연동 실패\n다시 시도해보세요")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color.brown700)
                        .multilineTextAlignment(.center)

                    Text("더 가까이 휴대폰을 대거나\n코드를 한번 더 확인해주세요.")
                        .font(.system(size: 14))
                        .foregroundColor(Color.gray900)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }

                Spacer()

                Image(success ? "img_connect_success" : "img_connect_fail")
                    .resizable()
                    .scaledToFit()
                    .frame(width: circleSize, height: circleSize)
                    .onTapGesture {
                        guard !success else { return }
                        testTapCount += 1
                        if testTapCount >= 3 {
                            onTestSuccess()
                        }
                    }

                Spacer()
            }

            if !success {
                PrimaryButton(title: "다시 시도하기", isEnabled: true) {
                    onRetry()
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 44)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .task(id: success) {
            guard success else { return }
            try? await Task.sleep(for: .seconds(2.0))
            onNext()
        }
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
