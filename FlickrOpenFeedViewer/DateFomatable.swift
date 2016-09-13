import Foundation
import SwiftDate

protocol DateFomatable {
    var stringInSeoul: String? { get }
}

extension DateFomatable where Self: NSDate {
    var stringInSeoul: String? {
        get {
            let timezone = DateRegion(timeZoneName: TimeZoneName(rawValue: "Asia/Seoul"))
            return self.toString(DateFormat.Custom("YYYY-MM-dd HH:mm:ss"), inRegion: timezone)
        }
    }
}