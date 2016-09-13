import SwiftyJSON
import SwiftDate
import RxSwift
import Alamofire
import RxAlamofire

enum FeedImageLoadState: Int {
    case Impossibility = 0, Prepared, Loading, Failed, Done, Deleted
}

extension FeedImageLoadState: Equatable {}
//extension String: JsonSerializable {}


func == (lhs: FeedImageLoadState, rhs: FeedImageLoadState) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

class FeedImage {
    var url: String? = nil
    var image: UIImage? = nil
    var loadState = FeedImageLoadState.Impossibility
    
    init() {}
    
    convenience init(url: String) {
        self.init()
        self.url = url
        self.loadState = FeedImageLoadState.Prepared
    }
}

struct Feed {
    let title: String
    let link: String
    let feedDescription: String
    let author: String
    let authorId: String
    let tags: String
    let takenAt: NSDate
    let publishedAt: NSDate
    private(set) var feedImage: FeedImage
}

extension Feed: JsonDecodable {
    static func fromJSON(rawjson: AnyObject) -> Feed {
        let json = JSON(rawjson)
        let title = json["title"].stringValue
        let link = json["link"].stringValue
        let feedDescription = json["description"].stringValue
        let author = json["author"].stringValue
        let authorId = json["authorId"].stringValue
        let tags = json["tags"].stringValue
        let takenAt = json["date_taken"].stringValue.toDate(DateFormat.ISO8601Format(.Full))!
        let publishedAt = json["published"].stringValue.toDate(DateFormat.ISO8601Format(.Full))!
        var feedImage: FeedImage
        if let media = json["media"]["m"].string {
            feedImage = FeedImage(url: media)
        } else {
            feedImage = FeedImage()
        }
        
        return Feed(title: title,
                    link: link,
                    feedDescription: feedDescription,
                    author: author,
                    authorId: authorId,
                    tags: tags,
                    takenAt: takenAt,
                    publishedAt: publishedAt,
                    feedImage: feedImage)
    }
    
    func downloadImage() -> Observable<UIImage> {
        return Observable.create({ observer -> Disposable in
            var request: Request?
            if let url = self.feedImage.url {
                request = Alamofire.request(.GET, url).validate().responseData { response in
                    if let imageData = response.result.value {
                        if let image = UIImage(data: imageData) {
                            observer.onNext(image)
                        } else {
                           observer.onError(NSError(domain: "Image not found", code: 1, userInfo: nil))
                        }
                    } else {
                        observer.onError(NSError(domain: "Response not found", code: 1, userInfo: nil))
                    }
                    observer.onCompleted()
                }
            } else {
                observer.onError(NSError(domain: "Has not url", code: 1, userInfo: nil))
            }
            return AnonymousDisposable {
                if let request = request {
                    request.cancel()
                }
            }
        }).observeOn(SerialDispatchQueueScheduler(internalSerialQueueName: "feedImageDownloader"))
    }
    
    mutating func removeImage() {
        if self.feedImage.image != nil {
            self.feedImage.image = nil
            self.feedImage.loadState = .Deleted
        }
    }
    
    static func fromRawResponse(rawResponse: String) -> Array<Feed>? {
        let targetString = "jsonFlickrFeed("
        var json: JSON? = nil
        if rawResponse.rangeOfString(targetString) != nil {
            let processedJsonString = String(
                rawResponse.stringByReplacingOccurrencesOfString(
                    targetString,
                    withString: "",
                    options: NSStringCompareOptions.LiteralSearch,
                    range: nil)
                    .stringByReplacingOccurrencesOfString("\\'", withString: "'")
                    .characters
                    .dropLast())
            json = processedJsonString.json
        } else {
            json = rawResponse.json
        }
        if let itemArray = json?["items"].arrayObject {
            return self.fromJSONArray(itemArray)
        }
        return nil
    }
}
