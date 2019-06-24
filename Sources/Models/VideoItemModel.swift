//
//  VideoItemModel.swift
//  VideoListModule
//
//  Created by Anton Boyarkin on 24/06/2019.
//

import Foundation
import IBACoreUI

struct VideoItemModel: Decodable, CellModelType {
    var id: Int64
    var title: String
    var description: String
    var cover: String
    var url: String
    var creationTime: String?
    var duration: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "#id"
        case title = "#title"
        case description = "#description"
        case cover = "#cover"
        case url = "#url"
        case creationTime = "#creation_time"
        case duration = "#duration"
    }
}

extension VideoItemModel {
    var date: Date? {
        if let creationTime = creationTime, let timeStamp = Double(creationTime) {
            return Date(timeIntervalSince1970: timeStamp)
        }
        return nil
    }
    
    var coverImageUrl: URL? {
        guard !cover.isEmpty else { return nil }
        
        if isYoutube, let youtubeVID = youtubeId {
            return URL(string: "https://img.youtube.com/vi/\(youtubeVID)/hqdefault.jpg")
        }
        
        return URL(string: cover)
    }
    
    var isYoutube: Bool {
        return url.contains("youtu")
    }
    
    var isVimeo: Bool {
        return url.contains("vimeo")
    }
    
    var youtubeId: String? {
        return extractYoutubeVideoId(from: url)
    }
    
    func extractYoutubeVideoId(from url: String) -> String? {
        let pattern = "^(?:http(?:s)?://)?(?:www\\.)?(?:m\\.)?(?:youtu\\.be/|youtube\\.com/(?:(?:watch)?\\?(?:.*&)?v(?:i)?=|(?:embed|v|vi|user)/))([a-z_A-Z0-9\\-]{11})(?:.*)"
        let regExp = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        
        let match = regExp.firstMatch(in: url, options: [], range: NSRange(location: 0, length: url.count))
        
        if let match = match, match.numberOfRanges == 2 {
            let VIDRange = match.range(at: 1)
            if let range = Range(VIDRange, in: url) {
                return String(url[range])
            }
        }
        return nil
        
        //        let pattern = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)"
        //        let pattern = "(?:(?<=(?:v)/)|(?<=(?:vi)/)|(?<=be/)|(?<=(?:\\?|\\&)v=)|(?<=(?:\\?|\\&)vi=)|(?<=embed/))([\\w-]{11})"
        //        guard let range = url.range(of: pattern, options: .caseInsensitive) else { return nil }
        //        return String(url[range])
    }
}
