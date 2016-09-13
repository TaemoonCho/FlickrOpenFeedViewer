import Foundation

protocol JsonDecodable {
    static func fromJSON(json: AnyObject) -> Self
}

extension JsonDecodable {
    static func fromJSONArray(json: [AnyObject]) -> [Self] {
        return json.map { Self.fromJSON($0) }
    }
}
