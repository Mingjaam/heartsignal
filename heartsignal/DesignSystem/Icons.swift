import SwiftUI

// MARK: - Icon Names (Figma 아이콘 목록 기반)

enum HSIconName: String {
    // 탭바 아이콘 (on/off)
    case homeOff     = "ic_home_off"
    case homeOn      = "ic_home_on"
    case dateOff     = "ic_date_off"
    case dateOn      = "ic_date_on"
    case sendOff     = "ic_send_off"
    case sendOn      = "ic_send_on"
    case mypageOff   = "ic_mypage_off"
    case mypageOn    = "ic_mypage_on"

    // 상태 아이콘 (on/off)
    case bellOff     = "ic_bell_off"
    case bellOn      = "ic_bell_on"
    case lockOff     = "ic_lock_off"
    case lockOn      = "ic_lock_on"
    case watchOff    = "ic_watch_off"
    case watchOn     = "ic_watch_on"
    case checkOff    = "ic_check_off"
    case checkOn     = "ic_check_on"

    // 단일 아이콘
    case post        = "ic_post"
    case head        = "ic_head"
    case document    = "ic_document"
    case book        = "ic_book"
    case app         = "ic_app"
    case setting     = "ic_setting"
    case close       = "ic_close"
    case plus        = "ic_plus"
    case write       = "ic_write"
    case trash       = "ic_trash"
    case hamburger   = "ic_hamburger"
    case heartbeat   = "ic_heartbeat"
    case heart       = "ic_heart"
    case appmain     = "ic_appmain"

    // 방향 아이콘
    case chevronUp    = "ic_chevron_up"
    case chevronDown  = "ic_chevron_down"
    case chevronLeft  = "ic_chevron_left"
    case chevronRight = "ic_chevron_right"
}

// MARK: - HSIconView

struct HSIconView: View {
    let name: HSIconName
    var color: Color = Color.brown700
    var size: CGFloat = 24

    var body: some View {
        Image(name.rawValue)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .foregroundColor(color)
            .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 16) {
        HStack(spacing: 16) {
            HSIconView(name: .homeOff)
            HSIconView(name: .homeOn, color: .main700)
            HSIconView(name: .dateOff)
            HSIconView(name: .sendOff)
            HSIconView(name: .mypageOff)
        }
        HStack(spacing: 16) {
            HSIconView(name: .bellOff)
            HSIconView(name: .bellOn, color: .main700)
            HSIconView(name: .checkOff, color: .gray700)
            HSIconView(name: .checkOn, color: .main700)
        }
        HStack(spacing: 16) {
            HSIconView(name: .close)
            HSIconView(name: .plus)
            HSIconView(name: .write)
            HSIconView(name: .trash)
            HSIconView(name: .setting)
        }
        HStack(spacing: 16) {
            HSIconView(name: .chevronUp)
            HSIconView(name: .chevronDown)
            HSIconView(name: .chevronLeft)
            HSIconView(name: .chevronRight)
        }
    }
    .padding()
}
