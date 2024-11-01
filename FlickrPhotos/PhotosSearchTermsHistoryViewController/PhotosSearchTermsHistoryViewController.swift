//
//  PhotosSearchTermsHistoryViewController.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 18.07.2024.
//

import UIKit

class PhotosSearchTermsHistoryViewController: UIViewController {
    typealias ViewModel = PhotosSearchTermsHistory & PhotosSearchTermsHistoryDataSource
    typealias TableViewDataSource = UITableViewDelegate & UITableViewDataSource
    
    //MARK: - Outlets
    @IBOutlet private weak var searchTermsHistoryTableView: UITableView!
    
    //MARK: - Private properties
    private var tableViewDataSource: TableViewDataSource?
    
    //MARK: - Public properties
    var viewModel: ViewModel?

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchTermsHistoryTableView.reloadData()
    }
    
    //MARK: - Private methods
    private func setupUI() {
        tableViewDataSource = SearchTermsHistoryTableViewDataSource(source: viewModel)
        searchTermsHistoryTableView.delegate = tableViewDataSource
        searchTermsHistoryTableView.dataSource = tableViewDataSource
        searchTermsHistoryTableView.register(SearchTermTableViewCell.self)
        searchTermsHistoryTableView.tableFooterView = UIView()
    }
}
