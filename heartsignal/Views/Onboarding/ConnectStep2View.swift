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

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Text("2 / 5 단계")
                        .font(.system(size: 13))
                        .foregroundColor(Color.gray900)
                        .padding(.top, 36)
                        .padding(.bottom, 12)

                    Text("상대방의 코드를\n입력해주세요.")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color.brown700)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    Image("img_connect_ecg")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)

                    // 내 코드
                    HStack(spacing: 6) {
                        Text("내 코드")
                            .font(.system(size: 14))
                            .foregroundColor(Color.gray900)
                        Text(myCode)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color.brown700)
                        Button {
                            UIPasteboard.general.string = myCode
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 13))
                                .foregroundColor(Color.gray900)
                        }
                    }
                    .padding(.bottom, 16)

                    // 코드 입력 필드
                    TextField("상대의 코드를 입력해주세요.", text: $partnerCode)
                        .font(.system(size: 16))
                        .foregroundColor(Color.brown700)
                        .keyboardType(.numberPad)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray700, lineWidth: 1)
                        )
                        .padding(.horizontal, 24)
                }
            }

            PrimaryButton(title: "다음", isEnabled: !partnerCode.isEmpty) {
                onNext(partnerCode)
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 44)
        }
        .background(Color.white.ignoresSafeArea())
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
