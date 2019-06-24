//
//  VideoListViewController.swift
//  VideoListModule
//
//  Created by Anton Boyarkin on 13/06/2019.
//

import UIKit
import IBACore
import IBACoreUI
import Kingfisher
import PinLayout
import FlexLayout

class VideoListViewController: BaseListViewController<VideoItemCell> {
    // MARK: - Private properties
    /// Widget type indentifier
    private var type: String?
    
    /// Widger config data
    private var data: DataModel?
    
    private var colorScheme: ColorSchemeModel?
    
    // MARK: - Controller life cycle methods
    public convenience init(type: String?, data: DataModel?) {
        let colorScheme = data?.colorScheme ?? AppManager.manager.appModel()?.design?.colorScheme
        self.init(with: colorScheme, data: data?.videos)
        self.type = type
        self.data = data
        self.colorScheme = colorScheme
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.onItemSelect = { item in
            let vc = VideoDetailsViewController(with: self.colorScheme, data: item, moduleId: self.data?.moduleId)
            vc.canShare = self.data?.canShare ?? false
            vc.canLike = self.data?.canLike ?? false
            vc.canComment = self.data?.canComment ?? false
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
