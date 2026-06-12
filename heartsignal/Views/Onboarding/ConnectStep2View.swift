import SwiftUI
import UIKit

struct ConnectStep2View: View {
    let myCode: String
    let onBack: () -> Void
    let onNext: (String) -> Void  // partnerCode

    @State private var partnerCode = ""

    var body: some View {
        VStack(spacing: 0) {
            navBar

            GeometryReader { proxy in
                let width = proxy.size.width
                let scale = width / 375

                ZStack(alignment: .top) {
                    stepText(current: "2")
                        .position(x: width / 2, y: 73 * scale)

                    Text("휴대폰을 서로 가까이 하거나\n상대방의 코드를 입력해주세요.")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundColor(Color(hex: "111111"))
                        .lineSpacing(0)
                        .multilineTextAlignment(.center)
                        .frame(width: 288 * scale, height: 68 * scale)
                        .position(x: width / 2, y: 126 * scale)

                    Image("img_connect_ecg")
                        .resizable()
                        .frame(width: width, height: 83 * scale)
                        .position(x: width / 2, y: 239 * scale)

                    VStack(spacing: 17) {
                        HStack(spacing: 6) {
                            Text("내 코드")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(Color.gray800)
                            Text(myCode)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(hex: "111111"))
                            Button {
                                UIPasteboard.general.string = myCode
                            } label: {
                                Image(systemName: "doc.on.doc.fill")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color.gray800)
                            }
                        }

                        TextField("상대의 코드를 입력해주세요.", text: $partnerCode)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(hex: "111111"))
                            .keyboardType(.numberPad)
                            .padding(.horizontal, 12)
                            .frame(height: 55)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.brown700, lineWidth: 1)
                            )
                    }
                    .frame(width: 343 * scale, height: 96 * scale)
                    .position(x: width / 2, y: 361 * scale)

                    VStack {
                        Spacer()
                        PrimaryButton(title: "다음", isEnabled: !partnerCode.isEmpty) {
                            onNext(partnerCode)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 23)
                    }
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
    }

    private func stepText(current: String) -> some View {
        HStack(spacing: 4) {
            Text(current)
                .foregroundColor(Color(hex: "111111"))
            Text("/")
                .foregroundColor(Color.gray700)
            Text("5")
                .foregroundColor(Color.gray700)
            Text("단계")
                .foregroundColor(Color.gray700)
        }
        .font(.body14R)
        .frame(height: 20)
    }

    private var navBar: some View {
        ZStack {
            Color.white.ignoresSafeArea(edges: .top)
            HStack {
                Button { onBack() } label: {
                    HSIconView(name: .chevronLeft, color: Color.brown700)
                }
                .padding(.leading, 16)
                Spacer()
                HStack(spacing: 6) {
                    Image("ic_appmain")
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text("하트시그널")
                        .font(.body18M)
                        .foregroundColor(Color.brown700)
                }
                Spacer()
                HSIconView(name: .chevronLeft, color: .clear)
                    .padding(.trailing, 16)
            }
        }
        .frame(height: 50)
        .shadow(color: Color.gray500, radius: 0, x: 0, y: 1)
    }
}

#Preview {
    ConnectStep2View(myCode: "123456", onBack: {}, onNext: { _ in })
}
