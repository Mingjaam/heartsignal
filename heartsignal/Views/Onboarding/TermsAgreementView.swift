import SwiftUI

struct TermsAgreementView: View {
    let onNext: () -> Void

    @State private var agreeTerms = false
    @State private var agreePrivacy = false

    private var agreeAll: Bool { agreeTerms && agreePrivacy }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 타이틀
            Text("서비스 이용에\n동의해주세요.")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(Color.brown700)
                .padding(.horizontal, 24)
                .padding(.top, 56)
                .padding(.bottom, 28)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // 전체 동의
                    checkRow(
                        title: "전체 동의하기",
                        isChecked: agreeAll,
                        isBold: true
                    ) {
                        let newValue = !agreeAll
                        agreeTerms = newValue
                        agreePrivacy = newValue
                    }

                    // 서비스 이용약관 박스
                    termsBox(text: termsText)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        .padding(.bottom, 16)

                    // 서비스 이용약관 동의
                    checkRow(
                        title: "서비스 이용약관 동의하기",
                        isChecked: agreeTerms,
                        isBold: false
                    ) {
                        agreeTerms.toggle()
                    }

                    // 개인정보 박스
                    termsBox(text: privacyText)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        .padding(.bottom, 16)

                    // 개인정보 동의
                    checkRow(
                        title: "개인정보 및 민감정보 이용 동의하기",
                        isChecked: agreePrivacy,
                        isBold: false
                    ) {
                        agreePrivacy.toggle()
                    }

                    Spacer(minLength: 40)
                }
            }

            PrimaryButton(title: "다음", isEnabled: agreeAll) {
                onNext()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 44)
            .padding(.top, 12)
        }
        .background(Color.white.ignoresSafeArea())
    }

    // MARK: - 체크 행

    private func checkRow(title: String, isChecked: Bool, isBold: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(isChecked ? HSIconName.checkOn.rawValue : HSIconName.checkOff.rawValue)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                Text(title)
                    .font(isBold ? .body18SB : .body16R)
                    .foregroundColor(Color.brown700)
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
        }
    }

    // MARK: - 약관 텍스트 박스 (스크롤 가능)

    private func termsBox(text: String) -> some View {
        ScrollView(showsIndicators: false) {
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(Color.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
        }
        .frame(height: 140)
        .background(Color(hex: "F2F2F2"))
        .cornerRadius(10)
    }

    // MARK: - 약관 텍스트 (추후 교체 예정)

    private let termsText = """
    제1조 (목적)
    본 약관은 김민재(이하 "운영자")가 제공하는 모바일 애플리케이션 "하트시그널"(이하 "서비스")의 이용과 관련하여 운영자와 이용자 간의 권리·의무 및 책임사항을 규정함을 목적으로 합니다.

    제2조 (정의)
    """

    private let privacyText = """
    제7조 (개인정보 및 민감정보 수집·이용)
    ① 운영자는 서비스 제공을 위해 다음의 개인정보를 수집합니다.
    필수 정보: 이메일 주소, 닉네임, 생년월일(성인 인증용)
    건강·민감정보: 심박수 데이터 (이용자 명시적 동의 후 수집)
    """
}

#Preview {
    TermsAgreementView(onNext: {})
}
