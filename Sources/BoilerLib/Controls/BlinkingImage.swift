//
//  BlinkingImage.swift
//  Marla
//
//  Created by Daniel Vela on 22/03/2020.
//  Copyright © 2020 veladan. All rights reserved.
//

import UIKit

public class BlinkingImage: UIImageView {
    public override func awakeFromNib() {
    addNotifications()
    animate()
  }

  private func addNotifications() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(applicationWillEnterForeground(_:)),
                                           name: UIApplication.willEnterForegroundNotification, object: nil)
  }

  @objc
  private func applicationWillEnterForeground(_ notification: NSNotification) {
    animate()
  }

  private func animate() {
    self.layer.removeAllAnimations()
    self.alpha = 1.0
    UIView.animate(withDuration: 1.2, delay: 0.0, options: [.autoreverse, .repeat, .curveEaseInOut], animations: {
      self.alpha = 0.10
    })
  }
}
