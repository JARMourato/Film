//
//  WatchingViewController.swift
//  Film
//
//  Created by Michel Balamou on 2019-08-26.
//  Copyright © 2019 ElasticPanda. All rights reserved.
//

import UIKit


protocol WatchingViewControllerDelegate {
    func playTapped()
    func moreInfoTapped()
}

enum WatchingViewControllerMode: Equatable {
    static func == (lhs: WatchingViewControllerMode, rhs: WatchingViewControllerMode) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading):
            return true
        case (.hasData(_), .hasData(_)):
            return true
        default:
            return false
        }
    }
    
    case idle
    case loading
    case hasData([Watched])
}

class WatchingViewController: UIViewController {
    
    var mode: WatchingViewControllerMode = .loading {
        didSet {
            switchedMode(newMode: mode)
        }
    }
    var data: [Watched] = []
    
    var watchingView: WatchingView!
    var delegate: WatchingViewControllerDelegate?
    
    // API
    var apiManager: WatchedAPI?
    
    // Alert
    var alert: AlertViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        watchingView = WatchingView()
        view = watchingView
        watchingView.delegate = self
        alert = AlertViewController(parent: self)
        
        setupCollectionView()
        initialLoadWatching()
    }
    
    func switchedMode(newMode: WatchingViewControllerMode) {
        switch mode {
        case .idle:
            watchingView.loadingView.isHidden = true
            watchingView.collectionView.isHidden = false
            
            watchingView.collectionView.reloadSections(IndexSet(integersIn: 0...1)) // refresh the section with the idle image
        case .loading:
            watchingView.loadingView.isHidden = false
            watchingView.collectionView.isHidden = true
            
        case .hasData(let freshData):
            watchingView.loadingView.isHidden = true
            watchingView.collectionView.isHidden = false
            
            if freshData.isEmpty {
                mode = .idle
                //self.data = []
                
                watchingView.collectionView.reloadSections(IndexSet(integersIn: 0...1)) // refresh the section with the idle image
                
                return
            }
            
            self.data = freshData
            watchingView.collectionView.reloadData()
        }
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
    
    func setupCollectionView() {
        collectionView = watchingView.collectionView
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(WatchingCell.self, forCellWithReuseIdentifier: WatchingCell.identifier)
        collectionView.register(IdleCell.self, forCellWithReuseIdentifier: IdleCell.identifier)
        collectionView.alwaysBounceVertical = true
    }
    
}


//----------------------------------------------------------------------
// MARK: API calls
//----------------------------------------------------------------------
extension WatchingViewController {
    
    func initialLoadWatching() {
        apiManager?.getWatched {
            [weak self] watched, error in
            if let error = error {
                // TODO: Show new cell type section with error
                self?.alert?.mode = .showMessage(error)
                self?.mode = .hasData([])
            } else {
                self?.mode = .hasData(watched)
                // TODO: if data is empty, show idle cell
            }
        }
    }
    
    func refreshOnPull(completion: @escaping () -> ()) {
        apiManager?.getWatched { [weak self] watched, error in
            if let error = error {
                self?.alert?.mode = .showMessage(error) // show alert
            } else {
               self?.mode = .hasData(watched)
            }
            
            completion()
        }
    }
}

//----------------------------------------------------------------------
// Refresh on pull
//----------------------------------------------------------------------
extension WatchingViewController: WatchingViewDelegate {
    
    func refreshCollectionView(completion: @escaping () -> ()) {
        refreshOnPull(completion: completion)
    }
    
}

//----------------------------------------------------------------------
// MARK: Watching Cell Actions
//----------------------------------------------------------------------
extension WatchingViewController: WatchingCellDelegate {
    
    func playButtonTapped() {
        delegate?.playTapped()
    }
    
    func informationButtonTapped() {
        delegate?.moreInfoTapped()
    }
}


//----------------------------------------------------------------------
// MARK: Data Source
//----------------------------------------------------------------------
extension WatchingViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2 // one section for watched & the other for idle
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 && !(mode == .idle) {
            return data.count
        } else if section == 1 && mode == .idle {
            return 1
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WatchingCell.identifier, for: indexPath) as! WatchingCell
            
            let data = self.data[indexPath.item]
            cell.delegate = self
            cell.viewedLabel.text = data.label
            cell.progress = data.stoppedAt
            cell.posterURL = data.posterURL
            
            return cell
         } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IdleCell.identifier, for: indexPath) as! IdleCell
            
            return cell
        }
    }
}


//----------------------------------------------------------------------
// MARK: Flow Layout
//----------------------------------------------------------------------
extension WatchingViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: 110, height: 197) // size of a cell
        } else if indexPath.section == 1 && mode == .idle {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height) // size of the cell
        }
        
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 && !(mode == .idle) {
            return UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0) // overall insets of the collection view
        } else if section == 1 && mode == .idle {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) // overall insets of the collection view section
        }
        
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0 // distance between columns
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0 // distance between rows
    }
}
