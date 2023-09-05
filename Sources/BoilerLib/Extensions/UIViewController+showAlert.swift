//
//  UIViewController+showAlert.swift
//  lishop-swift-uikit
//
//  Created by Daniel Vela on 7/3/23.
//

import UIKit

public extension UIViewController {
    func showAlert(_ message: String, title: String? = nil, onFinish: @escaping () -> Void = {}) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK",
                                                               comment: "showAlert button"),
                                      style: .default) { _ in onFinish() })
        self.present(alert, animated: true) {}
    }

    static func showAlertOnTopController(_ message: String,
                                         title: String? = nil,
                                         onFinish: @escaping () -> Void = {}) {
        var rootViewController = Self.rootViewController()
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first
        } else if let tabBarController = rootViewController as? UITabBarController {
            rootViewController = tabBarController.selectedViewController
        }
        rootViewController?.showAlert(message, title: title, onFinish: onFinish)
    }

    static func rootViewController() -> UIViewController? {
        let keyWindow = UIApplication
            .shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }
        return keyWindow?.rootViewController
    }

    func showTemporalAlert(_ message: String,
                           title: String? = nil,
                           seconds: Double = 0.3,
                           onFinish: @escaping () -> Void = {}) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                alert.dismiss(animated: true)
                onFinish()
            }
        }
    }
}
