//
//  GKAssetDetailViewController.swift
//  GKPhoto
//
//  Created by AlienLi on 2018/10/28.
//  Copyright © 2018 MarcoLi. All rights reserved.
//

import UIKit
import Photos

class GKAssetDetailViewController: UIViewController {

    var currentIndexPath: IndexPath?
    var fetchResult: PHFetchResult<PHAsset>!

    fileprivate let imageManager = PHCachingImageManager()

    var itemSize: CGSize!


    var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        self.navigationController?.hidesBarsOnTap = true

        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize.init(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        itemSize = CGSize.init(width: UIScreen.main.bounds.width * UIScreen.main.scale, height: UIScreen.main.bounds.height * UIScreen.main.scale)
        collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true

        collectionView.register(GKPhotoDetailCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.scrollToItem(at: currentIndexPath!, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
    }
}


extension GKAssetDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! GKPhotoDetailCell
        let asset = fetchResult.object(at: indexPath.item)
        cell.representedAssetIdentifier = asset.localIdentifier
        if cell.tag != 0 {
            imageManager.cancelImageRequest(PHImageRequestID.init(cell.tag))
        }
        let options = PHImageRequestOptions.init()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        cell.tag = Int(imageManager.requestImage(for: asset, targetSize: itemSize, contentMode: PHImageContentMode.aspectFill, options: options, resultHandler: { (image, _) in
            cell.imageview.image = image
        }))

        return cell
    }
}

class GKPhotoDetailCell: UICollectionViewCell {
    let scrollView = UIScrollView()
    let imageview = UIImageView()

    var representedAssetIdentifier: String = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        scrollView.addSubview(imageview)
        imageview.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
