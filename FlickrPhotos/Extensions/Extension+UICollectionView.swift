//
//  Extension+UICollectionView.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 17.07.2024.
//

import Foundation
import UIKit

extension UICollectionView {
    func register<Cell>(_ : Cell.Type) where Cell: UICollectionViewCell {
        let bundle = Bundle(for: Cell.self)
        let nib = UINib(nibName: Cell.nibName, bundle: bundle)
        register(nib, forCellWithReuseIdentifier: Cell.identifier)
    }
    func dequeueReusableCell<Cell>(forIndexPath indexPath: IndexPath) -> Cell where Cell: UICollectionViewCell {
        guard let cell = dequeueReusableCell(withReuseIdentifier: Cell.identifier, for: indexPath) as? Cell else {
            fatalError("Could not dequeue cell with identifier: \(Cell.identifier)")
        }
        return cell
    }
    func register<T: UICollectionReusableView>(_ : T.Type, forSupplementaryViewOfKind: String) {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        register(nib, forSupplementaryViewOfKind: forSupplementaryViewOfKind, withReuseIdentifier: T.nibName)
    }
    func dequeueReusableView<T: UICollectionReusableView>(ofKind kind: String, forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.identifier, for: indexPath) as? T else { fatalError("Could not dequeue cell with identifier: \(T.identifier)") }
        return cell
    }
}
