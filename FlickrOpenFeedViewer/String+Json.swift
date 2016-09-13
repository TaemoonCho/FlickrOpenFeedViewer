import Swift
import Foundation
import SwiftyJSON

extension String {
    var json: JSON? {
        if let data = self.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            return JSON(data: data)
        }
        return nil
    }
}
