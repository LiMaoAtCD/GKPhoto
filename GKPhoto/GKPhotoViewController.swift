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
    var selectedItems =  [String]()
    
    fileprivate let imageManager = PHCachingImageManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
//        fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)

        let width = (UIScreen.main.bounds.size.width - 4) / 4
        thumbnailSize = CGSize.init(width: width, height: width)
        collectionViewFlowLayout.itemSize = thumbnailSize
        collectionViewFlowLayout.minimumLineSpacing = 1
        collectionViewFlowLayout.minimumInteritemSpacing = 1
        collectionViewFlowLayout.scrollDirection = .vertical
        collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: collectionViewFlowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.identifier)
        collectionView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.bottom.equalTo(bottomLayoutGuide.snp.top)
        }
        addSelectionNotification()
    }
    
    func addSelectionNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.selectionStatusChanged(notification:)), name: NSNotification.Name.init("GK_Select"), object: nil)
    }
    
    @objc func selectionStatusChanged(notification: Notification) {
        let obj = notification.object as! String
        selectedItems.append(obj)
        if selectedItems.count >= 9  {
            collectionView.reloadData()
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let scale = UIScreen.main.scale
        let cellSize = collectionViewFlowLayout.itemSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as! PhotoCell
        let asset = fetchResult.object(at: indexPath.item)
        cell.representedAssetIdentifier = asset.localIdentifier
        print(asset.localIdentifier)
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil) { [weak self] (image, _) in
                guard let self = self else { return }
                if cell.representedAssetIdentifier == asset.localIdentifier {
                    cell.thumbnailImage = image
                    if let index = self.selectedItems.firstIndex(of: cell.representedAssetIdentifier) {
                        cell.assetSelected = true
                        cell.assetOrder = index + 1
                    } else {
                        cell.assetSelected = false
                        cell.assetOrder = 0
                    }
                }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = GKAssetDetailViewController()
        controller.asset = fetchResult.object(at: indexPath.item)
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

class PhotoCell: UICollectionViewCell {
    
    static let identifier = "PhotoCell"
    var representedAssetIdentifier: String = ""
    let imageView = UIImageView()
    let grayMask = UIView()
    let selectButton = UIButton()
    
    var assetSelected: Bool = false {
        didSet {
            selectButton.backgroundColor = assetSelected ?  UIColor.blue : UIColor.lightGray
        }
    }
    
    var assetOrder: Int = 0 {
        didSet {
            if assetOrder > 0 {
                selectButton.setTitle("\(assetOrder)", for: UIControl.State.normal)
            } else {
                selectButton.setTitle("", for: UIControl.State.normal)
            }
        }
    }
    
    var thumbnailImage: UIImage? {
        didSet {
            imageView.image = thumbnailImage
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubViews()
        addSubview(imageView)
        addSubview(grayMask)
        addSubview(selectButton)
        
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        grayMask.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        selectButton.snp.makeConstraints { (make) in
            make.right.top.equalToSuperview()
            make.width.height.equalTo(24)
        }
    }
    
    func configureSubViews() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        grayMask.backgroundColor = UIColor.gray
        grayMask.alpha = 0.3
        grayMask.isHidden = true
        
        selectButton.backgroundColor = UIColor.blue
        selectButton.layer.borderColor = UIColor.white.cgColor
        selectButton.layer.borderWidth = 1
        selectButton.layer.cornerRadius = 12
        selectButton.layer.masksToBounds = true
        selectButton.addTarget(self, action: #selector(self.selectThisPhoto), for: UIControl.Event.touchUpInside)
    }
    
    @objc func selectThisPhoto() {
        if self.assetSelected {
            self.assetSelected = !assetSelected
        }
        NotificationCenter.default.post(name: NSNotification.Name.init("GK_Select"), object: representedAssetIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

