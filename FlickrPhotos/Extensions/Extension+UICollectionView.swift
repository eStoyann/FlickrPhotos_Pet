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
        guard let cell = dequeueReusableCell(withReuseIdentifier: Cell.identifier,
                                             for: indexPath) as? Cell else {
            fatalError("Could not dequeue cell with identifier: \(Cell.identifier)")
        }
        return cell
    }
    func register<View>(_ : View.Type, forSupplementaryViewOfKind: String) where View: UICollectionReusableView {
        let bundle = Bundle(for: View.self)
        let nib = UINib(nibName: View.nibName, bundle: bundle)
        register(nib,
                 forSupplementaryViewOfKind: forSupplementaryViewOfKind,
                 withReuseIdentifier: View.nibName)
    }
    func dequeueReusableView<View>(ofKind kind: String,
                                   forIndexPath indexPath: IndexPath) -> View where View: UICollectionReusableView {
        guard let cell = dequeueReusableSupplementaryView(ofKind: kind,
                                                          withReuseIdentifier: View.identifier,
                                                          for: indexPath) as? View else {
            fatalError("Could not dequeue cell with identifier: \(View.identifier)")
        }
        return cell
    }
}
