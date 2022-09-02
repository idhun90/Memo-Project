import UIKit

extension UITableViewCell {
    
    func calculateDateFormat(date: Date) -> String {
        print(#function)
        let calendar = Calendar.current
        // 일자 계산
        let today = calendar.startOfDay(for: Date())
        let someday = calendar.startOfDay(for: date)

        // 월 계산
        let thisMonth = calendar.component(.month, from: today)
        let someMonth = calendar.component(.month, from: someday)
        
        // 해당 월에 주 계산
        let weekdayOrdinalToday = calendar.component(.weekdayOrdinal, from: today)
        let weekdayOrdinalSomeday = calendar.component(.weekdayOrdinal, from: someday)
        
        if someday == today {
            //오늘 작성한 메모
            print(dateFormatTodayOrThisWeek(date: date, dateStyle: .none, timeStyle: .short))
            return dateFormatTodayOrThisWeek(date: date, dateStyle: .none, timeStyle: .short)
        } else if someday != today && thisMonth == someMonth && weekdayOrdinalToday == weekdayOrdinalSomeday {
            // 이번 주 작성한 메모
            print(dateFormatTodayOrThisWeek(date: date, dateStyle: .medium, timeStyle: .short))
            return dateFormatTodayOrThisWeek(date: date, dateStyle: .medium, timeStyle: .short)
        } else {
            // 그외 기간 작성한 메모
            print(dateFormatAnotherDay(date: date))
            return dateFormatAnotherDay(date: date)
        }
    }
    
    // 오늘 작성 메모 형식 또는 이번 주 작성 메모 형식
    func dateFormatTodayOrThisWeek(date: Date, dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = dateStyle
        dateFormatter.timeStyle = timeStyle
        dateFormatter.locale = Locale(identifier: "Ko_KR")
        let date = date
        
        return dateFormatter.string(from: date)
    }
    // 그 외 기간 작성 메모 형식
    func dateFormatAnotherDay(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = Locale(identifier: "Ko_KR")
        let date = date
        
        return dateFormatter.string(from: date)
    }
}

// 오늘 형태: dateStyle .none, timeStyle .short
// 이번 주 형태: dateStyle .medium, timeStyle .short

// 오늘 작성 메모: date == Date()
// 이번 주 작성한 메모: date != Date(), 이번 주에 포함되면 됨
// 나머지 기간은: date != Date(), 이번 주가 아니면 됨
