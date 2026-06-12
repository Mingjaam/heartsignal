import SwiftUI

struct DailyRecord: Identifiable {
    let id = UUID()
    var title: String
    var subtitle: String
    var time: Date
    var emoji: String
    var note: String
}

struct RecordView: View {
    @EnvironmentObject var connectivity: PhoneConnectivityManager
    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date = Date()
    @State private var autoRecord: Bool = false
    @State private var showWatchInfo: Bool = false
    @State private var showDayDetail: Bool = false
    @State private var records: [Date: [DailyRecord]] = [:]

    private let calendar = Calendar.current
    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]

    private let loveStartDate: Date = {
        var comps = DateComponents()
        comps.year = 2026
        comps.month = 4
        comps.day = 10
        return Calendar.current.date(from: comps) ?? Date()
    }()

    private var isWatchConnected: Bool { connectivity.isWatchReachable }

    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    dDaySection
                        .padding(.top, 32)
                        .padding(.bottom, 32)

                    calendarSection

                    legendSection
                        .padding(.top, 16)
                        .padding(.bottom, 40)
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .sheet(isPresented: $showWatchInfo) {
            WatchInfoSheet(isPresented: $showWatchInfo, isConnected: isWatchConnected, heartRate: connectivity.watchHeartRate)
                .presentationDetents([.height(280)])
                .presentationCornerRadius(24)
        }
        .sheet(isPresented: $showDayDetail) {
            DayDetailSheet(
                date: selectedDate,
                records: $records
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(24)
        }
    }

    // MARK: - D-Day

    private var dDaySection: some View {
        let days = (calendar.dateComponents([.day], from: loveStartDate, to: Date()).day ?? 0) + 1
        return HStack(spacing: 0) {
            Text("우리의 사랑 ")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color.brown700)
            Text("D+\(days) ")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color.main700)
            Text("진행 중")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color.brown700)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Navigation Bar

    private var navigationBar: some View {
        AppNavBar {
            Button { showWatchInfo = true } label: {
                HSIconView(name: isWatchConnected ? .watchOn : .watchOff, color: Color.brown700)
            }
        }
    }

    // MARK: - Calendar

    private var calendarSection: some View {
        VStack(spacing: 0) {
            monthHeader
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 20)

            weekdayHeader
                .padding(.horizontal, 16)
                .padding(.bottom, 12)

            calendarGrid
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
        }
        .background(Color.white)
    }

    private var monthHeader: some View {
        HStack {
            Button {} label: {
                HStack(spacing: 4) {
                    Text(monthTitle(currentMonth))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.brown700)
                    HSIconView(name: .chevronDown, color: Color.brown700, size: 16)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            HStack(spacing: 6) {
                Text("자동기록")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.gray900)
                Toggle("", isOn: $autoRecord)
                    .labelsHidden()
                    .scaleEffect(0.8)
                    .tint(Color.main700)
            }
        }
    }

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(day == "일" ? Color.main700 : Color.gray900)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var calendarGrid: some View {
        let days = generateDays(for: currentMonth)
        let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(days) { day in
                dayCell(day)
            }
        }
    }

    private func dayCell(_ day: CalendarDay) -> some View {
        let date = day.date
        let isToday = calendar.isDateInToday(date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isSunday = calendar.component(.weekday, from: date) == 1
        let dayNum = calendar.component(.day, from: date)
        let dayRecords = dailyRecords(for: date)
        let eventEmoji = dayRecords.first?.emoji

        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                selectedDate = date
                showDayDetail = true
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(Color.main700)
                            .frame(width: 36, height: 36)
                    } else if isToday {
                        Circle()
                            .stroke(Color.main700, lineWidth: 1.5)
                            .frame(width: 36, height: 36)
                    }
                    Text("\(dayNum)")
                        .font(.system(size: 15, weight: isToday || isSelected ? .semibold : .regular))
                        .foregroundColor(
                            isSelected ? .white :
                            !day.isCurrentMonth ? Color.gray :
                            isToday ? Color.main700 :
                            isSunday ? Color.main700 :
                            Color.brown700
                        )
                }
                .frame(width: 36, height: 36)

                if let eventEmoji {
                    Text(eventEmoji)
                        .font(.system(size: 14))
                } else if !dayRecords.isEmpty {
                    Circle()
                        .fill(Color.main700.opacity(0.4))
                        .frame(width: 4, height: 4)
                } else {
                    Color.clear.frame(height: 18)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 72)
        }
        .buttonStyle(.plain)
    }

    private func dailyRecords(for date: Date) -> [DailyRecord] {
        records[calendar.startOfDay(for: date)] ?? []
    }

    // MARK: - Legend

    private var legendSection: some View {
        HStack(spacing: 24) {
            legendItem(emoji: "❤️‍🔥", text: "심박수 상승")
            legendItem(emoji: "💓", text: "보통")
            legendItem(emoji: "👥", text: "데이트")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    private func legendItem(emoji: String, text: String) -> some View {
        HStack(spacing: 4) {
            Text(emoji)
                .font(.system(size: 13))
            Text(text)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color.brown700)
        }
    }

    // MARK: - Calendar Helpers

    private func monthTitle(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: date)
    }

    private func generateDays(for month: Date) -> [CalendarDay] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month),
              let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else { return [] }

        var days: [CalendarDay] = []
        var date = firstWeek.start

        for _ in 0..<42 {
            let isCurrentMonth = calendar.isDate(date, equalTo: month, toGranularity: .month)
            days.append(CalendarDay(date: date, isCurrentMonth: isCurrentMonth))
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = nextDate
        }

        while days.count >= 7 {
            let lastWeek = days.suffix(7)
            if lastWeek.allSatisfy({ !calendar.isDate($0.date, equalTo: month, toGranularity: .month) }) {
                days.removeLast(7)
            } else {
                break
            }
        }

        return days
    }
}

// MARK: - 날짜별 기록 모달 (Bottom Sheet)

struct DayDetailSheet: View {
    let date: Date
    @Binding var records: [Date: [DailyRecord]]
    @Environment(\.dismiss) private var dismiss

    @State private var showAddSheet = false

    private var calendar: Calendar { .current }
    private var dateKey: Date { calendar.startOfDay(for: date) }
    private var dayRecords: [DailyRecord] { records[dateKey] ?? [] }

    private var solarFormatter: DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M월 d일 EEEE"
        return f
    }

    var body: some View {
        VStack(spacing: 0) {
            // 날짜 헤더
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text(solarFormatter.string(from: date))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color.brown700)
                Text(LunarDateHelper.string(from: date))
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.gray900)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 36)
            .padding(.bottom, 12)

            if dayRecords.isEmpty {
                emptyView
            } else {
                List {
                    ForEach(dayRecords) { record in
                        RecordListRow(record: record)
                            .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.white)
                    }
                    .onDelete(perform: deleteRecord)
                }
                .listStyle(.plain)
            }

            Spacer()

            // + 버튼
            HStack {
                Spacer()
                Button {
                    showAddSheet = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.main700)
                            .frame(width: 56, height: 56)
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .sheet(isPresented: $showAddSheet) {
            AddRecordSheet(date: date) { newRecord in
                var list = records[dateKey] ?? []
                list.append(newRecord)
                records[dateKey] = list
            }
            .presentationDetents([.large])
            .presentationCornerRadius(24)
        }
    }

    private var emptyView: some View {
        VStack(spacing: 8) {
            Image(systemName: "doc.text")
                .font(.system(size: 32))
                .foregroundColor(Color.gray800)
            Text("기록이 없어요")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color.gray900)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private func deleteRecord(at offsets: IndexSet) {
        guard var list = records[dateKey] else { return }
        list.remove(atOffsets: offsets)
        records[dateKey] = list.isEmpty ? nil : list
    }
}

// MARK: - 기록 행 (모달 내부용)

struct RecordListRow: View {
    let record: DailyRecord

    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "a h:mm"
        return f
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(record.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color.brown700)
                    Text(record.emoji)
                        .font(.system(size: 14))
                }
                Text(record.subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.gray900)
            }
            Spacer()
            Text(timeFormatter.string(from: record.time))
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color.gray800)
        }
        .padding(.vertical, 14)
        .background(Color.white)
        .overlay(
            Rectangle()
                .fill(Color.gray500.opacity(0.4))
                .frame(height: 0.5),
            alignment: .bottom
        )
    }
}

// MARK: - 기록 추가 Sheet

struct AddRecordSheet: View {
    let date: Date
    var onConfirm: (DailyRecord) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var note: String = ""
    @State private var time: Date = Date()
    @State private var selectedEmoji: String = "❤️‍🔥"
    @State private var showTimePicker: Bool = false

    private let emojis = ["❤️‍🔥", "💓", "👥", "🔥", "😍", "🥰"]

    private var solarFormatter: DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M월 d일 EEEE"
        return f
    }

    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "a h:mm"
        return f
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    titleSection
                    dateTimeSection
                    emojiSection
                    noteSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
            }

            confirmButton
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
        }
        .background(Color.white.ignoresSafeArea())
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("기록 내용")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(hex: "8D8D8D"))
            Text(solarFormatter.string(from: date))
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color.brown700)
            Text(LunarDateHelper.string(from: date))
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color.gray900)
        }
    }

    private var dateTimeSection: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.spring()) {
                    showTimePicker.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    Text(timeFormatter.string(from: time))
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(Color.brown700)
                    Text(selectedEmoji)
                        .font(.system(size: 18))
                    Text(note.isEmpty ? "평균 심박수 123 bpm" : note)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color.gray900)
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(Color.gray800)
                        .rotationEffect(.degrees(showTimePicker ? 180 : 0))
                }
            }
            .buttonStyle(.plain)
            .padding(.vertical, 4)

            if showTimePicker {
                VStack(spacing: 0) {
                    Divider().background(Color.gray500)
                    DatePicker(
                        "",
                        selection: $time,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .environment(\.locale, Locale(identifier: "ko_KR"))
                    Divider().background(Color.gray500)
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var emojiSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("기록 타입")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.gray900)

            HStack(spacing: 12) {
                ForEach(emojis, id: \.self) { emoji in
                    Button {
                        selectedEmoji = emoji
                    } label: {
                        Text(emoji)
                            .font(.system(size: 28))
                            .frame(width: 48, height: 48)
                            .background(
                                Circle()
                                    .fill(selectedEmoji == emoji ? Color.main700.opacity(0.15) : Color.clear)
                            )
                            .overlay(
                                Circle()
                                    .stroke(selectedEmoji == emoji ? Color.main700 : Color.clear, lineWidth: 2)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("내용을 입력해주세요.", text: $note, axis: .vertical)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color.brown700)
                .lineLimit(3...6)
            Divider()
                .background(Color.gray500)
        }
    }

    private var confirmButton: some View {
        Button {
            let record = DailyRecord(
                title: title.isEmpty ? "심박수 최고조!!" : title,
                subtitle: "\(timeFormatter.string(from: time)) · \(note.isEmpty ? "평균 심박수 123 bpm" : note)",
                time: time,
                emoji: selectedEmoji,
                note: note
            )
            onConfirm(record)
            dismiss()
        } label: {
            Text("확인")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.main700)
                .cornerRadius(12)
        }
    }
}

// MARK: - 음력 변환 (Apple 내장 Chinese Calendar = 한국 음력 동일 체계)

private struct LunarDateHelper {
    private static let lunarCalendar = Calendar(identifier: .chinese)

    static func string(from solarDate: Date) -> String {
        let components = lunarCalendar.dateComponents([.year, .month, .day, .isLeapMonth], from: solarDate)
        guard let month = components.month, let day = components.day else { return "" }
        let isLeap = components.isLeapMonth == true
        let leapPrefix = isLeap ? "윤" : ""
        return "음력 \(leapPrefix)\(month)월 \(day)일"
    }
}

// MARK: - Supporting Types

struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date
    let isCurrentMonth: Bool
}

enum EventType {
    case heartRise, normal, date
    var emoji: String {
        switch self {
        case .heartRise: return "❤️‍🔥"
        case .normal: return "💓"
        case .date: return "👥"
        }
    }
}

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

struct RecordItem: Identifiable {
    let id = UUID()
    let type: RecordEventType
    let title: String
    let subtitle: String
    let timeLabel: String
    let valueLabel: String
}

struct RecordRowView: View {
    let item: RecordItem
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(item.type.iconBackground).frame(width: 44, height: 44)
                HSIconView(name: item.type.icon, color: .white, size: 22)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(item.title).font(.system(size: 14, weight: .semibold)).foregroundColor(Color.brown700)
                Text(item.subtitle).font(.system(size: 12, weight: .regular)).foregroundColor(Color.gray900)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text(item.timeLabel).font(.system(size: 12, weight: .regular)).foregroundColor(Color.gray800)
                Text(item.valueLabel).font(.system(size: 14, weight: .semibold)).foregroundColor(item.type.valueColor)
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
        .environmentObject(PhoneConnectivityManager.shared)
}
