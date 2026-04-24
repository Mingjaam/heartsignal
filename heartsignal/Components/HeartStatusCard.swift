import SwiftUI
internal import Combine

// MARK: - 카드 슬라이드 데이터

struct HeartCardSlide {
    let imageName: String       // Assets 이미지명
    let statusTitle: String
    let emoji: String
    let distance: String

    static let slides: [HeartCardSlide] = [
        .init(imageName: "img_heart_card_default",
              statusTitle: "둘 다 심박수 상승 중!",
              emoji: "💓",
              distance: "90km"),
        .init(imageName: "img_heart_card_rise",
              statusTitle: "심박수가 올라가고 있어!",
              emoji: "❤️‍🔥",
              distance: "90km"),
        .init(imageName: "img_heart_card_night",
              statusTitle: "오늘 밤도 같이 있는 것 같아",
              emoji: "🫂",
              distance: "90km"),
    ]
}

// MARK: - 자동 슬라이딩 카드

struct HeartStatusCardSlider: View {
    @State private var currentIndex: Int = 0
    private let slides = HeartCardSlide.slides
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentIndex) {
                ForEach(Array(slides.enumerated()), id: \.offset) { index, slide in
                    HeartStatusCard(slide: slide)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxWidth: .infinity, minHeight: 136, maxHeight: 136)
            .cornerRadius(12)

            pageIndicator
                .padding(.bottom, 10)
        }
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 0.4)) {
                currentIndex = (currentIndex + 1) % slides.count
            }
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 5) {
            ForEach(0..<slides.count, id: \.self) { i in
                Capsule()
                    .fill(i == currentIndex ? Color.white : Color.white.opacity(0.4))
                    .frame(width: i == currentIndex ? 14 : 6, height: 6)
                    .animation(.easeInOut(duration: 0.25), value: currentIndex)
            }
        }
    }
}

// MARK: - 단일 카드

struct HeartStatusCard: View {
    let slide: HeartCardSlide

    var body: some View {
        ZStack {
            // 배경 이미지 (없으면 그라디언트 fallback)
            if UIImage(named: slide.imageName) != nil {
                Image(slide.imageName)
                    .resizable()
                    .scaledToFill()
                    .clipped()
            } else {
                LinearGradient(
                    colors: [Color.main600.opacity(0.6), Color.main700.opacity(0.4)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }

            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    Text(slide.statusTitle)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color.brown700)
                    Text(slide.emoji)
                        .font(.system(size: 20))
                }

                HStack(alignment: .bottom, spacing: 6) {
                    Text("우리는 지금")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color.brown700)
                        .padding(.bottom, 4)
                    Text(slide.distance)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.brown700)
                    Text("떨어져 있어요")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color.brown700)
                        .padding(.bottom, 3)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 136, maxHeight: 136)
    }
}

#Preview {
    HeartStatusCardSlider()
        .padding()
}
