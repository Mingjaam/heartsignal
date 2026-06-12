import SwiftUI

struct ConnectStep2NearbyView: View {
    let onBack: () -> Void
    let onPeerFound: () -> Void

    @EnvironmentObject private var connectivityService: ConnectivityService
    @State private var pulseOpacity: Double = 1.0

    var body: some View {
        VStack(spacing: 0) {
            navBar

            VStack(spacing: 0) {
                Text("2 / 5 단계")
                    .font(.system(size: 13))
                    .foregroundColor(Color.gray900)
                    .padding(.top, 36)
                    .padding(.bottom, 12)

                Text("휴대폰을 서로\n가까이 해주세요.")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color.brown700)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Spacer()

                Image("img_connect_ecg")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .opacity(pulseOpacity)
                    .padding(.vertical, 40)
                    .grayscale(0.6)

                Text("주변에서 연결 가능한 상대를 찾는 중이에요")
                    .font(.system(size: 14))
                    .foregroundColor(Color.gray900)

                Spacer()
            }
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            connectivityService.startConnecting(isNearby: true, partnerCode: nil)
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                pulseOpacity = 0.3
            }
        }
        .onChange(of: connectivityService.peerFound) { _, found in
            if found { onPeerFound() }
        }
    }

    private var navBar: some View {
        ZStack {
            Color.white.ignoresSafeArea(edges: .top)
            HStack {
                Button { onBack() } label: {
                    HSIconView(name: .chevronLeft, color: Color.brown700)
                }
                .padding(.leading, 16)
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
                HSIconView(name: .chevronLeft, color: .clear)
                    .padding(.trailing, 16)
            }
        }
        .frame(height: 50)
        .shadow(color: Color.gray500, radius: 0, x: 0, y: 1)
    }
}

#Preview {
    ConnectStep2NearbyView(onBack: {}, onPeerFound: {})
        .environmentObject(ConnectivityService())
}
