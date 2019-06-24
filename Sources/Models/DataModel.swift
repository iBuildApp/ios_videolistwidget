//
//  DataModel.swift
//  VideoListModule
//
//  Created by Anton Boyarkin on 13/06/2019.
//

import Foundation
import IBACore

struct DataModel: Decodable {
    var colorScheme: ColorSchemeModel?
    
    var moduleId: String?
    
    var allowsharing: String
    var allowcomments: String
    var allowlikes: String
    
    var videos: [VideoItemModel]?
    
    enum CodingKeys: String, CodingKey {
        case colorScheme = "colorskin"
        case moduleId = "module_id"
        case allowsharing = "allowsharing"
        case allowcomments = "allowcomments"
        case allowlikes = "allowlikes"
        case videos = "video"
    }
}

extension DataModel {
    var canShare: Bool { return allowsharing == "on" }
    var canLike: Bool { return allowlikes == "on" }
    var canComment: Bool { return allowcomments == "on" }
}
