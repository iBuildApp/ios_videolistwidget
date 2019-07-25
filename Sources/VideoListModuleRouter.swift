//
//  VideoListModuleRouter.swift
//  VideoListModule
//
//  Created by Anton Boyarkin on 13/06/2019.
//

import IBACore
import IBACoreUI

public enum VideoListModuleRoute: Route {
    case root
}

public class VideoListModuleRouter: BaseRouter<VideoListModuleRoute> {
    var module: VideoListModule?
    init(with module: VideoListModule) {
        self.module = module
    }

    public override func generateRootViewController() -> BaseViewControllerType {
        return VideoListViewController(type: module?.config?.type, data: module?.data)
    }

    public override func prepareTransition(for route: VideoListModuleRoute) -> RouteTransition {
        return RouteTransition(module: generateRootViewController(), isAnimated: true)
    }

    public override func rootTransition() -> RouteTransition {
        return self.prepareTransition(for: .root)
    }
}
