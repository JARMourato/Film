//
//  VideoPlayerController.swift
//  Film
//
//  Created by Michel Balamou on 2019-08-22.
//  Copyright © 2019 ElasticPanda. All rights reserved.
//

import UIKit


class VideoPlayerController: UIViewController, VLCMediaPlayerDelegate {

    var isPlaying: Bool = true
    var videoPlayerView: VideoPlayerView!
    var mediaPlayer = VLCMediaPlayer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        forceLandscapeOrientation()
        
        videoPlayerView = VideoPlayerView(frame: self.view.frame)
        self.view = videoPlayerView
        
        setUpPlayer(url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")
        setActions()
    }
    
    func setActions() {
        videoPlayerView.pausePlayButton.addTarget(self, action: #selector(pausePlayButtonPressed(sender:)), for: .touchUpInside)
        
        let tapToShowControlls = UITapGestureRecognizer(target: self, action: #selector(showControlls))
        videoPlayerView.mediaView.addGestureRecognizer(tapToShowControlls)
        
        let tapToHideControlls = UITapGestureRecognizer(target: self, action: #selector(hideControlls))
        videoPlayerView.controlView.addGestureRecognizer(tapToHideControlls)
        
        mediaPlayer.addObserver(self, forKeyPath: "time", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
        videoPlayerView.slider.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        videoPlayerView.slider.addTarget(self, action: #selector(touchUpInside(_:)), for: .touchUpInside)
        videoPlayerView.slider.addTarget(self, action: #selector(touchUpOutside(_:)), for: .touchUpOutside)
    }
    
    func setUpPlayer(url: String) {
        let streamURL = URL(string: url)!
        let vlcMedia = VLCMedia(url: streamURL)
        
        mediaPlayer.media = vlcMedia
        mediaPlayer.drawable = videoPlayerView.mediaView
        mediaPlayer.delegate = self
        
        mediaPlayer.play()
    }
    
    //----------------------------------------------------------------------
    // Orientation
    //----------------------------------------------------------------------
    func forceLandscapeOrientation() {
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    //----------------------------------------------------------------------
    // Actions
    //----------------------------------------------------------------------
    @objc func showControlls() {
        videoPlayerView.controlView.isHidden = false
    }
    
    @objc func hideControlls() {
        videoPlayerView.controlView.isHidden = true
    }
    
    @objc func pausePlayButtonPressed(sender: UIButton) {
        if isPlaying {
            mediaPlayer.pause()
            isPlaying = false
            sender.setTitle("▶", for: .normal)
        } else {
            mediaPlayer.play()
            isPlaying = true
            sender.setTitle("▌▌", for: .normal)
        }
    }
    
    @objc func rewindBack() {
        mediaPlayer.jumpBackward(Int32(10))
    }
    
    //----------------------------------------------------------------------
    // Slider
    //----------------------------------------------------------------------
    var setPosition = true
    var updatePosition = true
    
    // continuously update slider and time displayed
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if (setPosition && updatePosition)
        {
            videoPlayerView.slider.value = mediaPlayer.position // move slider
            
            var remaining =  mediaPlayer.remainingTime.description
            remaining.remove(at: remaining.startIndex)
            videoPlayerView.durationLabel.text = remaining // display time
        }
    }
    
    // When the value of the slider is set but the finger is outside the slider
    @objc func touchUpOutside(_ sender: UISlider) {
        positionSliderAction()
    }
    
    // When the value of the slider is set but the finger is inside the slider
    @objc func touchUpInside(_ sender: UISlider) {
        positionSliderAction()
    }
    
    // When the slider is touched
    @objc func touchDown(_ sender: UISlider) {
        updatePosition = false
    }
    
    func positionSliderAction()
    {
        self.perform(#selector(setPositionForReal), with: nil, afterDelay: 0.3)
        
        setPosition = false
        updatePosition = true
    }
    
    @objc func setPositionForReal()
    {
        if !setPosition {
            mediaPlayer.position = videoPlayerView.slider.value
            setPosition = true
        }
    }
}

class Film {
    // Mandatory
    var id: Int
    var URL: String
    var duration: Int
    
    // Optional
    var stoppedAt: Int?
    var poster: String?
    var title: String?
    
    init() {
        id = 0
        URL = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"
        duration = 15
    }
    
    // Methods
    func label() -> String {
        return ""
    }
    
    func durationMin() -> String {
        return "0"
    }
}

