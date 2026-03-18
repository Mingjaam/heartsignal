import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: 0) {
            AppNavBar()
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

    private var heartStatusSection: some View {
        ZStack(alignment: .topLeading) {
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

                HStack(spacing: 0) {
                    heartRateColumn(name: "나", bpm: "123", change: "+12%", avg: "123")
                    Rectangle()
                        .fill(Color.white.opacity(0.35))
                        .frame(width: 1)
                        .padding(.vertical, 14)
                    heartRateColumn(name: "상대", bpm: "123", change: "+12%", avg: "123")
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

    private var ourStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("우리 상태는")
                .font(.body18M)
                .foregroundColor(Color.brown700)

            HeartStatusCardSlider()
        }
    }

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
                ForEach(StatusCard.samples) { card in
                    StatusCardRow(card: card)
                }
            }
        }
    }
}

struct StatusCard: Identifiable {
    let id = UUID()
    let text: String
    let emoji: String
    let isActive: Bool

    static let samples: [StatusCard] = [
        .init(text: "너에게 가는 중", emoji: "💓", isActive: true),
        .init(text: "업무 중", emoji: "💻", isActive: false),
        .init(text: "울동 중", emoji: "💪", isActive: false),
    ]
}

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

#Preview {
    HomeView()
}
