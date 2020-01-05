//
//  VideoPlayerStateMachine.swift
//  Film
//
//  Created by Michel Balamou on 2020-01-04.
//  Copyright © 2020 ElasticPanda. All rights reserved.
//

import UIKit

enum PlayState {
    case playing
    case paused
}

enum VideoPlayerState {
    case initial
    case shown(PlayState)
    case hidden(PlayState)
    case loadingShown
    case loadingHidden
    case scrolling
}

class VideoPlayerStateMachine {
    private var view: VideoPlayerView
    private var currentState: VideoPlayerState = .initial
    private var thumbImage: UIImage?
    private var transitioning = false
    
    private var timer: Timer?
    
    init(view: VideoPlayerView) {
        self.view = view
    }
    
    var canDoubleTap: Bool {
        switch currentState {
        case .initial,
             .scrolling:
            return false
        default:
            return true
        }
    }
    
    var canTapToShowHideControls: Bool {
        switch currentState {
        case .initial,
             .scrolling:
            return false
        default:
            return true
        }
    }
    
    private func canTransition(from: VideoPlayerState, to: VideoPlayerState) -> Bool {
        switch (from, to) {
        case (.initial, .shown):
            return true
        case (.shown, .shown),
             (.shown, .hidden),
             (.shown, .loadingShown),
             (.shown, .scrolling):
            return true
        case (.hidden, .shown),
             (.hidden, .loadingHidden):
            return true
        case (.loadingShown, .loadingShown),
             (.loadingShown, .shown),
             (.loadingShown, .loadingHidden),
             (.loadingShown, .scrolling):
            return true
        case (.scrolling, .loadingShown):
            return true
        default:
            return false
        }
    }
    
    func transitionTo(state newState: VideoPlayerState) {
        guard canTransition(from: currentState, to: newState) else {
            assertionFailure("Attempting to transition from '\(currentState)' to '\(newState)'")
            return
        }
        
        let from = currentState
        let to = newState
        currentState = newState
        timer?.invalidate()
        
        switch (from, to) {
        case (.shown, .hidden):
            transitioning = true
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveLinear, animations: {
                self.view.controlView.alpha = 0.0
            }, completion: { _ in
                self.transitioning = false
            })
        case (.hidden, .shown(let playing)):
            setupPlaying(playing)
            transitioning = true
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveLinear, animations: {
                self.view.controlView.alpha = 1.0
            }, completion: {_ in
                self.transitioning = false
            })
            
            setupTimer { [weak self] in self?.transitionTo(state: .hidden(.playing)) }
        case (.shown, .shown(let playing)): // update playOrPause icon
            setupPlaying(playing)
        case (.loadingShown, .loadingHidden):
            transitioning = true
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveLinear, animations: {
                self.view.controlView.alpha = 0.0
            }, completion: { _ in
                self.transitioning = false
            })
        case (.loadingHidden, .loadingShown):
            transitioning = true
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveLinear, animations: {
                self.view.controlView.alpha = 1.0
            }, completion: {_ in
                self.transitioning = false
            })
            
            setupTimer { [weak self] in self?.transitionTo(state: .loadingHidden) }
        case (.initial, .shown(let playing)):
            setupPlaying(playing)
            setupTimer { [weak self] in self?.transitionTo(state: .hidden(.playing)) }
            fallthrough
        default:
            updateUI()
        }
    }
    
    func setupTimer(callback: @escaping () -> Void) {
        timer = Timer.scheduledTimer(withTimeInterval: 7.0, repeats: false) { timer in
            callback()
            timer.invalidate()
        }
    }
    
    func setupPlaying(_ playing: PlayState) {
        switch playing {
        case .paused:
            view.pausePlayButton.setImage(Images.Player.playImage, for: .normal)
        case .playing:
            view.pausePlayButton.setImage(Images.Player.pauseImage, for: .normal)
        }
    }
    
    func updateUI() {
        thumbImage = thumbImage ?? view.slider.thumbImage(for: .normal)
        view.slider.setThumbImage(thumbImage, for: .normal)
        
        switch currentState {
        case .initial:
            view.controlView.show()
            
            view.backward10sLabel.hide()
            view.backward10sButton.hide()
            view.forward10sLabel.hide()
            view.forward10sButton.hide()
            view.pausePlayButton.hide()
            view.airPlayButton.hide()
            view.spinner.startAnimating()
            
            view.slider.setThumbImage(UIImage(), for: .normal)
        case .shown(let playing):
            setupPlaying(playing)
            view.controlView.show()
            
            view.backward10sLabel.show()
            view.backward10sButton.show()
            view.forward10sLabel.show()
            view.forward10sButton.show()
            view.pausePlayButton.show()
            view.airPlayButton.show()
            view.spinner.stopAnimating()
        case .hidden:
            view.controlView.hide()
            view.airPlayButton.show()
            view.spinner.startAnimating()
        case .loadingShown:
            view.controlView.show()
            view.pausePlayButton.hide()

            view.backward10sLabel.show()
            view.backward10sButton.show()
            view.forward10sLabel.show()
            view.forward10sButton.show()
            view.airPlayButton.show()
            view.spinner.startAnimating()
        case .loadingHidden:
            view.controlView.hide()
            view.spinner.startAnimating()
        default:
            return
        }
    }
    
    func startedBuffering() {
        switch currentState {
        case .shown:
            transitionTo(state: .loadingShown)
        case .hidden:
            transitionTo(state: .loadingHidden)
        default:
            return
        }
    }
    
    func doneBuffering() {
        switch currentState {
        case .initial:
            transitionTo(state: .shown(.playing))
        case .loadingShown:
            transitionTo(state: .shown(.playing))
        case .loadingHidden:
            transitionTo(state: .hidden(.playing))
        default:
            return
        }
    }
}

extension UIView {
    
    func hide() {
        isHidden = true
    }
    
    func show() {
        isHidden = false
    }
}
