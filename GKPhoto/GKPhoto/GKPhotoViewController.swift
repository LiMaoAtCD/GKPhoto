//
//  GKPhotoViewController.swift
//  GKPhoto
//
//  Created by AlienLi on 2018/10/28.
//  Copyright © 2018 MarcoLi. All rights reserved.
//

import UIKit
import SnapKit
import Photos

class GKPhotoViewController: UIViewController {
    var collectionView: UICollectionView!
    let collectionViewFlowLayout = PhotoLayout()

    var thumbnailSize = CGSize.zero
    var fetchResult: PHFetchResult<PHAsset>!

    fileprivate let imageManager = PHCachingImageManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchImageAssets()
        setupViews()
    }

    func fetchImageAssets() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
    }

    func setupViews() {
        let width = (UIScreen.main.bounds.size.width - 4) / 4
        let size = CGSize.init(width: width, height: width)
        collectionViewFlowLayout.itemSize = size
        collectionViewFlowLayout.minimumLineSpacing = 1
        collectionViewFlowLayout.minimumInteritemSpacing = 1
        collectionViewFlowLayout.scrollDirection = .vertical
        collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: collectionViewFlowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        view.addSubview(collectionView)
        collectionView.register(GKPhotoCell.self, forCellWithReuseIdentifier: GKPhotoCell.identifier)
        collectionView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.bottom.equalTo(bottomLayoutGuide.snp.top)
        }
        thumbnailSize = CGSize.init(width: width * UIScreen.main.bounds.width, height: width * UIScreen.main.bounds.width)
    }

}

extension GKPhotoViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GKPhotoCell.identifier, for: indexPath) as! GKPhotoCell
        let asset = fetchResult.object(at: indexPath.item)
        cell.representedAssetIdentifier = asset.localIdentifier
        if cell.tag != 0 {
            imageManager.cancelImageRequest(PHImageRequestID.init(cell.tag))
        }
        cell.tag = Int(imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil) { (image, _) in
                cell.thumbnailImage = image
                if let index = GKHelper.default.identifiers.firstIndex(of: cell.representedAssetIdentifier) {
                    cell.assetSelected = true
                    cell.assetOrder = index + 1
                    cell.canSelect = true
                } else {
                    cell.assetSelected = false
                    cell.assetOrder = 0
                    cell.canSelect = !GKHelper.default.isMaxNumber()
                }
        })

        cell.selectionHandler = {
            [weak self] selected in
            if selected {
                GKHelper.default.insert(asset.localIdentifier, indexPath: indexPath)
                if GKHelper.default.isMaxNumber() {
                    collectionView.reloadData()
                }
                self?.updateCells()
            } else {
                if GKHelper.default.isMaxNumber() {
                    // 达到最大选择数后, 取消
                    collectionView.reloadData()
                }

                GKHelper.default.delete(asset.localIdentifier)
                cell.assetSelected = selected
                cell.assetOrder = 0
                self?.updateCells()
            }
        }
        return cell
    }

    func updateCells() {
        for (index, indexPath) in GKHelper.default.indexPaths.enumerated() {
            if let cell = collectionView.cellForItem(at: indexPath) as? GKPhotoCell {
                cell.assetOrder = index + 1
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = GKAssetDetailViewController()
        controller.fetchResult = fetchResult
        controller.currentIndexPath = indexPath
        navigationController?.pushViewController(controller, animated: true)

    }
}

class PhotoLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

