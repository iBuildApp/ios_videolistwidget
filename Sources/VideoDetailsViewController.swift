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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.onPlay = {
            guard let path = self.data?.url, let url = URL(string: path) else { return }
            
            if self.data?.isYoutube ?? false, let yid = self.data?.youtubeId {
                XCDYouTubeClient.default().getVideoWithIdentifier(yid, completionHandler: { (video, error) in
                    if error == nil, let video = video {
//                        YouTube video stream format codes
//                        https://gist.github.com/sidneys/7095afe4da4ae58694d128b1034e01e2
//
//                        18    mp4    audio/video    360p   XCDYouTubeVideoQualityMedium360
//                        22    mp4    audio/video    720p   XCDYouTubeVideoQualityHD720
//                        37    mp4    audio/video    1080p
//
//                        82    mp4    audio/video    360p
//                        83    mp4    audio/video    480p
//                        84    mp4    audio/video    720p
//                        85    mp4    audio/video    1080p
//
//                        92    hls    audio/video    240p
//                        93    hls    audio/video    360p
//                        94    hls    audio/video    480p
//                        95    hls    audio/video    720p
//                        96    hls    audio/video    1080p
//                        132    hls    audio/video    240p
                        
                        let vidoeUrls = video.streamURLs
                        var vidoeStreamingUrl: URL?
                        
                        innerLoop: for (key, value) in vidoeUrls {
                            switch key.hashValue {
                            case AnyHashable(XCDYouTubeVideoQualityHTTPLiveStreaming).hashValue:
                                vidoeStreamingUrl = value
                                break innerLoop

                            case AnyHashable(XCDYouTubeVideoQuality.HD720).hashValue:
                                vidoeStreamingUrl = value
                                break innerLoop

                            case AnyHashable(84).hashValue:
                                vidoeStreamingUrl = value
                                break innerLoop

                            case AnyHashable(37).hashValue:
                                vidoeStreamingUrl = value
                                break innerLoop

                            case AnyHashable(85).hashValue:
                                vidoeStreamingUrl = value
                                break innerLoop

                            case AnyHashable(83).hashValue:
                                vidoeStreamingUrl = value
                                break innerLoop

                            case AnyHashable(XCDYouTubeVideoQuality.medium360).hashValue:
                                vidoeStreamingUrl = value
                                break innerLoop

                            case AnyHashable(82).hashValue:
                                vidoeStreamingUrl = value
                                break innerLoop

                            case AnyHashable(XCDYouTubeVideoQuality.small240).hashValue:
                                vidoeStreamingUrl = value
                                break innerLoop

                            default: continue
                            }
                        }
                        
                        if let videoUrl = vidoeStreamingUrl {
                            let player = AVPlayer(url: videoUrl)
                            let playerController = AVPlayerViewController()
                            playerController.player = player
                            playerController.allowsPictureInPicturePlayback = false
                            if #available(iOS 11.0, *) {
                                playerController.entersFullScreenWhenPlaybackBegins = true
                                playerController.exitsFullScreenWhenPlaybackEnds = true
                            }
                            self.present(playerController, animated: true) {
                                player.play()
                            }
                        } else if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
                    
                    if let videoURL = vid.videoURL[.Quality720p] ?? vid.videoURL[.Quality960p] ?? vid.videoURL[.Quality1080p] ?? vid.videoURL[.Quality640p] ?? vid.videoURL[.Quality540p] ?? vid.videoURL[.Quality360p] {
                        let player = AVPlayer(url: videoURL)
                        let playerController = AVPlayerViewController()
                        playerController.player = player
                        self.present(playerController, animated: true) {
                            player.play()
                        }
                    } else if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
            var message = String(format: Localization.Common.Share.Video.message, url, appName)
            let showLink = app.design?.isShowLink ?? false
            if showLink {
                let link = "https://ibuildapp.com/projects.php?action=info&projectid=\(appConfig.appID)"
                message.append("\n")
                message.append(String(format: Localization.Common.Share.link, appName, link))
                message.append("\n")
                message.append(Localization.Common.Share.postedVia)
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
