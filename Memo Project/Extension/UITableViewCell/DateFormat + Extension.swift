import UIKit

/*
형태
- 오늘: dateStyle .none, timeStyle .short
- 이번 주: "EEEE"
- 나머지: dateStyle .medium, timeStyle .short

 조건
- 오늘: date == Date()
- 이번 주: date != Date(), 같은 월 같은 주
- 나머지: date != Date(), 같은 월 같은 주가 아니면
*/


extension UITableViewCell {
    
    func calculateDateFormat(date: Date) -> String {

        let calendar = Calendar.current
        // 일자 계산
        let today = calendar.startOfDay(for: Date())
        let someday = calendar.startOfDay(for: date)

        // 월 계산
        let thisMonth = calendar.component(.month, from: today)
        let someMonth = calendar.component(.month, from: someday)
        
        // 해당 월의 주 번호 계산
        let todayWeekOfYear = calendar.component(.weekOfYear, from: today)
        let SomedayWeekOfYear = calendar.component(.weekOfYear, from: someday)
        
        if someday == today {
            //오늘 작성한 메모
            return dateFormatTodayOrTheOthers(date: date, dateStyle: .none, timeStyle: .short)
            
        } else if someday != today && thisMonth == someMonth && todayWeekOfYear == SomedayWeekOfYear {
            // 이번 주 작성한 메모
            return dateFormatThisWeek(date: date)
            
        } else {
            // 그외 기간 작성한 메모
            return dateFormatTodayOrTheOthers(date: date, dateStyle: .medium, timeStyle: .short)
        }
    }
    
    // 오늘 작성 메모 형식 또는 그 외 기간에 작성한 메모 형식
    func dateFormatTodayOrTheOthers(date: Date, dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = dateStyle
        dateFormatter.timeStyle = timeStyle
        dateFormatter.locale = Locale(identifier: "ko_KR")
        let date = date
        
        return dateFormatter.string(from: date)
    }
    // 이번 주 작성 메모 형식
    func dateFormatThisWeek(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        let date = date
        
        return dateFormatter.string(from: date)
    }
}
