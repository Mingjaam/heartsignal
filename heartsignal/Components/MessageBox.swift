import SwiftUI

enum MessageBoxState {
    case upload
    case input(text: String)
    case enter(text: String)
}

struct MessageBox: View {
    let state: MessageBoxState
    let onUpload: () -> Void
    let onSubmit: () -> Void

    var body: some View {
        ZStack {
            switch state {
            case .upload:
                uploadView
            case .input(let text):
                inputView(text: text)
            case .enter(let text):
                enterView(text: text)
            }
        }
        .frame(width: 147, height: 85)
        .background(backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.main600, style: strokeStyle)
        )
    }

    private var uploadView: some View {
        Button {
            onUpload()
        } label: {
            Image(systemName: "plus")
                .frame(width: 24, height: 24)
                .foregroundColor(Color.main700)
        }
    }

    private func inputView(text: String) -> some View {
        HStack {
            Spacer()
            VStack {
                Image(systemName: "pencil")
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color.main700)
                Spacer()
            }
        }
        .overlay(
            HStack(spacing: 2) {
                Text(text)
                    .font(.body16R)
                    .foregroundColor(Color.brown700)
                Text("💓")
                    .font(.system(size: 20, weight: .semibold))
            }
            .padding(.top, 47)
            .padding(.leading, 10),
            alignment: .topLeading
        )
        .padding(10)
    }

    private func enterView(text: String) -> some View {
        HStack {
            Spacer()
            VStack {
                Button {
                    onSubmit()
                } label: {
                    Text("등록")
                        .font(.body12R)
                        .foregroundColor(.white)
                        .frame(width: 36, height: 24)
                        .background(Color.main700)
                        .cornerRadius(8)
                }
                Spacer()
            }
        }
        .overlay(
            HStack(spacing: 2) {
                Text(text)
                    .font(.body16R)
                    .foregroundColor(Color.gray900)
                Text("💓")
                    .font(.system(size: 20, weight: .semibold))
            }
            .padding(.top, 47)
            .padding(.leading, 10),
            alignment: .topLeading
        )
        .padding(10)
    }

    private var backgroundColor: Color {
        switch state {
        case .upload: return .white
        case .input, .enter: return Color.bg
        }
    }

    private var strokeStyle: StrokeStyle {
        switch state {
        case .upload: return StrokeStyle(lineWidth: 1, dash: [5, 5])
        case .input, .enter: return StrokeStyle(lineWidth: 1)
        }
    }
}

#Preview {
    HStack(spacing: 8) {
        MessageBox(state: .upload, onUpload: {}, onSubmit: {})
        MessageBox(state: .input(text: "너에게 가는 중"), onUpload: {}, onSubmit: {})
        MessageBox(state: .enter(text: "너에게 가는 중"), onUpload: {}, onSubmit: {})
    }
    .padding()
}
