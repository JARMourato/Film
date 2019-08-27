//
//  WatchingViewController.swift
//  Film
//
//  Created by Michel Balamou on 2019-08-26.
//  Copyright © 2019 ElasticPanda. All rights reserved.
//

import UIKit


protocol WatchingViewControllerDelegate {
    func tappedPreviouslyWatchedShow()
}

class WatchingViewController: UIViewController {
    
    var watchingView: WatchingView!
    var delegate: WatchingViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        watchingView = WatchingView()
        view = watchingView
        
        setupCollectionView()
        
        // TMP CODE
        tmpCODE()
    }
    
    // TMP CODE+++
    func tmpCODE() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tmpCODETap))
        watchingView.navBar.logoImage.isUserInteractionEnabled = true
        watchingView.navBar.logoImage.addGestureRecognizer(tapGesture)
    }
    
    @objc func tmpCODETap() {
         delegate?.tappedPreviouslyWatchedShow()
    }
    // TMP CODE---
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    
    //----------------------------------------------------------------------
    // Status bar
    //----------------------------------------------------------------------
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //----------------------------------------------------------------------
    // Collection View
    //----------------------------------------------------------------------
    weak var collectionView: UICollectionView!
    
    var data: [String] = ["S1:E1", "S2:E1", "2h 30 min", "1h 25 min"]
    
    func setupCollectionView() {
        collectionView = watchingView.collectionView
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(WatchingCell.self, forCellWithReuseIdentifier: WatchingCell.identifier)
        collectionView.alwaysBounceVertical = true
    }
}


extension WatchingViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WatchingCell.identifier, for: indexPath) as! WatchingCell
        let data = self.data[indexPath.item]
        cell.viewedLabel.text = data
        return cell
    }
}

extension WatchingViewController: UICollectionViewDelegate {
    
    // Item selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension WatchingViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 110, height: 197) // size of a cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0) // overall insets of the collection view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0 // distance between columns
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0 // distance between rows
    }
}
