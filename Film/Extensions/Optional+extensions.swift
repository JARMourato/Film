//
//  Optional+extensions.swift
//  Film
//
//  Created by Michel Balamou on 2019-09-21.
//  Copyright © 2019 ElasticPanda. All rights reserved.
//

import Foundation

extension Optional where Wrapped: Collection {
    
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
    
}
