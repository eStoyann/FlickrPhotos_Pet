//
//  PhotosViewController.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 16.07.2024.
//

import UIKit

class PhotosViewController: UIViewController {
    typealias ViewModel = PhotosViewModelProtocol & PhotosDataSource & PhotosSearchTermsDelegate
    
    //MARK: - Outlets
    @IBOutlet private weak var photosCollectionView: UICollectionView!
    
    //MARK: - Private properties
    private var photosSearchTermsHistoryViewController: PhotosSearchTermsHistoryViewController?
    private var photosCollectionViewDataSource: PhotosCollectionViewDataProviderProtocol?
    private var photoSearchTermsDelegate: UISearchBarDelegate?
    private var loaderView: LoaderView?
    
    //MARK: - Public properties
    var viewModel: ViewModel?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        viewModel?.getPhotos()
    }
    
    //MARK: - Private methods
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.title = viewModel?.title
        navigationItem.searchController = configureSearchController()
        navigationItem.hidesSearchBarWhenScrolling = false
        configurePhotosCollectionView()
    }
    private func configureSearchController() -> UISearchController {
        photosSearchTermsHistoryViewController = .loadFromNib()
        photosSearchTermsHistoryViewController?.viewModel = viewModel?.photosSearchTermsHistoryViewModel
        let searchController = UISearchController(searchResultsController: photosSearchTermsHistoryViewController)
        photoSearchTermsDelegate = PhotosSearchTermsBarDelegate(source: viewModel)
        searchController.searchBar.delegate = photoSearchTermsDelegate
        searchController.searchBar.placeholder = viewModel?.searchBarPlaceholder
        searchController.automaticallyShowsCancelButton = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.showsSearchResultsController = true
        return searchController
    }
    private func configurePhotosCollectionView() {
        photosCollectionView.register(PhotoCollectionViewCell.self)
        photosCollectionView.register(ActivityIndicatorCollectionReusableView.self, 
                                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter)
        photosCollectionView.contentInset = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
        photosCollectionViewDataSource = PhotosCollectionViewDataSource(source: viewModel)
        photosCollectionView.delegate = photosCollectionViewDataSource
        photosCollectionView.dataSource = photosCollectionViewDataSource
    }
    private func bind() {
        viewModel?.selectedSearchTerm.bind({[weak self] searchTerm in
            guard let self else {return}
            guard searchTerm?.isNotEmpty == true else {return}
            navigationItem.searchController?.searchBar.text = searchTerm
            navigationItem.searchController?.searchResultsController?.dismiss(animated: true)
        })
        viewModel?.nextPagePhotosState.bind({[weak self] state in
            guard let self else {return}
            switch state {
            case let .failure(error):
                print(error)
            case let .loaded(items):
                photosCollectionViewDataSource?.insertItems(items, into: photosCollectionView)
            case .loading:
                let height: CGFloat = 50
                photosCollectionViewDataSource?.updateActivityIndicatorFooterViewHeight(height, in: photosCollectionView)
            case .idle:
                let height: CGFloat = 0
                photosCollectionViewDataSource?.updateActivityIndicatorFooterViewHeight(height, in: photosCollectionView)
            }
        })
        viewModel?.recentPhotosState.bind({[weak self] state in
            guard let self else {return}
            switch state {
            case let .failure(error):
                print(error)
            case .loading:
                if loaderView == nil {
                    loaderView = LoaderView(frame: UIScreen.main.bounds)
                    view._window?.addSubview(loaderView!)
                }
                loaderView!.startAnimation()
            case .loaded:
                photosCollectionView.reloadData()
            case .idle:
                loaderView?.stopAnimation {
                    self.loaderView = nil
                }
            }
        })
    }
}
