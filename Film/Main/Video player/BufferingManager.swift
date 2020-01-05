//
//  BufferingManager.swift
//  Film
//
//  Created by Michel Balamou on 2020-01-04.
//  Copyright © 2020 ElasticPanda. All rights reserved.
//

import Foundation

protocol BufferingDelegate: class {
    func startedBuffering()
    func endedBuffering()
}


class BufferingManager: VLCMediaPlayerDelegate {
    private let mediaPlayer: VLCMediaPlayer
    private var currentState: VLCMediaPlayerState
    weak var delegate: BufferingDelegate?
    
    private var timer: Timer?
    private var didStartBuffering: Bool = false
    
    init(mediaPlayer: VLCMediaPlayer) {
        self.mediaPlayer = mediaPlayer
        self.currentState = mediaPlayer.state
        self.mediaPlayer.delegate = self
    }
    
    internal func mediaPlayerStateChanged(_ aNotification: Notification!) {
        let newState = mediaPlayer.state
        printState(newState)
        timer?.invalidate()
        
        switch (currentState, newState) {
        case (.buffering, .buffering):
            break
        case (_, .buffering):
            startedBuffering()
        case (_, .playing):
            doneBuffering()
        default:
            break
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] timer in
            self?.doneBuffering()
            timer.invalidate()
        }
        
        
        currentState = newState
    }
    
    private func startedBuffering() {
        delegate?.startedBuffering()
        didStartBuffering = true
    }
    
    private func doneBuffering() {
        guard didStartBuffering else { return }
        
        delegate?.endedBuffering()
        didStartBuffering = false
    }
    
    private func printState(_ state: VLCMediaPlayerState) {
        switch state {
        case .buffering:
            print("~BUFFERING")
        case .ended:
            print("~ENDED")
        case .error:
            print("~ERROR")
        case .opening:
            print("~OPENING")
        case .paused:
            print("~PAUSED")
        case .playing:
            print("~PLAYING")
        case .stopped:
            print("~STOPPED")
        case .esAdded:
            print("~ES ADDED")
        @unknown default:
            print("~ UNKNOWN \(state)")
        }
    }
    
}
