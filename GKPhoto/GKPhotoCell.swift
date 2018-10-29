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

    var canSelect: Bool = true {
        didSet {
            grayMask.isHidden = canSelect
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
            make.right.top.equalToSuperview().inset(3)
            make.width.height.equalTo(24)
        }
    }

    func configureSubViews() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        grayMask.backgroundColor = UIColor.gray
        grayMask.alpha = 0.7
        grayMask.isHidden = true

        selectButton.backgroundColor = UIColor.blue
        selectButton.layer.borderColor = UIColor.white.cgColor
        selectButton.layer.borderWidth = 1
        selectButton.layer.cornerRadius = 12
        selectButton.layer.masksToBounds = true
        selectButton.addTarget(self, action: #selector(self.selectThisPhoto), for: UIControl.Event.touchUpInside)
    }

    @objc func selectThisPhoto() {
        if !canSelect { return }
        self.assetSelected = !assetSelected
        selectionHandler?(assetSelected)
    }

    var selectionHandler: ((Bool) -> Void)?

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

