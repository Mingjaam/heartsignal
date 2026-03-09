import SwiftUI

struct CodeInputField: View {
    @Binding var text: String
    let placeholder: String
    var isValid: Bool = false

    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .font(.body18M)
                .foregroundColor(text.isEmpty ? Color.gray800 : Color.brown700)

            if isValid {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray500)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Image(systemName: "checkmark")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color.gray900)
                            .padding(5)
                    )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 15)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray900, lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        CodeInputField(text: .constant(""), placeholder: "상대의 코드를 입력해주세요.")
        CodeInputField(text: .constant("ABC123"), placeholder: "상대의 코드를 입력해주세요.", isValid: true)
    }
    .padding()
}
