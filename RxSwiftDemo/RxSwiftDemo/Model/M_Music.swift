//
//  M_Music.swift
//  RxSwift Demo
//
//  Created by Wing Chan on 28/10/2018.
//  Copyright © 2018 Wing. All rights reserved.
//

import Foundation

struct M_Music : Decodable {
    let sz_artist : String
    let sz_title : String
    let sz_trackId : String
    let sz_previewUrl : String
    
    private enum CodingKeys: String, CodingKey {
        case sz_artist = "artistName"
        case sz_title = "trackName"
        case sz_trackId = "trackId"
        case sz_previewUrl = "previewUrl"
    }
}
