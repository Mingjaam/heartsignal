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
                }
            }
            .background(Color.bg)
        }
        .background(Color.bg)
    }

    private var ourStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("우리 상태는")
                .font(.body18M)
                .foregroundColor(Color.brown700)

            HeartStatusCardSlider()
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
