//
//  MockWatchedAPI.swift
//  Film
//
//  Created by Michel Balamou on 2019-08-30.
//  Copyright © 2019 ElasticPanda. All rights reserved.
//

import Foundation

protocol WatchedAPI {
    func getWatched(result: @escaping ([Watched], _ error: String?) -> ())
}

class MockWatchedAPI: WatchedAPI {
    
    var count = 0
    
    func getWatched(result: @escaping ([Watched], _ error: String?) -> ()) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: { [weak self] in
            let error: String? = (self?.count == 2) ? "Bad internet connection" : nil
            let data = (self?.count == 0) ? [] : Watched.getRandomMock()
            
            result(data, error)
            
            self?.count += 1
        })
        
    }
    
}
