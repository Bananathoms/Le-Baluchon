//
//  Extension+UIViewController.swift
//  Le Baluchon
//
//  Created by Thomas Carlier on 29/05/2024.
//

import Foundation
import UIKit

extension UIViewController {
    /// Displays an alert with a title, message, and an OK button.
    /// - Parameters:
    ///   - title: The title of the alert.
    ///   - message: The message body of the alert.
    ///   - okButtonTitle: The title of the OK button. Defaults to "OK".
    func showAlert(title: String, message: String, okButtonTitle: String = "OK") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okButtonTitle, style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
