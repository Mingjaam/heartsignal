import SwiftUI

struct HomeView: View {
    @EnvironmentObject var connectivity: PhoneConnectivityManager
    @State private var statusCards: [StatusCard] = StatusCard.samples
    @State private var showNotification: Bool = false
    @State private var showWatchInfo: Bool = false

    private var isWatchConnected: Bool { connectivity.isWatchReachable }

    // MARK: - 실측 심박수 계산값

    private var myBpm: String {
        connectivity.watchHeartRate > 0 ? "\(Int(connectivity.watchHeartRate))" : "--"
    }

    private var myChange: String {
        let current = connectivity.watchHeartRate
        let yesterday = connectivity.yesterdayAverageHeartRate
        guard current > 0, yesterday > 0 else { return "--" }
        let pct = ((current - yesterday) / yesterday) * 100
        return pct >= 0 ? "+\(Int(pct))%" : "\(Int(pct))%"
    }

    private var myAvg: String {
        connectivity.averageHeartRate > 0 ? "\(Int(connectivity.averageHeartRate))" : "--"
    }

    private var partnerBpm: String {
        connectivity.partnerHeartRate > 0 ? "\(Int(connectivity.partnerHeartRate))" : "--"
    }

    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    VStack(spacing: 18) {
                        ourStatusSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 18)

                    heartStatusSection

                    VStack(spacing: 18) {
                        currentStatusSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .background(Color.bg)
        }
        .background(Color.bg)
    }

    // MARK: - 상단 네비게이션 바

    private var navigationBar: some View {
        AppNavBar {
            HStack(spacing: 4) {
                Button { showWatchInfo = true } label: {
                    HSIconView(name: isWatchConnected ? .watchOn : .watchOff)
                }
                Button { showNotification = true } label: {
                    HSIconView(name: .bellOff, color: Color.brown700)
                }
            }
        }
        .fullScreenCover(isPresented: $showNotification) {
            NotificationView(isPresented: $showNotification)
        }
        .sheet(isPresented: $showWatchInfo) {
            WatchInfoSheet(isPresented: $showWatchInfo, isConnected: isWatchConnected, heartRate: connectivity.watchHeartRate)
                .presentationDetents([.height(280)])
                .presentationCornerRadius(24)
        }
    }

    // MARK: - 심장 상태 섹션

    private var heartStatusSection: some View {
        ZStack(alignment: .topLeading) {
            // 배경: 이미지 자체 비율로 가로 꽉 채움
            Image("img_heart_status_bg")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 6) {
                    Text("심장 상태")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.brown700)
                    HSIconView(name: .heartbeat, color: Color.main700, size: 20)
                }
                .padding(.top, 20)

                // 글래스모피즘 카드 (343 fixed, 192 height)
                HStack(spacing: 0) {
                    heartRateColumn(name: "나", bpm: myBpm, change: myChange, avg: myAvg)
                    Rectangle()
                        .fill(Color.white.opacity(0.35))
                        .frame(width: 1)
                        .padding(.vertical, 14)
                    heartRateColumn(name: "상대", bpm: partnerBpm, change: "--", avg: "--")
                }
                .frame(width: 343, height: 192)
                .background(Color.white.opacity(0.18))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.7), Color.white.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity)
    }

    private func heartRateColumn(name: String, bpm: String, change: String, avg: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Text(name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.brown700)
                HSIconView(name: .heart, color: Color(hex: "FF3B5C"), size: 14)
            }

            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(bpm)
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundColor(Color.brown700)
                Text("bpm")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.main700)
                    .padding(.bottom, 5)
            }

            Text("어제보다 \(change)")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(Color(hex: "FF3B30"))

            Text("평균 \(avg) bpm")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(Color.brown700.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 우리 상태는

    private var ourStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("우리 상태는")
                .font(.body18M)
                .foregroundColor(Color.brown700)

            HeartStatusCardSlider()
        }
    }

    // MARK: - 나는 지금...

    private var currentStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("나는 지금 ...")
                    .font(.body18M)
                    .foregroundColor(Color.brown700)
                Spacer()
                Button {
                } label: {
                    Text("추가하기")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(hex: "8D8D8D"))
                }
            }

            VStack(spacing: 12) {
                ForEach(statusCards) { card in
                    StatusCardRow(card: card)
                }
            }
        }
    }
}

// MARK: - 상태 카드 모델

struct StatusCard: Identifiable {
    let id = UUID()
    let text: String
    let emoji: String
    let isActive: Bool

    static let samples: [StatusCard] = [
        .init(text: "너에게 가는 중", emoji: "💓", isActive: true),
        .init(text: "업무 중", emoji: "💻", isActive: false),
        .init(text: "운동 중", emoji: "💪", isActive: false),
    ]
}

// MARK: - 상태 카드 행

struct StatusCardRow: View {
    let card: StatusCard

    var body: some View {
        HStack {
            Text(card.text)
                .font(card.isActive ? .body14SB : .body14R)
                .foregroundColor(Color.brown700)
            Text(card.emoji)
                .font(.system(size: 14))
            Spacer()
            HSIconView(name: .write, color: Color.gray800)
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 12)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(card.isActive ? Color.main700 : Color(hex: "E0E0E0"), lineWidth: 1)
        )
    }
}

// MARK: - 워치 연결 정보 시트

struct WatchInfoSheet: View {
    @Binding var isPresented: Bool
    let isConnected: Bool
    let heartRate: Double

    var body: some View {
        VStack(spacing: 0) {
            // 핸들
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray700)
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 20)

            // 워치 아이콘 + 상태
            HSIconView(
                name: isConnected ? .watchOn : .watchOff,
                size: 48
            )
            .padding(.bottom, 12)

            Text(isConnected ? "Apple Watch 연결됨" : "Apple Watch 미연결")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color.brown700)
                .padding(.bottom, 6)

            Text(isConnected ? "워치와 정상적으로 연결되어 있습니다." : "워치가 페어링되어 있지 않거나\n앱이 설치되지 않았습니다.")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color.gray900)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)

            // 심박수 정보
            HStack(spacing: 0) {
                VStack(spacing: 4) {
                    Text("현재 심박수")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color.gray900)
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text(heartRate > 0 ? "\(Int(heartRate))" : "--")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(Color.brown700)
                        Text("bpm")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Color.gray900)
                            .padding(.bottom, 3)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 16)
            .background(Color.gray500)
            .cornerRadius(14)
            .padding(.horizontal, 20)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
}

#Preview {
    HomeView()
}
