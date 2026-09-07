//
//  RootViewControllerProvider.swift
//  DangoStack
//

import UIKit

@MainActor
enum RootViewControllerProvider {
    static func topViewController() -> UIViewController? {
        let windowScenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .sorted { lhs, rhs in
                scenePriority(lhs.activationState) > scenePriority(rhs.activationState)
            }

        let rootViewController = windowScenes
            .flatMap(\.windows)
            .sorted { $0.isKeyWindow && !$1.isKeyWindow }
            .first { !$0.isHidden && $0.windowLevel == .normal }?
            .rootViewController

        return visibleViewController(from: rootViewController)
    }

    private static func visibleViewController(
        from viewController: UIViewController?
    ) -> UIViewController? {
        if let presented = viewController?.presentedViewController {
            return visibleViewController(from: presented)
        }
        if let navigation = viewController as? UINavigationController {
            return visibleViewController(from: navigation.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            return visibleViewController(from: tab.selectedViewController)
        }
        if let split = viewController as? UISplitViewController {
            return visibleViewController(from: split.viewControllers.last)
        }
        return viewController
    }

    private static func scenePriority(
        _ state: UIScene.ActivationState
    ) -> Int {
        switch state {
        case .foregroundActive: 3
        case .foregroundInactive: 2
        case .background: 1
        case .unattached: 0
        @unknown default: 0
        }
    }
}
