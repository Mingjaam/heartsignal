import SwiftUI

struct PrimaryButton: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.body18SB)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(isEnabled ? Color.main700 : Color.gray700)
                .cornerRadius(10)
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "시작하기", isEnabled: true) {}
        PrimaryButton(title: "시작하기", isEnabled: false) {}
    }
    .padding()
}
