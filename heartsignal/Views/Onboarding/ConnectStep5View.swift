import SwiftUI

struct ConnectStep5View: View {
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            navBar

            VStack(spacing: 0) {
                Text("5 / 5 단계")
                    .font(.system(size: 13))
                    .foregroundColor(Color.gray900)
                    .padding(.top, 36)
                    .padding(.bottom, 12)

                Text("지금, 상대와 나의 심박수를\n체크해볼게요!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color.brown700)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Text("워치를 꼭 착용해주세요!")
                    .font(.system(size: 15))
                    .foregroundColor(Color.gray900)
                    .padding(.top, 16)

                Spacer()

                Image("img_connect_beat")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 24)

                Spacer()

                PrimaryButton(title: "시작하기", isEnabled: true) {
                    onStart()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 44)
            }
        }
        .background(Color.white.ignoresSafeArea())
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
