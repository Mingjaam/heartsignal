import SwiftUI

struct ConnectStep3View: View {
    let isNearby: Bool
    let partnerCode: String?
    let onBack: () -> Void
    let onSuccess: () -> Void
    let onFailure: () -> Void

    @EnvironmentObject private var connectivityService: ConnectivityService
    @State private var progress: CGFloat = 0

    private let animationDuration: Double = 4.0
    private let circleSize: CGFloat = 160

    var body: some View {
        VStack(spacing: 0) {
            navBar

            VStack(spacing: 0) {
                Text("3 / 5 단계")
                    .font(.system(size: 13))
                    .foregroundColor(Color.gray900)
                    .padding(.top, 36)
                    .padding(.bottom, 12)

                Text("연동 확인중이에요")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color.brown700)

                Spacer()

                ZStack {
                    Circle()
                        .stroke(Color.gray700, lineWidth: 18)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.main700, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: animationDuration), value: progress)
                }
                .frame(width: circleSize, height: circleSize)

                Spacer()
            }
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            progress = 1.0
        }
        .task {
            // 코드 모드일 때만 여기서 MPC 시작 (근거리 모드는 Step2Nearby에서 이미 시작됨)
            if !isNearby {
                connectivityService.startConnecting(isNearby: false, partnerCode: partnerCode)
            }

            try? await Task.sleep(for: .seconds(animationDuration))

            let connected = connectivityService.connectionState == .connected
            connectivityService.stopConnecting()

            if connected {
                onSuccess()
            } else {
                onFailure()
            }
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
    ConnectStep3View(isNearby: false, partnerCode: "123456", onBack: {}, onSuccess: {}, onFailure: {})
        .environmentObject(ConnectivityService())
}
