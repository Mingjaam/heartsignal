import SwiftUI

private enum MyPageRoute: Equatable {
    case notificationSettings
    case notices(expanded: Bool)
    case settings
    case contact(ContactInitialState)
}

private enum ContactInitialState: Equatable {
    case empty
    case input
    case ready
}

struct MyPageView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("termsAccepted") private var termsAccepted = false
    @AppStorage("isConnected") private var isConnected = false
    @State private var route: MyPageRoute? = MyPageView.initialRoute

    var onSubpageVisibilityChanged: (Bool) -> Void = { _ in }

    var body: some View {
        Group {
            if let route {
                subpage(for: route)
            } else {
                mainPage
            }
        }
        .onAppear {
            onSubpageVisibilityChanged(route != nil)
        }
        .onChange(of: route) { _, newValue in
            onSubpageVisibilityChanged(newValue != nil)
        }
    }

    @ViewBuilder
    private func subpage(for route: MyPageRoute) -> some View {
        switch route {
        case .notificationSettings:
            NotificationSettingsView {
                self.route = nil
            }
        case .notices(let expanded):
            NoticePageView(initiallyExpanded: expanded) {
                self.route = nil
            }
        case .settings:
            SettingsPageView {
                self.route = nil
            }
        case .contact(let initialState):
            ContactPageView(initialState: initialState) {
                self.route = nil
            }
        }
    }

    private var mainPage: some View {
        VStack(spacing: 0) {
            AppNavBar {
                HSIconView(name: .watchOff, color: Color.brown700)
            }
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    profileCard
                        .padding(.horizontal, 16)
                        .padding(.top, 37)
                        .padding(.bottom, 32)

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
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Text("김미래")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Color(hex: "111111"))
                Image(systemName: "heart.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color.main700)
                Text("박현재")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(Color.gray700)
            }
            .frame(height: 34)

            Rectangle()
                .fill(Color.gray700)
                .frame(height: 1)
                .padding(.horizontal, 36)
                .padding(.top, 3)
                .padding(.bottom, 9)

            HStack(spacing: 4) {
                HSIconView(name: .sendOff, color: Color(hex: "747474"), size: 16)
                Text("대구광역시")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(hex: "747474"))
            }
            .frame(height: 22)
            .padding(.bottom, 8)

            HStack(spacing: 4) {
                Text("💓")
                Text("연결됨")
                    .foregroundColor(Color.main600)
                Text("·")
                    .foregroundColor(Color.gray800)
                    .padding(.horizontal, 4)
                Text("⏱")
                Text("마지막 업데이트")
                    .foregroundColor(Color(hex: "747474"))
                Text("2분전")
                    .foregroundColor(Color.main600)
            }
            .font(.system(size: 16, weight: .regular))
            .frame(height: 22)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 132)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.main700, lineWidth: 1.5)
        )
    }

    // MARK: - 정보 섹션

    private var infoSection: some View {
        VStack(spacing: 0) {
            sectionHeader("정보")
            ListItem(title: "공지사항",         icon: .post,     style: .navigate) {
                route = .notices(expanded: false)
            }
            ListItem(title: "문의하기",          icon: .head,     style: .navigate) {
                route = .contact(.empty)
            }
            ListItem(title: "위치정보 이용약관", icon: .document, style: .navigate) {}
            ListItem(title: "법적고지",          icon: .book,     style: .navigate) {}
            ListItem(title: "앱 버전",           icon: .app,      style: .info(value: "v4.04"))
        }
    }

    // MARK: - 설정 섹션

    private var settingsSection: some View {
        VStack(spacing: 0) {
            sectionHeader("설정")
            ListItem(title: "알림설정", icon: .bellOff, style: .navigate) {
                route = .notificationSettings
            }
            ListItem(title: "설정",     icon: .setting, style: .navigate) {
                route = .settings
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

    private static var initialRoute: MyPageRoute? {
#if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        if let index = arguments.firstIndex(of: "-figmaRoute"),
           arguments.indices.contains(index + 1) {
            switch arguments[index + 1] {
            case "notificationSettings":
                return .notificationSettings
            case "notices":
                return .notices(expanded: false)
            case "noticeDetail":
                return .notices(expanded: true)
            case "settings":
                return .settings
            case "contact":
                return .contact(.empty)
            case "contactInput":
                return .contact(.input)
            case "contactComplete":
                return .contact(.ready)
            default:
                break
            }
        }
#endif
        return nil
    }
}

private struct MyPageSubpageNavBar: View {
    let title: String
    let onBack: () -> Void

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea(edges: .top)

            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color(hex: "111111"))

            HStack {
                Button(action: onBack) {
                    HSIconView(name: .chevronLeft, color: Color.gray900, size: 24)
                }
                .padding(.leading, 16)
                Spacer()
            }
        }
        .frame(height: 50)
        .background(Color.white)
    }
}

private struct NoticePageView: View {
    let onBack: () -> Void
    @State private var expandedIndex: Int?

    init(initiallyExpanded: Bool, onBack: @escaping () -> Void) {
        self.onBack = onBack
        _expandedIndex = State(initialValue: initiallyExpanded ? 0 : nil)
    }

    var body: some View {
        VStack(spacing: 0) {
            MyPageSubpageNavBar(title: "공지사항", onBack: onBack)
            VStack(spacing: 0) {
                ForEach(0..<6, id: \.self) { index in
                    row(index)
                }
                Spacer(minLength: 0)
            }
            .background(Color.bg)
        }
        .background(Color.bg.ignoresSafeArea())
    }

    private func row(_ index: Int) -> some View {
        let expanded = expandedIndex == index
        return VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    expandedIndex = expanded ? nil : index
                }
            } label: {
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(index == 0 ? "2026.04.21" : "Text")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Color.gray800)
                        Text(index == 0 ? "[공지] 하트 시그널에서 알려드립니다." : "Text")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color.brown700)
                    }
                    Spacer()
                    HSIconView(
                        name: expanded ? .chevronUp : .chevronDown,
                        color: Color.gray900,
                        size: 24
                    )
                }
                .padding(.horizontal, 24)
                .frame(height: 62)
                .background(Color.white)
            }
            .buttonStyle(.plain)

            if expanded {
                Text(noticeBody)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color.gray900)
                    .lineSpacing(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 24)
                    .background(Color.white)
            }

            Rectangle()
                .fill(Color.gray500)
                .frame(height: 1)
        }
    }

    private var noticeBody: String {
        "우리 앱의 공지사항은 아무래도 이렇게 나오겠네요. Wish it was a bad trip Wish it was a movie 다 꿈이였음 좋겠지만서도 Yeah lately I cannot let it go"
    }
}

private struct SettingsPageView: View {
    let onBack: () -> Void
    @State private var dataSync = false
    @State private var locationShare = false
    @State private var reactionRecord = false

    var body: some View {
        VStack(spacing: 0) {
            MyPageSubpageNavBar(title: "설정", onBack: onBack)
            VStack(spacing: 0) {
                settingsHeader("기기 연동 상태")
                settingsRow("기기 재연동", showsChevron: true)
                settingsRow("데이터 동기화", isOn: $dataSync)
                settingsGap
                settingsHeader("프라이버시")
                settingsRow("위치 공유", isOn: $locationShare)
                settingsRow("반응 기록 저장", isOn: $reactionRecord)
                settingsGap
                settingsHeader("관계 설정")
                settingsRow("우리 시작일", showsChevron: true)
                settingsRow("연결 관리", showsChevron: true)
                Spacer(minLength: 0)
            }
            .background(Color.bg)
        }
        .background(Color.bg.ignoresSafeArea())
    }

    private var settingsGap: some View {
        Color.bg.frame(height: 16)
    }

    private func settingsHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color.gray900)
            Spacer()
        }
        .padding(.horizontal, 24)
        .frame(height: 52)
        .background(Color.bg)
    }

    private func settingsRow(
        _ title: String,
        showsChevron: Bool = false,
        isOn: Binding<Bool>? = nil
    ) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color.brown700)
            Spacer()
            if let isOn {
                ToggleSwitch(isOn: isOn)
            } else if showsChevron {
                HSIconView(name: .chevronRight, color: Color.gray900, size: 24)
            }
        }
        .padding(.horizontal, 24)
        .frame(height: 52)
        .background(Color.white)
        .overlay(Rectangle().fill(Color.gray500).frame(height: 1), alignment: .bottom)
    }
}

private struct ContactPageView: View {
    let onBack: () -> Void
    @State private var selectedType = "오류 신고"
    @State private var message: String
    @State private var phone: String

    init(initialState: ContactInitialState, onBack: @escaping () -> Void) {
        self.onBack = onBack
        switch initialState {
        case .empty:
            _message = State(initialValue: "")
            _phone = State(initialValue: "")
        case .input:
            _message = State(initialValue: "문의합니다. 나문희")
            _phone = State(initialValue: "")
        case .ready:
            _message = State(initialValue: "문의합니다. 나문희")
            _phone = State(initialValue: "010-1234-5678")
        }
    }

    private var canSubmit: Bool {
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            MyPageSubpageNavBar(title: "문의하기", onBack: onBack)
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    typeChips
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    messageBox
                        .padding(.horizontal, 16)
                        .padding(.top, 12)

                    Color.bg
                        .frame(height: 22)
                        .padding(.top, 16)

                    Text("회신 방법 선택")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.brown700)
                        .padding(.horizontal, 16)
                        .padding(.top, 18)

                    replyRow(title: "문자 메시지", selected: true)
                        .padding(.horizontal, 16)
                        .padding(.top, 18)
                    replyRow(title: "이메일", selected: false, disabled: true)
                        .padding(.horizontal, 16)
                        .padding(.top, 14)

                    TextField("전화번호를 입력해주세요", text: $phone)
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(Color.brown700)
                        .keyboardType(.phonePad)
                        .padding(.horizontal, 12)
                        .frame(height: 53)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.brown700, lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 14)

                    Button {} label: {
                        Text("접수하기")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(canSubmit ? Color.main700 : Color.gray700)
                            .cornerRadius(10)
                    }
                    .disabled(!canSubmit)
                    .padding(.horizontal, 16)
                    .padding(.top, 76)
                    .padding(.bottom, 28)
                }
            }
            .background(Color.white)
        }
        .background(Color.white.ignoresSafeArea())
    }

    private var typeChips: some View {
        HStack(spacing: 6) {
            chip("오류 신고")
            chip("이용 문의")
            chip("개선 제안")
        }
    }

    private func chip(_ title: String) -> some View {
        let selected = selectedType == title
        return Button {
            selectedType = title
        } label: {
            Text(title)
                .font(.system(size: 14, weight: selected ? .semibold : .regular))
                .foregroundColor(selected ? .white : Color.gray900)
                .padding(.horizontal, 14)
                .frame(height: 35)
                .background(selected ? Color.main700 : Color.white)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(selected ? Color.main700 : Color.gray800, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var messageBox: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $message)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.gray900)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)

                if message.isEmpty {
                    Text("문의 내용을 입력해주세요.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color.gray800)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 13)
                }
            }
            .frame(height: 187)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray900, lineWidth: 1)
            )

            Text("200자 / 2000자")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color.gray900)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    private func replyRow(title: String, selected: Bool, disabled: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(disabled ? Color.gray800 : Color.brown700)
            Spacer()
            ZStack {
                Circle()
                    .fill(selected ? Color.main700 : Color.gray700)
                    .frame(width: 24, height: 24)
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 53)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(selected ? Color.main700 : Color.gray800, lineWidth: 1)
        )
    }
}

#Preview {
    MyPageView()
}
