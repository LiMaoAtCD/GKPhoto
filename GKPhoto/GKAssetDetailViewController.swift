//
//  GKAssetDetailViewController.swift
//  GKPhoto
//
//  Created by AlienLi on 2018/10/28.
//  Copyright © 2018 MarcoLi. All rights reserved.
//

import UIKit
import Photos

class GKAssetDetailViewController: UIViewController, UIScrollViewDelegate {

    var asset: PHAsset?
    fileprivate let imageManager = PHCachingImageManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        let scrollView = UIScrollView.init(frame: CGRect.zero)
        scrollView.delegate = self
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.bottom.equalTo(bottomLayoutGuide.snp.top)
        }
        
        let content = UIView()
        scrollView.addSubview(content)
        content.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.height.equalToSuperview()
        }
        
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFit
        content.addSubview(imageview)
        imageview.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        let options = PHImageRequestOptions.init()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        options.isNetworkAccessAllowed = true
        options.progressHandler = { (progress, error, stop, info) in
            print(progress)
        }
        imageManager.requestImage(for: asset!, targetSize: CGSize.init(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), contentMode: PHImageContentMode.aspectFit, options: options) { (image, _) in
            imageview.image = image
        }
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
    }

}
