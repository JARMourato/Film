//
//  Series+mock.swift
//  Film
//
//  Created by Michel Balamou on 2019-09-01.
//  Copyright © 2019 ElasticPanda. All rights reserved.
//

import Foundation


extension Series {
    
    static func getMock() -> Series {
        let desc = "An animated series on adult-swim about the infinite adventures of Rick, a genius alcoholic and careless scientist, with his grandson Morty, a 14 year-old anxious boy who is not so smart, but always tries to lead his grandfather with his own morale compass. Together, they explore the infinite universes; causing mayhem and running into trouble."
        
        return Series(title: "Rick and Morty", seasonSelected: 2, totalSeasons: 4, description: desc, posterURL: MockData.randomPoster())
    }
}

extension Episode {
    
    static func getMock() -> Episode {
        return Episode(id: 1, episodeNumber: 1, seasonNumber: 2, videoURL: MockData.videoURLs[0], duration: 100)
    }
    
    static func getMockArray() -> [Episode] {
        let episodes = Array(1...5).map { i -> Episode in
            let sentence = "An animated series on adult-swim about the infinite adventures of Rick, a genius alcoholic and careless scientist."
            let plot = Array(repeating: sentence, count: Int.random(in: 0...4)).joined(separator: " ")
            
            let duration = Int.random(in: 1200 ... 5400)
            
            return Episode(id: i,
                           episodeNumber: i,
                           seasonNumber: 1,
                           videoURL: MockData.videoURLs[Int.random(in: 0..<MockData.videoURLs.count)],
                           duration: duration,
                           thumbnailURL: MockData.randomPoster(),
                           plot: plot, stoppedAt: i < 3 ? Int(Float.random(in: 0...1) * Float(duration)) : nil)
        }
        
        return episodes
    }
    
}
