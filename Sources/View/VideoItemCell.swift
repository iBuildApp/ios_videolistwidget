//
//  VideoItemCell.swift
//  VideoListModule
//
//  Created by Anton Boyarkin on 14/06/2019.
//

import UIKit
import IBACore
import IBACoreUI
import PinLayout
import FlexLayout
import Imaginary
import Kingfisher

class VideoItemCell: UITableViewCell, BaseCellType {
    typealias ModelType = VideoItemModel
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    private var model: ModelType?
    
    private let padding: CGFloat = 8
    private let previewImageView = UIImageView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    
    public let shareButton = UIButton(type: .custom)
    
    public var onAction: ((ModelType) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        separatorInset = .zero
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .black
        
        previewImageView.contentMode = .scaleAspectFill
        previewImageView.clipsToBounds = true
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.lineBreakMode = .byTruncatingTail
        dateLabel.numberOfLines = 0
        dateLabel.textColor = UIColor.black.withAlphaComponent(0.5)
        
        shareButton.setTitle(Localization.Common.Text.share, for: .normal)
        shareButton.setTitleColor(.gray, for: .normal)
        shareButton.titleLabel?.font = .systemFont(ofSize: 16.0)
        shareButton.setImage(getCoreUIImage(with: "share"), for: .normal)
        shareButton.titleEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: -8)
        shareButton.contentEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 8)
        shareButton.sizeToFit()
        
        // Use contentView as the root flex container
        contentView.flex.padding(10).addItem().padding(10).define { flex in
            flex.addItem(previewImageView).maxHeight(200).shrink(1)
            flex.addItem(titleLabel).marginTop(padding)
            flex.addItem().direction(.row).justifyContent(.spaceBetween).define({ flex in
                flex.addItem(dateLabel).marginTop(padding)
                flex.addItem(shareButton).marginTop(padding)
            })
        }
        
        shareButton.addTarget(self, action: #selector(share), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(model: ModelType) {
        self.model = model
        titleLabel.text = model.title
        titleLabel.flex.markDirty()
        
        if let date = model.date {
            dateLabel.text = date.humanizedString
        } else {
            dateLabel.text = ""
        }
        dateLabel.flex.markDirty()
        
        if let url = model.coverImageUrl {
            previewImageView.kf.setImage(with: url, placeholder: getCoreUIImage(with: "placeholder_image"))
            previewImageView.flex.height(200)
        } else {
            previewImageView.flex.height(0)
        }
        flex.layout()
    }
    
    func setColorScheme(_ colorScheme: ColorSchemeModel) {
        titleLabel.textColor = colorScheme.secondaryColor
        shareButton.tintColor = colorScheme.secondaryColor.withAlphaComponent(0.6)
        shareButton.setTitleColor(colorScheme.secondaryColor.withAlphaComponent(0.6), for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    fileprivate func layout() {
        contentView.flex.layout(mode: .adjustHeight)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        // 1) Set the contentView's width to the specified size parameter
        contentView.pin.width(size.width)
        
        // 2) Layout contentView flex container
        layout()
        
        // Return the flex container new size
        return contentView.frame.size
    }
    
    @objc func share() {
        if let model = model {
            onAction?(model)
        }
    }
}
