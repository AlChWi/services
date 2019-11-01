//
//  UIImageView+extensions.swift
//  Services App
//
//  Created by Perov Alexey on 15.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func createImageWith(text: String, textSize: CGFloat, textColor: UIColor?, backgroundColor: UIColor) {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0.0)
        let label = UILabel(frame: self.frame)
        label.text = text
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: textSize)
        label.textColor = textColor
        label.backgroundColor = backgroundColor
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        label.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.image = image
    }
}
