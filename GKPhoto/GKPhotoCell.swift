//
//  GKPhotoCell.swift
//  GKPhoto
//
//  Created by mao li on 2018/10/29.
//  Copyright © 2018 MarcoLi. All rights reserved.
//

import UIKit

class GKPhotoCell: UICollectionViewCell {
    static let identifier = "GKPhotoCell"

    var representedAssetIdentifier: String = ""

    let imageView = UIImageView()
    let grayMask = UIView()
    let selectButton = UIButton()

    var assetSelected: Bool = false {
        didSet {
            selectButton.backgroundColor = assetSelected ?  UIColor.blue : UIColor.init(white: 0.0, alpha: 0.3)
            grayMask.isHidden = !assetSelected

            UIView.animate(withDuration: TimeInterval.init(0.25), delay: TimeInterval.init(0.1), usingSpringWithDamping: CGFloat(0.1), initialSpringVelocity: CGFloat(0.5), options: UIView.AnimationOptions.curveEaseInOut, animations: { [weak self] in
                self?.selectButton.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
            }) { [weak self] (_) in
//                self?.selectButton.transform = CGAffineTransform.identity
            }
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
        self.assetSelected = !assetSelected
        selectionHandler?(assetSelected)
    }

    var selectionHandler: ((Bool) -> Void)?

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

