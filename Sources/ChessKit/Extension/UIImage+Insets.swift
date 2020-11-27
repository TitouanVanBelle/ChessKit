//
//  UIImage+Insets.swift
//  
//
//  Created by Titouan Van Belle on 11.11.20.
//

import UIKit

extension UIImage {
    func with(inset: CGFloat) -> UIImage? {
        let insets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        return with(insets: insets)
    }

    func with(insets: UIEdgeInsets) -> UIImage? {
        let cgSize = CGSize(width: self.size.width + insets.left * self.scale + insets.right * self.scale,
                            height: self.size.height + insets.top * self.scale + insets.bottom * self.scale)

        UIGraphicsBeginImageContextWithOptions(cgSize, false, self.scale)
        defer { UIGraphicsEndImageContext() }

        let origin = CGPoint(x: insets.left * self.scale, y: insets.top * self.scale)
        self.draw(at: origin)

        return UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(self.renderingMode)

    }
}

