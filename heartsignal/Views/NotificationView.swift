import SwiftUI

struct NotificationView: View {
    @Binding var isPresented: Bool
    @State private var items: [NotifItem] = NotifItem.samples

    var body: some View {
        VStack(spacing: 0) {
            navBar
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // 안내 문구
                    HStack {
                        Text("알림은 일주일 뒤 자동으로 삭제돼요!")
                            .font(.body14R)
                            .foregroundColor(Color(hex: "726467"))
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)

                    // 알림 카드 리스트
                    VStack(spacing: 12) {
                        ForEach(items) { item in
                            notifCard(item)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
            .background(Color.bg)
        }
        .background(Color.bg)
    }

    // MARK: - 네비게이션 바

    private var navBar: some View {
        ZStack {
            Color.white.ignoresSafeArea(edges: .top)
            Text("알림")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.brown700)
            HStack {
                Button { isPresented = false } label: {
                    HSIconView(name: .chevronLeft, color: Color.brown700, size: 24)
                }
                .padding(.leading, 16)
                Spacer()
                Button {
                    withAnimation { items.removeAll() }
                } label: {
                    HSIconView(name: .trash, color: Color.brown700, size: 22)
                }
                .padding(.trailing, 16)
            }
        }
        .frame(height: 50)
        .shadow(color: Color.gray500, radius: 0, x: 0, y: 1)
    }

    // MARK: - 알림 카드

    private func notifCard(_ item: NotifItem) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                HStack(spacing: 6) {
                    if !item.isRead {
                        Circle()
                            .fill(Color.main700)
                            .frame(width: 7, height: 7)
                    }
                    Text(item.timeLabel)
                        .font(.body14R)
                        .foregroundColor(Color.gray800)
                }
                Spacer()
                Button {
                    withAnimation { items.removeAll { $0.id == item.id } }
                } label: {
                    HSIconView(name: .close, color: Color.gray900, size: 18)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.body18M)
                    .foregroundColor(Color.brown700)
                HStack(spacing: 4) {
                    Text(item.message)
                        .font(.body14R)
                        .foregroundColor(Color.brown700)
                    Text(item.bpmChange)
                        .font(.body14SB)
                        .foregroundColor(Color.main700)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 18)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(item.isRead ? Color.gray700 : Color.main700, lineWidth: 1)
        )
    }
}

// MARK: - 알림 데이터 모델

struct NotifItem: Identifiable {
    let id = UUID()
    let isRead: Bool
    let timeLabel: String
    let title: String
    let message: String
    let bpmChange: String

    static let samples: [NotifItem] = [
        .init(isRead: false, timeLabel: "방금",
              title: "지금 반응이 온 것 같아요 💓",
              message: "상대방의 심박수가 상승했어요",
              bpmChange: "+12 bpm"),
        .init(isRead: false, timeLabel: "5분 전",
              title: "둘 다 텐션 올라가는 중인 거 아냐? 💓",
              message: "양쪽 심박수가 동시에 상승했어요",
              bpmChange: "+8 bpm"),
        .init(isRead: true, timeLabel: "1시간 전",
              title: "지금 서로 꽤 가까이 있는 것 같아요 👀",
              message: "상대방과의 거리가 가까워졌어요",
              bpmChange: "50m"),
        .init(isRead: true, timeLabel: "3시간 전",
              title: "상대방이 시그널을 보냈어요 💌",
              message: "보고 싶어",
              bpmChange: ""),
    ]
}

#Preview {
    NotificationView(isPresented: .constant(true))
}
