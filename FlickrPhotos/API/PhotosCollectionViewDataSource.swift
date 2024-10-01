//
//  PhotosCollectionViewDataSource.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 17.07.2024.
//

import Foundation
import UIKit

protocol PhotosCollectionViewDataProviderProtocol: UICollectionViewDelegate,
                                                   UICollectionViewDataSource,
                                                   UICollectionViewDelegateFlowLayout,
                                                   UICollectionViewDataSourcePrefetching {
    func updateActivityIndicatorFooterViewHeight(_ height: CGFloat, in collectionView: UICollectionView)
    func insertItems(_ items: Array<IndexPath>, into collectionView: UICollectionView)
}
extension PhotosCollectionViewDataProviderProtocol {
    func insertItems(_ items: Array<IndexPath>, into collectionView: UICollectionView) {
        guard !items.isEmpty else {return}
        collectionView.performBatchUpdates{
            collectionView.insertItems(at: items)
        }
    }
}

final class PhotosCollectionViewDataSource: NSObject,
                                            PhotosCollectionViewDataProviderProtocol {
    private let source: PhotosDataSource
    private var reusableViewHeight: CGFloat = 0
    
    init?(source: PhotosDataSource?) {
        if let source {
            self.source = source
        } else {
            return nil
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        source.numberOfSectionsOfPhotos
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        source.numberOfPhotos(in: section)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PhotoCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.setup(image: .placeholder)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard let cell = cell as? PhotoCollectionViewCell else {return}
        source.startLoadingImage(at: indexPath) { image in
            cell.stopActivityIndicatorView()
            cell.setup(image: image ?? .placeholder)
        }
        if source.isLoadingImage(at: indexPath) {
            cell.startActivityIndicatorView()
        }
    }
    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard let cell = cell as? PhotoCollectionViewCell else {return}
        cell.stopActivityIndicatorView()
        source.stopLoadingImage(at: indexPath)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let interItemsSpacing: CGFloat = 1*3
        let width = (collectionView.bounds.width-interItemsSpacing)/2
        let height: CGFloat = 150
        return CGSize(width: width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        1
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter else {
            fatalError()
        }
        let footerView: ActivityIndicatorCollectionReusableView = collectionView.dequeueReusableView(ofKind: kind, forIndexPath: indexPath)
        return footerView
    }
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        guard let footerView = view as? ActivityIndicatorCollectionReusableView else {
            return
        }
        footerView.startActivityIndicator()
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        guard let footerView = view as? ActivityIndicatorCollectionReusableView else {
            return
        }
        footerView.stopActivityIndicator()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: reusableViewHeight)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let safeArea = scrollView.safeAreaInsets
        let offsetX = scrollView.contentOffset.y+safeArea.top
        let height = UIScreen.main.bounds.height
        let contentSizeHeight = scrollView.contentSize.height-height+safeArea.top+safeArea.bottom
        if offsetX >= contentSizeHeight/2, offsetX > 0 {
            source.loadNextPhotosPage()
        }
    }
    func collectionView(_ collectionView: UICollectionView,
                        prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            source.startLoadingImage(at: indexPath){ image in
                if collectionView.indexPathsForVisibleItems.contains(where: {$0 == indexPath}),
                   let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
                    cell.stopActivityIndicatorView()
                    cell.setup(image: image ?? .placeholder)
                }
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView,
                        cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(source.stopLoadingImage)
    }
}
extension PhotosCollectionViewDataSource {
    func updateActivityIndicatorFooterViewHeight(_ height: CGFloat, in collectionView: UICollectionView) {
        reusableViewHeight = height
        collectionView.collectionViewLayout.invalidateLayout()
    }
}
