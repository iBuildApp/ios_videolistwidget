//
//  CommantReplyView.swift
//  VideoListModule
//
//  Created by Anton Boyarkin on 20/06/2019.
//

import UIKit
import FlexLayout
import PinLayout
import IBACore
import IBACoreUI

public class CommantReplyView: UIView {
    private let contentView = UIScrollView()
    private let rootFlexContainer = UIView()
    
    public let imageView = UIImageView()
    public let nameLabel = UILabel()
    public let textLabel = UILabel()
    public let dateLabel = UILabel()
    public let repliesLabel = UILabel()
    public let commentsConteiner = UIView()
    public let inputConteiner = UIView()
    public var commentInputView: TextInputView!
    
    var canComment = false {
        didSet {
            updateVisibility()
        }
    }
    
    var onSubmitComment: ((_ name: String, _ text: String) -> Void)?
    
    private let model: Comment
    private let colorScheme: ColorSchemeModel
    
    private var commentViews: [CommentView] = []
    
    init(model: Comment, colorScheme: ColorSchemeModel) {
        self.model = model
        self.colorScheme = colorScheme
        super.init(frame: .zero)
        
        backgroundColor = colorScheme.backgroundColor
        
        commentInputView = TextInputView(colorScheme: colorScheme)
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        
        nameLabel.font = .systemFont(ofSize: 16)
        nameLabel.textColor = colorScheme.textColor
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.numberOfLines = 0
        
        textLabel.font = .systemFont(ofSize: 14)
        textLabel.textColor = colorScheme.textColor
        textLabel.lineBreakMode = .byTruncatingTail
        textLabel.numberOfLines = 0
        
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.lineBreakMode = .byTruncatingTail
        dateLabel.numberOfLines = 0
        dateLabel.textColor = UIColor.black.withAlphaComponent(0.5)
        
        repliesLabel.font = .systemFont(ofSize: 16)
        repliesLabel.textColor = colorScheme.textColor
        repliesLabel.lineBreakMode = .byTruncatingTail
        repliesLabel.numberOfLines = 0
        repliesLabel.text = Localization.Common.Comments.replies(0)
        
        rootFlexContainer.flex.define { flex in
            flex.addItem().direction(.row).padding(8, 8, 8, 0).define ({ flex in
                flex.addItem(imageView).width(50).aspectRatio(1)
                flex.addItem().direction(.column).marginLeft(8).grow(1).define({ flex in
                    flex.addItem(nameLabel)
                    flex.addItem(dateLabel)
                })
            })
            flex.addItem(textLabel).marginHorizontal(8).marginVertical(8)
            
            flex.addItem().height(1).backgroundColor(.lightGray)
            flex.addItem(repliesLabel).marginHorizontal(20).marginVertical(8)
            flex.addItem().height(1).backgroundColor(.lightGray)
            flex.addItem(commentsConteiner)
        }
        
        contentView.addSubview(rootFlexContainer)
        
        addSubview(contentView)
        
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
        
        addSubview(commentInputView)
        addSubview(inputConteiner)
        
        updateVisibility()
        
        inputConteiner.backgroundColor = commentInputView.backgroundColor
        
        commentInputView.pin.bottom(pin.safeArea).right().left()
        commentInputView.flex.layout(mode: .adjustHeight)
        inputConteiner.pin.bottomLeft().right().below(of: commentInputView)
        
        commentInputView.onSubmit = { name, text in
            self.onSubmitComment?(name, text)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        commentInputView.pin.bottom(pin.safeArea).right().left()
        commentInputView.flex.layout(mode: .adjustHeight)
        inputConteiner.pin.bottomLeft().right().below(of: commentInputView)
        
        let inputHeight = commentInputView.bounds.height + inputConteiner.bounds.height
        
        // 1) Layout the contentView & rootFlexContainer using PinLayout
        contentView.pin.all(pin.safeArea)
        rootFlexContainer.pin.top().left().right()
        
        // 2) Let the flexbox container layout itself and adjust the height
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        
        // 3) Adjust the scrollview contentSize
        var size = rootFlexContainer.frame.size
        if canComment {
            size.height += inputHeight
        }
        contentView.contentSize = size
    }
    
    func updateVisibility() {
        commentInputView.isHidden = !canComment
        inputConteiner.isHidden = !canComment
    }
    
    func setReplies(_ comments: [Comment]) {
        repliesLabel.text = Localization.Common.Comments.replies(comments.count)
        repliesLabel.flex.markDirty()
        
        for view in commentViews {
            view.isHidden = true
            view.flex.isIncludedInLayout(false)
            view.removeFromSuperview()
        }
        
        commentViews.removeAll()
        
        commentsConteiner.flex.define { flex in
            for comment in comments {
                let view = CommentView(model: comment, colorScheme: colorScheme)
                self.commentViews.append(view)
                flex.addItem(view)
            }
        }
        
        commentsConteiner.flex.markDirty()
        
        setNeedsLayout()
    }
}
