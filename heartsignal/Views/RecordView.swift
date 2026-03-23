import SwiftUI

struct RecordView: View {
    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date = Date()

    private let calendar = Calendar.current
    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]

    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    calendarSection
                    Divider()
                        .background(Color.gray500)
                    recordListSection
                }
                .padding(.bottom, 100)
            }
            .background(Color.bg)
        }
        .background(Color.bg)
    }

    // MARK: - 네비게이션 바

    private var navigationBar: some View {
        AppNavBar()
    }

    // MARK: - 캘린더

    private var calendarSection: some View {
        VStack(spacing: 0) {
            monthHeader
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
            weekdayHeader
                .padding(.horizontal, 16)
            calendarGrid
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
        }
        .background(Color.white)
    }

    private var monthHeader: some View {
        HStack {
            Button {
                currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
            } label: {
                HSIconView(name: .chevronLeft, color: Color.brown700, size: 20)
            }
            Spacer()
            Text(monthTitle(currentMonth))
                .font(.body18SB)
                .foregroundColor(Color.brown700)
            Spacer()
            Button {
                currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
            } label: {
                HSIconView(name: .chevronRight, color: Color.brown700, size: 20)
            }
        }
    }

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(day == "일" ? Color.main700 : Color.gray900)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.bottom, 8)
    }

    private var calendarGrid: some View {
        let days = generateDays(for: currentMonth)
        let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
        return LazyVGrid(columns: columns, spacing: 4) {
            ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                if let day {
                    dayCell(day)
                } else {
                    Color.clear.frame(height: 44)
                }
            }
        }
    }

    private func dayCell(_ date: Date) -> some View {
        let isToday = calendar.isDateInToday(date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let hasEvent = sampleEvents[calendar.startOfDay(for: date)] != nil
        let dayNum = calendar.component(.day, from: date)
        let weekday = calendar.component(.weekday, from: date)
        let isSunday = weekday == 1

        return Button {
            selectedDate = date
        } label: {
            VStack(spacing: 3) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(Color.main700)
                            .frame(width: 34, height: 34)
                    } else if isToday {
                        Circle()
                            .stroke(Color.main700, lineWidth: 1.5)
                            .frame(width: 34, height: 34)
                    }
                    Text("\(dayNum)")
                        .font(.system(size: 14, weight: isToday || isSelected ? .semibold : .regular))
                        .foregroundColor(
                            isSelected ? .white :
                            isToday ? Color.main700 :
                            isSunday ? Color.main700.opacity(0.7) :
                            Color.brown700
                        )
                }
                .frame(width: 34, height: 34)

                Circle()
                    .fill(hasEvent ? Color.main700 : Color.clear)
                    .frame(width: 4, height: 4)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
        .buttonStyle(.plain)
    }

    // MARK: - 기록 목록

    private var recordListSection: some View {
        let items = sampleEvents[calendar.startOfDay(for: selectedDate)] ?? []
        return VStack(alignment: .leading, spacing: 0) {
            Text(selectedDateLabel)
                .font(.body14SB)
                .foregroundColor(Color.brown700)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 12)

            if items.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "heart.slash")
                        .font(.system(size: 28))
                        .foregroundColor(Color.gray800)
                    Text("이날은 기록이 없어요")
                        .font(.body14R)
                        .foregroundColor(Color.gray900)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(items) { item in
                    RecordRowView(item: item)
                }
            }
        }
    }

    // MARK: - Helpers

    private var selectedDateLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 EEEE"
        return formatter.string(from: selectedDate)
    }

    private func monthTitle(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: date)
    }

    private func generateDays(for month: Date) -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: month),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: month))
        else { return [] }

        let firstWeekday = (calendar.component(.weekday, from: firstDay) - 1)
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        while days.count % 7 != 0 { days.append(nil) }
        return days
    }

    // 날짜별 이벤트 샘플 데이터
    private var sampleEvents: [Date: [RecordItem]] {
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!

        return [
            today: [
                .init(type: .heartRiseBoth, title: "둘 다 텐션 올라가는 중 💓", subtitle: "양쪽 심박수가 동시에 상승했어요", timeLabel: "방금", valueLabel: "+8 bpm"),
                .init(type: .heartRisePartner, title: "반응이 온 것 같아요 💓", subtitle: "상대방의 심박수가 상승했어요", timeLabel: "5분 전", valueLabel: "+12 bpm"),
                .init(type: .messageSent, title: "시그널을 보냈어요", subtitle: "너에게 가는 중 💓", timeLabel: "1시간 전", valueLabel: "전송"),
            ],
            yesterday: [
                .init(type: .heartRiseMine, title: "내 심박수가 상승했어요", subtitle: "갑자기 심박수가 빨라졌어요", timeLabel: "14:30", valueLabel: "+15 bpm"),
                .init(type: .sleep, title: "수면 상태 감지", subtitle: "상대방이 수면 중이에요", timeLabel: "23:40", valueLabel: "낮음"),
            ],
            twoDaysAgo: [
                .init(type: .messageSent, title: "시그널을 보냈어요", subtitle: "보고 싶어 💓", timeLabel: "11:20", valueLabel: "전송"),
            ],
        ]
    }
}

// MARK: - 기록 이벤트 타입

enum RecordEventType {
    case heartRisePartner, heartRiseMine, heartRiseBoth, sleep, messageSent

    var icon: HSIconName {
        switch self {
        case .heartRisePartner, .heartRiseMine, .heartRiseBoth: return .bellOn
        case .sleep:        return .watchOn
        case .messageSent:  return .sendOn
        }
    }

    var iconBackground: Color {
        switch self {
        case .heartRisePartner, .heartRiseBoth: return Color.main700
        case .heartRiseMine:  return Color.main600
        case .sleep:          return Color.gray800
        case .messageSent:    return Color.brown700
        }
    }

    var valueColor: Color {
        switch self {
        case .heartRisePartner, .heartRiseBoth, .heartRiseMine: return Color.main700
        case .sleep:       return Color.gray900
        case .messageSent: return Color.brown700
        }
    }
}

// MARK: - 기록 데이터 모델

struct RecordItem: Identifiable {
    let id = UUID()
    let type: RecordEventType
    let title: String
    let subtitle: String
    let timeLabel: String
    let valueLabel: String
}

// MARK: - 기록 행 컴포넌트

struct RecordRowView: View {
    let item: RecordItem

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(item.type.iconBackground)
                    .frame(width: 44, height: 44)
                HSIconView(name: item.type.icon, color: .white, size: 22)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.body14SB)
                    .foregroundColor(Color.brown700)
                Text(item.subtitle)
                    .font(.body12R)
                    .foregroundColor(Color.gray900)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text(item.timeLabel)
                    .font(.body12R)
                    .foregroundColor(Color.gray800)
                Text(item.valueLabel)
                    .font(.body14SB)
                    .foregroundColor(item.type.valueColor)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.white)
        .overlay(Rectangle().frame(height: 1).foregroundColor(Color.gray500), alignment: .bottom)
    }
}

#Preview {
    RecordView()
}
