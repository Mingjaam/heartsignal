import SwiftUI

struct NotificationCard: View {
    let isRead: Bool
    let timeLabel: String
    let title: String
    let message: String
    let bpmChange: String
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.main700)
                        .frame(width: 7, height: 7)
                    Text(timeLabel)
                        .font(.body14R)
                        .foregroundColor(Color.gray800)
                }
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color.gray900)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body18M)
                    .foregroundColor(Color.brown700)

                HStack(spacing: 4) {
                    Text(message)
                        .font(.body14R)
                        .foregroundColor(Color.brown700)
                    Text(bpmChange)
                        .font(.body14SB)
                        .foregroundColor(Color.main600)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 20)
        .frame(width: 343)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isRead ? Color.gray700 : Color.main700, lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        NotificationCard(
            isRead: false,
            timeLabel: "방금",
            title: "지금 반응이 온 것 같아요 💓",
            message: "상대방의 심박수가 상승했어요",
            bpmChange: "+12 bpm"
        ) {}
        NotificationCard(
            isRead: true,
            timeLabel: "방금",
            title: "지금 반응이 온 것 같아요 💓",
            message: "상대방의 심박수가 상승했어요",
            bpmChange: "+12 bpm"
        ) {}
    }
    .padding()
}
