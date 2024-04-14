//
//  SettingsViewController.swift
//  Le Baluchon
//
//  Created by Thomas Carlier on 13/04/2024.
//

import Foundation
import UIKit

/// This class manages the settings, including language and currency preferences.
class SettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    // Outlets for city settings
    @IBOutlet weak var cityHomeTextfield: UITextField!
    @IBOutlet weak var cityDestinationTextField: UITextField!
    @IBOutlet weak var cityHomeSetButton: UIButton!
    @IBOutlet weak var cityDestinationSetButton: UIButton!
    @IBOutlet weak var cityHomeLabel: UILabel!
    @IBOutlet weak var cityDestinationLabel: UILabel!
    // Outlets for currency settings
    @IBOutlet weak var currencyDestinationPicker: UIPickerView!
    @IBOutlet weak var currencyDestinationSetButton: UIButton!
    @IBOutlet weak var currencyDestinationSelectedLabel: UILabel!
    // Outlets for Language settings
    @IBOutlet weak var homeLanguagePicker: UIPickerView!
    @IBOutlet weak var homeLanguageSetButton: UIButton!
    @IBOutlet weak var homeLanguageLabel: UILabel!
    @IBOutlet weak var destinationLanguagePicker: UIPickerView!
    @IBOutlet weak var destinationLanguageSetButton: UIButton!
    @IBOutlet weak var destinationLanguageLabel: UILabel!
    // List of currencies and languages
    var currencies: [Currency] = []
    var homeLanguages: [Language] = []
    var destinationLanguages: [Language] = []
    
    /// Initializes the controller's view and loads necessary data.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPickers()
        self.loadCurrencies()
        self.loadLanguages()
    }
    
    /// Configures all UIPickerView delegates and data sources.
    private func setupPickers() {
        self.currencyDestinationPicker.delegate = self
        self.currencyDestinationPicker.dataSource = self
        self.homeLanguagePicker.delegate = self
        self.homeLanguagePicker.dataSource = self
        self.destinationLanguagePicker.delegate = self
        self.destinationLanguagePicker.dataSource = self
    }
    
    /// Handles setting the home city from a UITextField to a UILabel.
    /// - Parameter sender: The UIButton that triggered this action.
    @IBAction func setCityHome(_ sender: UIButton) {
        let defaultHomeCity = "Paris"
        let homeCity = cityHomeTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true ? defaultHomeCity : cityHomeTextfield.text!
        UserDefaults.standard.set(homeCity, forKey: "SelectedHomeCity")
        self.cityHomeLabel.text = homeCity
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: NSNotification.Name("HomeCityUpdated"), object: nil)
    }
    
    /// Handles setting the destination city from a UITextField to a UILabel.
    /// - Parameter sender: The UIButton that triggered this action.
    @IBAction func setCityDestination(_ sender: UIButton) {
        let defaultDestinationCity = "New York"
        let destinationCity = cityDestinationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true ? defaultDestinationCity : cityDestinationTextField.text!
        UserDefaults.standard.set(destinationCity, forKey: "SelectedDestinationCity")
        self.cityDestinationLabel.text = destinationCity
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: NSNotification.Name("DestinationCityUpdated"), object: nil)
    }
    
    /// Sets the selected currency as the destination currency and updates the label.
    /// - Parameter sender: The UIButton that triggered this action.
    @IBAction func setDestinationCurrency(_ sender: UIButton) {
        let selectedIndex = self.currencyDestinationPicker.selectedRow(inComponent: 0)
        let selectedCurrency = self.currencies[selectedIndex].code
        self.currencyDestinationSelectedLabel.text = "Selected: \(currencies[selectedIndex].name) (\(selectedCurrency))"
        UserDefaults.standard.set(selectedCurrency, forKey: "DestinationCurrency")
        UserDefaults.standard.synchronize()
    }
    
    
    /// Sets the home language based on the user's selection in the homeLanguagePicker and updates the interface.
    /// - Parameter sender: The UIButton that triggered this action.
    @IBAction func setHomeLanguage(_ sender: UIButton) {
        let selectedIndex = self.homeLanguagePicker.selectedRow(inComponent: 0)
        let selectedLanguage = self.homeLanguages[selectedIndex]
        UserDefaults.standard.set(selectedLanguage.language, forKey: "SelectedHomeLanguageCode")
        UserDefaults.standard.set(selectedLanguage.name, forKey: "SelectedHomeLanguageName")
        UserDefaults.standard.synchronize()
        self.homeLanguageLabel.text = "\(selectedLanguage.name) (\(selectedLanguage.language))"
        NotificationCenter.default.post(name: NSNotification.Name("LanguagePreferenceChanged"), object: nil)
    }
    
    
    /// Sets the destination language based on user selection from the picker view.
    /// - Parameter sender: The UIButton that triggered this action.
    @IBAction func setDestinationLanguage(_ sender: UIButton) {
        let selectedIndex = self.destinationLanguagePicker.selectedRow(inComponent: 0)
        let selectedLanguage = self.destinationLanguages[selectedIndex]
        UserDefaults.standard.set(selectedLanguage.language, forKey: "SelectedDestinationLanguageCode")
        UserDefaults.standard.set(selectedLanguage.name, forKey: "SelectedDestinationLanguageName")
        UserDefaults.standard.synchronize()
        self.destinationLanguageLabel.text = "\(selectedLanguage.name) (\(selectedLanguage.language))"
        NotificationCenter.default.post(name: NSNotification.Name("LanguagePreferenceChanged"), object: nil)
    }
    
    /// Loads currency data from a JSON file and updates the UIPickerView.
    private func loadCurrencies() {
        let jsonDecoder = JSONDecoder()
        if let url = Bundle.main.url(forResource: "currencies", withExtension: "json"),
           let jsonData = try? Data(contentsOf: url),
           let currencyList = try? jsonDecoder.decode(CurrencyList.self, from: jsonData) {
            self.currencies = currencyList.symbols.map { Currency(code: $0.key, name: $0.value) }
            self.currencyDestinationPicker.reloadAllComponents()
            if let usdIndex = currencies.firstIndex(where: { $0.code == "USD" }) {
                self.currencyDestinationPicker.selectRow(usdIndex, inComponent: 0, animated: false)
                self.pickerView(currencyDestinationPicker, didSelectRow: usdIndex, inComponent: 0)
            }
        }
    }
    
    /// Loads language data from a JSON file and updates the UIPickerView for both home and destination languages.
    private func loadLanguages() {
        let jsonDecoder = JSONDecoder()
        if let url = Bundle.main.url(forResource: "languages", withExtension: "json"),
           let jsonData = try? Data(contentsOf: url),
           let languageList = try? jsonDecoder.decode(LanguagesList.self, from: jsonData) {
            self.homeLanguages = languageList.data.languages
            self.destinationLanguages = languageList.data.languages
            self.homeLanguagePicker.reloadAllComponents()
            self.destinationLanguagePicker.reloadAllComponents()

            if let defaultHomeIndex = self.homeLanguages.firstIndex(where: { $0.language == "fr" }) {
                self.homeLanguagePicker.selectRow(defaultHomeIndex, inComponent: 0, animated: false)
                self.pickerView(homeLanguagePicker, didSelectRow: defaultHomeIndex, inComponent: 0)
            }
            if let defaultDestinationIndex = self.destinationLanguages.firstIndex(where: { $0.language == "en" }) {
                self.destinationLanguagePicker.selectRow(defaultDestinationIndex, inComponent: 0, animated: false)
                self.pickerView(destinationLanguagePicker, didSelectRow: defaultDestinationIndex, inComponent: 0)
            }
        }
    }
    
    // UIPickerViewDataSource
    /// Returns the number of 'columns' or 'components' to display in the picker view.
    /// - Parameter pickerView: The UIPickerView instance that is querying the number of components.
    /// - Returns: The number of components (columns) to display in the picker view. Always returns 1 for simplicity.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /// Determines the number of rows that should be displayed in the specified component of the picker view.
    /// - Parameters:
    ///   - pickerView: The UIPickerView instance requesting this information. This can be one of the currency or language picker views.
    ///   - component: An integer identifying the component of the picker view requesting the number of rows. As there is only one component in each picker, this is typically 0.
    /// - Returns: The number of rows in the component. For the currency picker, it returns the number of currencies available; for the language pickers, it returns the number of languages available.
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.currencyDestinationPicker {
            return self.currencies.count
        } else if pickerView == self.homeLanguagePicker || pickerView == self.destinationLanguagePicker {
            return self.homeLanguages.count
        }
        return 0
    }
    
    // UIPickerViewDelegate
    /// Provides the title for a given row in a specific component of the picker view.
    /// - Parameters:
    ///   - pickerView: The UIPickerView that is requesting the title. This determines which dataset is used for the title (currencies or languages).
    ///   - row: The zero-indexed position of the row for which the title is requested. This index is used to retrieve data from either the `currencies` or `homeLanguages` arrays.
    ///   - component: The zero-indexed position of the component within the picker view. In this setup, there is only one component.
    /// - Returns: A formatted string that represents the content of the row in the picker view, or nil if no data is available for that row.
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.numberOfLines = 1

        if pickerView == currencyDestinationPicker {
            label.text = "\(currencies[row].name) - \(currencies[row].code)"
        } else if pickerView == homeLanguagePicker || pickerView == destinationLanguagePicker {
            label.text = "\(homeLanguages[row].name) (\(homeLanguages[row].language))"
        }

        return label
    }
    
    /// Called when a row is selected in one of the picker views.
    /// - Parameters:
    ///   - pickerView: The UIPickerView in which a row was selected. This method specifically checks if it's the currency destination picker.
    ///   - row: The zero-indexed number of the row that was selected. This is used to access the corresponding currency from the `currencies` array.
    ///   - component: The zero-indexed number of the component within the picker view. This setup assumes there is only one component.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.currencyDestinationPicker {
            let selectedCurrency = self.currencies[row].code
            UserDefaults.standard.set(selectedCurrency, forKey: "DestinationCurrency")
        }
    }
}
