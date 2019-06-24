//
//  CommentViewController.swift
//  VideoListModule
//
//  Created by Anton Boyarkin on 20/06/2019.
//

import UIKit
import IBACore
import IBACoreUI
import PKHUD

class CommentReplyViewController: BaseViewController {
    private var video: VideoItemModel?
    private var comment: Comment?
    private var colorScheme: ColorSchemeModel?
    private var moduleId: String?
    
    public var onReplyPosted: (()->Void)?
    
    var canComment = false {
        didSet {
            mainView.canComment = canComment
        }
    }
    
    // MARK: - Controller life cycle methods
    convenience init(with colorScheme: ColorSchemeModel?, video: VideoItemModel?, comment: Comment?, moduleId: String?) {
        self.init()
        self.video = video
        self.comment = comment
        self.colorScheme = colorScheme
        self.moduleId = moduleId
    }
    
    fileprivate var mainView: CommantReplyView {
        return self.view as! CommantReplyView
    }
    
    override public func loadView() {
        if let data = comment, let colorScheme = colorScheme {
            view = CommantReplyView(model: data, colorScheme: colorScheme)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let vid = video?.id, let mid = moduleId, let cid = comment?.id {
            mainView.onSubmitComment = { name, text in
                HUD.show(.progress)
                AppManager.manager.apiService?.postComment(name: name, text: text, for: "\(vid)", of: "video", reply: cid, module: mid, {
                    AppManager.manager.apiService?.getComments(for: "\(vid)", of: "video", reply: cid, module: mid) { comments in
                        HUD.hide()
                        self.mainView.setReplies(comments)
                        self.onReplyPosted?()
                    }
                })
            }
            AppManager.manager.apiService?.getComments(for: "\(vid)", of: "video", reply: cid, module: mid) { comments in
                self.mainView.setReplies(comments)
            }
        }
    }
}
