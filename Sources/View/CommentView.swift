//
//  CommentView.swift
//  VideoListModule
//
//  Created by Anton Boyarkin on 19/06/2019.
//

import UIKit
import IBACore
import FlexLayout
import PinLayout

public class CommentView: UIView {
    private let rootFlexContainer = UIView()
    
    public let imageView = UIImageView()
    public let nameLabel = UILabel()
    public let textLabel = UILabel()
    public let dateLabel = UILabel()
    public let addCommentButton = UIButton(type: .custom)
    
    var onAddComment: ((_ model: Comment) -> Void)?
    
    private let model: Comment
    private let colorScheme: ColorSchemeModel
    
    init(model: Comment, colorScheme: ColorSchemeModel) {
        self.model = model
        self.colorScheme = colorScheme
        super.init(frame: .zero)
        
        backgroundColor = colorScheme.backgroundColor
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        
        let comments = Int(model.total_comments) ?? 0
        addCommentButton.setTitle(Localization.Common.Comments.replies(comments), for: .normal)
        
        addCommentButton.setTitleColor(colorScheme.accentColor, for: .normal)
        addCommentButton.titleLabel?.font = .systemFont(ofSize: 14)
        addCommentButton.tintColor = colorScheme.textColor.withAlphaComponent(0.6)
        addCommentButton.sizeToFit()
        
        nameLabel.font = .systemFont(ofSize: 16)
        nameLabel.textColor = colorScheme.textColor
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.numberOfLines = 0
        
        textLabel.font = .systemFont(ofSize: 14)
        textLabel.textColor = colorScheme.secondaryColor
        textLabel.lineBreakMode = .byTruncatingTail
        textLabel.numberOfLines = 0
        
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.lineBreakMode = .byTruncatingTail
        dateLabel.numberOfLines = 0
        dateLabel.textColor = UIColor.black.withAlphaComponent(0.5)
        
        flex.direction(.row).padding(8, 8, 8, 0).define { flex in
            flex.addItem(imageView).width(50).aspectRatio(1)
            flex.addItem().direction(.column).grow(1).define({ flex in
                flex.addItem().direction(.row).marginHorizontal(8).define({ flex in
                    flex.addItem(nameLabel)
                    flex.addItem(dateLabel).marginLeft(8)
                })
                flex.addItem(textLabel).marginHorizontal(8).marginVertical(8)
                
                if model.reply_id == "0" {
                    flex.addItem().direction(.row).marginHorizontal(8).define({ flex in
                        flex.addItem(addCommentButton)
                    })
                }
                flex.addItem().height(1).marginTop(8).backgroundColor(.lightGray)
            })
        }
        
        addSubview(rootFlexContainer)
        
        addCommentButton.addTarget(self, action: #selector(addComment), for: .touchUpInside)
        
        nameLabel.text = model.username
        nameLabel.flex.markDirty()
        
        if let timestamp = Double(model.create) {
            let t = timestamp / 1000.0
            let date = Date(timeIntervalSince1970: t)
            dateLabel.text = date.humanizedString
        } else {
            dateLabel.text = ""
        }
        dateLabel.flex.markDirty()
        
        textLabel.text = model.text
        textLabel.flex.markDirty()
        
        if let url = URL(string: model.avatar) {
            imageView.kf.setImage(with: url)
        }
        imageView.flex.markDirty()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        flex.layout(mode: .adjustHeight)
    }
    
    @objc func addComment() {
        onAddComment?(model)
    }
}
