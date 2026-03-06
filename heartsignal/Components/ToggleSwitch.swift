import SwiftUI

struct ToggleSwitch: View {
    @Binding var isOn: Bool

    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            ZStack(alignment: isOn ? .trailing : .leading) {
                Capsule()
                    .fill(isOn ? Color.main700 : Color.gray800)
                    .frame(width: 42, height: 23)

                Circle()
                    .fill(Color.white)
                    .frame(width: 19, height: 19)
                    .padding(.leading, isOn ? 0 : 2)
                    .padding(.trailing, isOn ? 2 : 0)
            }
        }
        .animation(.spring(response: 0.2), value: isOn)
    }
}

#Preview {
    VStack(spacing: 20) {
        ToggleSwitch(isOn: .constant(true))
        ToggleSwitch(isOn: .constant(false))
    }
}
