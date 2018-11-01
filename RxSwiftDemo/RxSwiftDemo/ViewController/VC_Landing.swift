//
//  ViewController.swift
//  RxSwift Demo
//
//  Created by Wing Chan on 28/10/2018.
//  Copyright © 2018 Wing. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AVFoundation

class VC_Landing: UITableViewController {
    
    
    /*
     
     Function brief:
     1. Search itunes music via API when user typing keyword inside searchbar
     2. Play preview soundtrack when user selected music inside the listview, stop preview when user pressed again
     
    */
    
    
    
    
    var ctl_search: UISearchController! // search controller for receive searchbar update
    let previewPlayer = AVQueuePlayer() // player for play music preview
    
    // Def: store playing preview's url
    // Usage: stop the playing music preview when pressed again
    var sz_playingUrl = ""
    // Def: store the searching keyword input
    // Usage: to keep remain the searching keyword on the searchbar view
    var sz_searchingKeyword = ""
    
    let disposeBag = DisposeBag() // RxSwift for memory management
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init search controller
        initSearchBar()
        
        // setup search music list function
        setupSearchAndDisplay()
        
        // setup select and play function
        setupPressAndPlay()
    }
    
    func initSearchBar() {
        ctl_search = UISearchController(searchResultsController: nil)
        ctl_search.searchBar.placeholder = "Search"
        navigationItem.searchController = ctl_search
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        // keeps keyword when end editing
        ctl_search.searchBar.rx.textDidEndEditing
            .subscribe(onNext: { self.ctl_search.searchBar.text = self.sz_searchingKeyword })
            .disposed(by: disposeBag)
    }
    
    func previewMusicWith(url : String) {
        // play m4a format preview content from preview url
        if (sz_playingUrl == url) { // stop playing if pressed the playing music
            previewPlayer.removeAllItems()
            sz_playingUrl = ""
        } else {
            previewPlayer.removeAllItems()
            previewPlayer.insert(AVPlayerItem(url: URL(string: url)!), after: nil)
            previewPlayer.play()
            sz_playingUrl = url
        }
    }
    
    func setupSearchAndDisplay() {
        // RxSwift - create observable for update search results from searchbar input
        let observ_searchResults = ctl_search.searchBar.rx.text.orEmpty
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest { (sz_keyword) -> Observable<[M_Music]> in
                self.sz_searchingKeyword = sz_keyword
                guard !sz_keyword.isEmpty else { return .just([]) }
                return MC_ITunesMusic.shared.searchMusicWith(keyword: sz_keyword)
            }.observeOn(MainScheduler.instance)
        
        // RxSwift - result bind to tableview
        tableView.dataSource = nil
        observ_searchResults.bind(to: tableView.rx.items(cellIdentifier: "cell_music")) {
            (index, m_music: M_Music, cell) in
            cell.textLabel?.text = "\(m_music.sz_artist) - \(m_music.sz_title)" // display music with artist & music title
            }.disposed(by: disposeBag)
    }
    
    func setupPressAndPlay() {
        // RxSwift - subscribe tableview item selected event
        tableView.rx.itemSelected.subscribe(onNext: { indexPath in
            let data : M_Music = try! self.tableView.rx.model(at: indexPath)
            self.previewMusicWith(url: data.sz_previewUrl)
        }).disposed(by: disposeBag)
    }
}
