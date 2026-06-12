import SwiftUI
import CoreLocation
internal import Combine

// MARK: - 카드 슬라이드 데이터

struct HeartCardSlide {
    let imageName: String       // Assets 이미지명
    let statusTitle: String
    let emoji: String

    static let slides: [HeartCardSlide] = [
        .init(imageName: "img_heart_card_rise",
              statusTitle: "둘 다 심박수 상승 중!",
              emoji: "💞"),
        .init(imageName: "img_heart_card_default",
              statusTitle: "심박수가 올라가고 있어!",
              emoji: "❤️‍🔥"),
        .init(imageName: "img_heart_card_night",
              statusTitle: "오늘 밤도 같이 있는 것 같아",
              emoji: "🫂"),
    ]
}

// MARK: - 자동 슬라이딩 카드

struct HeartStatusCardSlider: View {
    @StateObject private var locationManager = LocationManager()
    @State private var currentIndex: Int = 0
    private let slides = HeartCardSlide.slides
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    // 상대방 위치: 부산
    private let partnerLocation = CLLocation(
        latitude: 35.1796,
        longitude: 129.0756
    )

    /// 내 위치와 부산 사이의 거리 문자열
    private var distanceText: String {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-figmaPreview") {
            return "90km"
        }
#endif
        guard let userLoc = locationManager.location else { return "--km" }
        let meters = userLoc.distance(from: partnerLocation)
        let km = meters / 1000.0

        if km < 1 {
            return String(format: "%.0fm", meters)
        } else if km < 10 {
            return String(format: "%.1fkm", km)
        } else {
            return String(format: "%.0fkm", km)
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentIndex) {
                ForEach(Array(slides.enumerated()), id: \.offset) { index, slide in
                    HeartStatusCard(slide: slide, distance: distanceText)
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
    let distance: String

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
                    Text(distance)
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

// MARK: - 위치 매니저

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var location: CLLocation?

    override init() {
        super.init()
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-figmaPreview") {
            location = CLLocation(latitude: 35.8714, longitude: 128.6014)
            return
        }
#endif
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        handleAuthorization()
    }

    private func handleAuthorization() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            manager.stopUpdatingLocation()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        location = latest
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 업데이트 실패: \(error.localizedDescription)")
    }
}

#Preview {
    HeartStatusCardSlider()
        .padding()
}
