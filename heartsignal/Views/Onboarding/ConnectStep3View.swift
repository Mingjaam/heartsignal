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
    private let circleSize: CGFloat = 136

    var body: some View {
        VStack(spacing: 0) {
            navBar

            GeometryReader { proxy in
                let width = proxy.size.width
                let scale = width / 375

                ZStack(alignment: .top) {
                    stepText(current: "3")
                        .position(x: width / 2, y: 73 * scale)

                    Text("연동 확인중이에요")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundColor(Color(hex: "111111"))
                        .frame(height: 34 * scale)
                        .position(x: width / 2, y: 109 * scale)

                    ZStack {
                        Circle()
                            .stroke(Color.gray700, lineWidth: 13)
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(Color.main700, style: StrokeStyle(lineWidth: 13, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: animationDuration), value: progress)
                    }
                    .frame(width: circleSize * scale, height: circleSize * scale)
                    .position(x: width / 2, y: 289 * scale)
                }
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
