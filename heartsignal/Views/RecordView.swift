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
                }
                .padding(.bottom, 100)
            }
            .background(Color.bg)
        }
        .background(Color.bg)
    }

    private var navigationBar: some View {
        AppNavBar()
    }

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
                    .fill(Color.clear)
                    .frame(width: 4, height: 4)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
        .buttonStyle(.plain)
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
}

#Preview {
    RecordView()
}
