//
//  SearchHelper.swift
//  RxSwift Demo
//
//  Created by Wing Chan on 28/10/2018.
//  Copyright © 2018 Wing. All rights reserved.
//

import Foundation
import RxSwift
import RxAlamofire

class MC_ITunesMusic {
    static var shared = MC_ITunesMusic()
    
    final let API_ITUNES_SEARCH = "https://itunes.apple.com/search"
    
    
    // API call - search itunes music with keyword, limited to 25 items
    func searchMusicWith(keyword:String) -> Observable<[M_Music]>{
        // prepare params
        let param = ["term": keyword, "limit" : "25"]
        
        // response root structure
        struct Root : Decodable {
            let results : [M_Music]
        }
        
        // submit request
        return requestData(.get, API_ITUNES_SEARCH, parameters: param).map({ data -> [M_Music] in
            do {
                let result = try JSONDecoder().decode(Root.self, from: data.1)
                return result.results
            } catch { return [] }
        })
    }
}


