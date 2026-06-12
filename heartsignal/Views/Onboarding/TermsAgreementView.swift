import SwiftUI

struct TermsAgreementView: View {
    let onNext: () -> Void

    @State private var agreeTerms = false
    @State private var agreePrivacy = false

    private var agreeAll: Bool { agreeTerms && agreePrivacy }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("서비스 이용에 동의해주세요.")
                .font(.system(size: 24, weight: .regular))
                .foregroundColor(Color(hex: "111111"))
                .lineSpacing(0)
                .padding(.horizontal, 16)
                .padding(.top, 36)
                .padding(.bottom, 10)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    checkRow(
                        title: "전체 동의하기",
                        isChecked: agreeAll,
                        isBold: true
                    ) {
                        let newValue = !agreeAll
                        agreeTerms = newValue
                        agreePrivacy = newValue
                    }

                    termsBox(text: termsText)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 12)

                    checkRow(
                        title: "서비스 이용약관 동의하기",
                        isChecked: agreeTerms,
                        isBold: false
                    ) {
                        agreeTerms.toggle()
                    }

                    termsBox(text: privacyText)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 12)

                    checkRow(
                        title: "개인정보 및 민감정보 이용 동의하기",
                        isChecked: agreePrivacy,
                        isBold: false
                    ) {
                        agreePrivacy.toggle()
                    }

                    Spacer(minLength: 24)
                }
            }

            PrimaryButton(title: "다음", isEnabled: agreeAll) {
                onNext()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 23)
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
                    .frame(width: 24, height: 24)
                Text(title)
                    .font(.system(size: isBold ? 20 : 16, weight: .regular))
                    .foregroundColor(Color(hex: "111111"))
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: isBold ? 34 : 28)
        }
    }

    // MARK: - 약관 텍스트 박스 (스크롤 가능)

    private func termsBox(text: String) -> some View {
        ScrollView(showsIndicators: false) {
            Text(text)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
        }
        .frame(height: 164)
        .background(Color.gray500)
        .cornerRadius(10)
    }

    // MARK: - 약관 텍스트 (추후 교체 예정)

    private let termsText = """
    제1조 (목적)
    본 약관은 김민재(이하 "운영자")가 제공하는 모바일 애플리케이션 "하트시그널"(이하 "서비스")의 이용과 관련하여 운영자와 이용자 간의 권리·의무 및 책임사항을 규정함을 목적으로 합니다.

    제2조 (정의)
    본 약관에서 사용하는 용어의 정의는 다음과 같습니다.
    "서비스"란 하트시그널 애플리케이션을 통해 제공되는 모든 기능 및 콘텐츠를 의미합니다.
    "이용자"란 본 약관에 동의하고 서비스를 이용하는 자를 의미합니다.
    "계정"이란 서비스 이용을 위해 이용자가 생성한 고유 식별 정보를 의미합니다.
    "커플"이란 서비스 내에서 파트너 연결 기능을 통해 상호 연결된 두 이용자를 의미합니다.
    "심박수 데이터"란 웨어러블 기기 또는 스마트폰을 통해 수집되는 이용자의 심박수 측정값을 의미합니다.
    "위치 데이터"란 이용자의 GPS 기반 위치 정보를 의미합니다.

    제3조 (약관의 효력 및 변경)
    ① 본 약관은 서비스 화면에 게시하거나 이용자에게 통지함으로써 효력이 발생합니다.
    ② 운영자는 관련 법령을 위반하지 않는 범위에서 약관을 변경할 수 있으며, 변경 시 최소 7일 전에 앱 내 공지 또는 등록된 연락처로 통지합니다.
    ③ 이용자가 변경된 약관에 동의하지 않을 경우 서비스 이용을 중단하고 탈퇴할 수 있습니다.

    제4조 (이용 자격 및 가입)
    ① 서비스는 만 19세 이상의 성인만 이용할 수 있습니다.
    ② 이용자는 가입 시 실명 및 정확한 정보를 제공하여야 하며, 허위 정보 제공으로 인한 불이익은 이용자 본인이 책임집니다.
    ③ 1인 1계정 원칙을 적용하며, 타인의 명의를 도용하여 가입하는 행위를 금지합니다.
    ④ 운영자는 다음 각 호에 해당하는 경우 가입을 거절할 수 있습니다.
    만 19세 미만인 경우
    이전에 이용 정지 또는 강제 탈퇴 처리된 경우
    허위 정보를 기재한 경우
    """

    private let privacyText = """
    제7조 (개인정보 및 민감정보 수집·이용)
    ① 운영자는 서비스 제공을 위해 다음의 개인정보를 수집합니다.
    필수 정보: 이메일 주소, 닉네임, 생년월일(성인 인증용)
    건강·민감정보: 심박수 데이터 (이용자 명시적 동의 후 수집)
    위치 정보: GPS 기반 위치 데이터 (이용자 허용 시 수집)
    ② 심박수 데이터 및 위치 데이터는 민감정보에 해당하므로, 이용자의 별도 명시적 동의를 받아 수집합니다.
    ③ 수집된 개인정보는 서비스 제공 목적 이외에 사용되지 않으며, 제3자에게 제공하지 않습니다. 단, 법령에 따른 의무적 제공의 경우는 예외로 합니다.
    ④ 상세한 개인정보 처리 방침은 앱 내 별도의 "개인정보처리방침"을 통해 확인할 수 있습니다.
    """
}

#Preview {
    TermsAgreementView(onNext: {})
}
