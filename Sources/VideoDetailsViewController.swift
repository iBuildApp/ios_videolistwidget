//
//  VideoDetailsViewController.swift
//  VideoListModule
//
//  Created by Anton Boyarkin on 17/06/2019.
//

import UIKit
import IBACore
import IBACoreUI
import XCDYouTubeKit
import HCVimeoVideoExtractor
import PKHUD

import AVKit
import AVFoundation

class VideoDetailsViewController: BaseViewController {
    private var data: VideoItemModel?
    private var colorScheme: ColorSchemeModel?
    private var moduleId: String?
    
    var canShare = false {
        didSet {
            mainView.canShare = canShare
        }
    }
    
    var canLike = false {
        didSet {
            mainView.canLike = canLike
        }
    }
    
    var canComment = false {
        didSet {
            mainView.canComment = canComment
        }
    }
    
    // MARK: - Controller life cycle methods
    convenience init(with colorScheme: ColorSchemeModel?, data: VideoItemModel?, moduleId: String?) {
        self.init()
        self.data = data
        self.colorScheme = colorScheme
        self.moduleId = moduleId
    }
    
    fileprivate var mainView: VideoDetailsView {
        return self.view as! VideoDetailsView
    }
    
    override public func loadView() {
        if let data = data, let colorScheme = colorScheme {
            view = VideoDetailsView(model: data, colorScheme: colorScheme)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.onPlay = {
            guard let path = self.data?.url, let url = URL(string: path) else { return }
            
            if self.data?.isYoutube ?? false, let yid = self.data?.youtubeId {
                XCDYouTubeClient.default().getVideoWithIdentifier(yid, completionHandler: { (video, error) in
                    if error == nil, let video = video {
                        if let videoURL = video.streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?? video.streamURLs[XCDYouTubeVideoQuality.HD720] ?? video.streamURLs[136] ?? video.streamURLs[135] ?? video.streamURLs[134] {
                            
                            let player = AVPlayer(url: videoURL)
                            let playerController = AVPlayerViewController()
                            playerController.player = player
                            self.present(playerController, animated: true) {
                                player.play()
                            }
                        }
                    } else {
                        print("Error: \(error!.localizedDescription)")
                    }
                })
            } else if self.data?.isVimeo ?? false {
                HCVimeoVideoExtractor.fetchVideoURLFrom(url: url, completion: { (video: HCVimeoVideo?, error: Error?) -> Void in
                    if let err = error {
                        print("Error = \(err.localizedDescription)")
                        return
                    }
                    
                    guard let vid = video else {
                        print("Invalid video object")
                        return
                    }
                    
                    if let videoURL = vid.videoURL[.Quality720p] {
                        let player = AVPlayer(url: videoURL)
                        let playerController = AVPlayerViewController()
                        playerController.player = player
                        self.present(playerController, animated: true) {
                            player.play()
                        }
                    }
                })
            } else {
                let player = AVPlayer(url: url)
                let playerController = AVPlayerViewController()
                playerController.player = player
                self.present(playerController, animated: true) {
                    player.play()
                }
            }
        }
        
        if let vid = data?.id, let mid = moduleId {
            mainView.onSubmitComment = { name, text in
                HUD.show(.progress)
                AppManager.manager.apiService?.postComment(name: name, text: text, for: "\(vid)", of: "video", reply: "0", module: mid, {
                    self.loadComments { comments in
                        HUD.hide()
                        self.mainView.setComments(comments)
                    }
                })
            }
            
            loadComments { comments in
                self.mainView.setComments(comments)
            }
        }
        
        mainView.onAddComment = { comment in
            let vc = CommentReplyViewController<VideoItemModel>(with: self.colorScheme, item: self.data, comment: comment, moduleId: self.moduleId)
            vc.canComment = self.canComment
            vc.onReplyPosted = {
                self.loadComments { comments in
                    self.mainView.setComments(comments)
                }
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        mainView.onShare = {
            guard let app = AppManager.manager.appModel(), let appConfig = AppManager.manager.config(), let url = self.data?.url else { return }
            let appName = app.design?.appName ?? ""
            var message = String(format: Localization.VideoList.Share.message, url, appName)
            let showLink = app.design?.isShowLink ?? false
            if showLink {
                let link = "https://ibuildapp.com/projects.php?action=info&projectid=\(appConfig.appID)"
                message.append("\n")
                message.append(String(format: Localization.VideoList.Share.link, appName, link))
                message.append("\n")
                message.append(Localization.VideoList.Share.postedVia)
            }
            
            let textToShare = [ message ]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func loadComments(_ completion: @escaping ([Comment])->Void) {
        if let vid = data?.id, let mid = moduleId {
            AppManager.manager.apiService?.getComments(for: "\(vid)", of: "video", reply: "0", module: mid) { comments in
                completion(comments)
            }
        }
    }
}
