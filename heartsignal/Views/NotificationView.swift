import SwiftUI

struct NotificationView: View {
    @Binding var isPresented: Bool
    @State private var items: [NotifItem] = NotifItem.samples

    var body: some View {
        VStack(spacing: 0) {
            navBar

            if items.isEmpty {
                emptyState
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Text("알림은 일주일 뒤 자동으로 삭제돼요!")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(hex: "726467"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)

                        VStack(spacing: 16) {
                            ForEach(items) { item in
                                notifCard(item)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 6)
                        .padding(.bottom, 40)
                    }
                }
                .background(Color.bg)
            }
        }
        .background(Color.bg)
    }

    private var navBar: some View {
        ZStack {
            Color.white.ignoresSafeArea(edges: .top)

            Text("알림")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color(hex: "111111"))

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
        .overlay(
            Rectangle()
                .fill(Color.gray500)
                .frame(height: 1),
            alignment: .bottom
        )
    }

    private func notifCard(_ item: NotifItem) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.main700)
                        .frame(width: 7, height: 7)
                    Text(item.timeLabel)
                        .font(.body14R)
                        .foregroundColor(Color.gray800)
                }

                Spacer()

                Button {
                    withAnimation { items.removeAll { $0.id == item.id } }
                } label: {
                    HSIconView(name: .close, color: Color.brown700, size: 24)
                }
            }
            .frame(height: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.body18M)
                    .foregroundColor(Color.brown700)

                HStack(spacing: 4) {
                    Text(item.message)
                        .font(.body14R)
                        .foregroundColor(Color.brown700)
                    Text(item.bpmChange)
                        .font(.body14SB)
                        .foregroundColor(Color.main600)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .frame(height: 111)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(item.isRead ? Color.gray700 : Color.main700, lineWidth: 1)
        )
    }

    private var emptyState: some View {
        VStack(spacing: 24) {
            Image(systemName: "xmark")
                .font(.system(size: 112, weight: .ultraLight))
                .foregroundColor(Color(hex: "D8D0D2"))

            Text("알람이 없어요")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(Color(hex: "D8D0D2"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bg)
    }
}

struct NotifItem: Identifiable {
    let id = UUID()
    let isRead: Bool
    let timeLabel: String
    let title: String
    let message: String
    let bpmChange: String

    static let samples: [NotifItem] = [
        .init(isRead: false, timeLabel: "방금",
              title: "지금 반응이 온 것 같아요 💞",
              message: "상대방의 심박수가 상승했어요",
              bpmChange: "+12 bpm"),
        .init(isRead: false, timeLabel: "방금",
              title: "지금 반응이 온 것 같아요 💞",
              message: "상대방의 심박수가 상승했어요",
              bpmChange: "+12 bpm"),
        .init(isRead: true, timeLabel: "방금",
              title: "지금 반응이 온 것 같아요 💞",
              message: "상대방의 심박수가 상승했어요",
              bpmChange: "+12 bpm"),
        .init(isRead: true, timeLabel: "방금",
              title: "지금 반응이 온 것 같아요 💞",
              message: "상대방의 심박수가 상승했어요",
              bpmChange: "+12 bpm"),
        .init(isRead: true, timeLabel: "방금",
              title: "지금 반응이 온 것 같아요 💞",
              message: "상대방의 심박수가 상승했어요",
              bpmChange: "+12 bpm"),
        .init(isRead: true, timeLabel: "방금",
              title: "지금 반응이 온 것 같아요 💞",
              message: "상대방의 심박수가 상승했어요",
              bpmChange: "+12 bpm")
    ]
}

#Preview {
    NotificationView(isPresented: .constant(true))
}
