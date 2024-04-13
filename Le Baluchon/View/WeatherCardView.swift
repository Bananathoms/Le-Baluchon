//
//  WeatherCardView.swift
//  Le Baluchon
//
//  Created by Thomas Carlier on 13/04/2024.
//

import Foundation
import UIKit

@IBDesignable
class WeatherCardView: UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = true
        }
    }
}
