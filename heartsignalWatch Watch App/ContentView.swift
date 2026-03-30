import SwiftUI

struct ContentView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("하트시그널")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 8)
        }
        .background(Color.black)
    }
}

#Preview {
    ContentView()
}
