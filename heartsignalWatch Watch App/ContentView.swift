import SwiftUI
import HealthKit

struct ContentView: View {
    @State private var heartRate: Double = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                VStack(spacing: 4) {
                    Text("나")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)

                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text(heartRate > 0 ? "\(Int(heartRate))" : "--")
                            .font(.system(size: 44, weight: .semibold))
                            .foregroundColor(.white)
                        Text("bpm")
                            .font(.system(size: 13))
                            .foregroundColor(Color(red: 1, green: 0, blue: 0.55))
                            .padding(.bottom, 6)
                    }

                    Image(systemName: "heart.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 1, green: 0, blue: 0.55))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(white: 0.12))
                .cornerRadius(12)
            }
            .padding(.horizontal, 8)
        }
        .background(Color.black)
    }
}

#Preview {
    ContentView()
}
