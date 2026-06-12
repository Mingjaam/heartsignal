import SwiftUI

struct MyPageView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("termsAccepted") private var termsAccepted = false
    @AppStorage("isConnected") private var isConnected = false

    var body: some View {
        VStack(spacing: 0) {
            AppNavBar {
                HSIconView(name: .watchOff, color: Color.brown700)
            }
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    profileCard
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .padding(.bottom, 24)

                    infoSection
                    settingsSection
                }
                .padding(.bottom, 100)
            }
            .background(Color.bg)
        }
        .background(Color.bg)
    }

    // MARK: - 프로필 카드

    private var profileCard: some View {
        VStack(spacing: 10) {
            // 이름
            HStack(spacing: 8) {
                Text("김미래")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color.brown700)
                Image(systemName: "heart.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color.main700)
                Text("박현재")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color.brown700)
            }

            // 위치
            HStack(spacing: 4) {
                HSIconView(name: .sendOff, color: Color.gray900, size: 14)
                Text("대구광역시")
                    .font(.body14R)
                    .foregroundColor(Color.gray900)
            }

            // 연결 상태
            HStack(spacing: 6) {
                HStack(spacing: 3) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 11))
                        .foregroundColor(Color.main700)
                    Text("연결됨")
                        .font(.body12R)
                        .foregroundColor(Color.main700)
                }
                Text("•")
                    .font(.body12R)
                    .foregroundColor(Color.gray800)
                HStack(spacing: 3) {
                    HSIconView(name: .watchOff, color: Color.gray900, size: 13)
                    Text("마지막 업데이트 ")
                        .font(.body12R)
                        .foregroundColor(Color.gray900)
                    + Text("2분전")
                        .font(.body12R)
                        .foregroundColor(Color.main700)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.main700, lineWidth: 1.5)
        )
    }

    // MARK: - 정보 섹션

    private var infoSection: some View {
        VStack(spacing: 0) {
            sectionHeader("정보")
            ListItem(title: "공지사항",         icon: .post,     style: .navigate) {}
            ListItem(title: "문의하기",          icon: .head,     style: .navigate) {}
            ListItem(title: "위치정보 이용약관", icon: .document, style: .navigate) {}
            ListItem(title: "법적고지",          icon: .book,     style: .navigate) {}
            ListItem(title: "앱 버전",           icon: .app,      style: .info(value: "v4.04"))
        }
    }

    // MARK: - 설정 섹션

    private var settingsSection: some View {
        VStack(spacing: 0) {
            sectionHeader("설정")
            ListItem(title: "알림설정", icon: .bellOff, style: .navigate) {}
            ListItem(title: "설정",     icon: .setting, style: .navigate) {}
            ListItem(title: "로그아웃", icon: .close,   style: .navigate) {
                isConnected = false
                termsAccepted = false
                isLoggedIn = false
            }
        }
    }

    // MARK: - 섹션 헤더

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.body14R)
                .foregroundColor(Color.gray900)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 8)
        .background(Color.bg)
    }
}

#Preview {
    MyPageView()
}
