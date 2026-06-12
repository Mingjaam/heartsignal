import SwiftUI

struct ConnectStep1View: View {
    let onStart: () -> Void
    let onNearby: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            AppNavBar()

            VStack(spacing: 0) {
                // 단계 표시
                Text("1 / 5 단계")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.gray900)
                    .padding(.top, 36)
                    .padding(.bottom, 12)

                // 타이틀
                Text("심박수로 알아보는\n우리사이")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(Color.brown700)
                    .multilineTextAlignment(.center)

                Spacer()

                // 중앙 워치 이미지
                Image("img_connect_watch")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)

                Spacer()

                // 하단 버튼 영역
                VStack(spacing: 14) {
                    PrimaryButton(title: "시작하기", isEnabled: true) {
                        onStart()
                    }

                    VStack(spacing: 10) {
                        Text("상대와 가까이 있다면")
                            .font(.system(size: 13))
                            .foregroundColor(Color.gray900)

                        Button { onNearby() } label: {
                            Text("연동하기")
                                .font(.body18SB)
                                .foregroundColor(Color.main700)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.main700, lineWidth: 1.5)
                                )
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 44)
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    ConnectStep1View(onStart: {}, onNearby: {})
}
