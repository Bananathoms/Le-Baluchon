//
//  SettingsViewController.swift
//  Le Baluchon
//
//  Created by Thomas Carlier on 13/04/2024.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    @IBOutlet weak var cityHomeTextfield: UITextField!
    @IBOutlet weak var cityDestinationTextField: UITextField!
    @IBOutlet weak var cityHomeSetButton: UIButton!
    @IBOutlet weak var cityDestinationSetButton: UIButton!
    @IBOutlet weak var cityHomeLabel: UILabel!
    @IBOutlet weak var cityDestinationLabel: UILabel!
    
    
    @IBOutlet weak var currencyHomePicker: UIPickerView!
    @IBOutlet weak var currencyDestinationPicker: UIPickerView!
    
    // List of currencies
    let currencies = ["USD", "EUR", "JPY", "GBP", "AUD", "CAD", "CHF", "CNY", "SEK", "NZD"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currencyHomePicker.delegate = self
        currencyHomePicker.dataSource = self
        currencyDestinationPicker.delegate = self
        currencyDestinationPicker.dataSource = self
    }
    
    // UIPickerViewDataSource
    @objc(numberOfComponentsInPickerView:) func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @objc func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencies.count
    }
    
    // UIPickerViewDelegate
    @objc func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencies[row]
    }
}
