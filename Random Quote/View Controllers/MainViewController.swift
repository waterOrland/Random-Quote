//
//  ViewController.swift
//  Random Quote
//
//  Created by Orland Tompkins.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var listButton: UIButton!
    @IBOutlet var quoteLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    
    var quoteManager = QuoteManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        quoteLabel.isHidden = true
        authorLabel.isHidden = true
        
        quoteManager.delegate = self
        searchTextField.delegate = self
    }
    
    @IBAction func getQuoteButton(_ sender: UIButton) {
        quoteManager.fetchQuote()
    }
}

// MARK: - UITextFieldDelegate
extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    // TODO: - Replace with textFieldPrimaryAction
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            // fetch author bio
            quoteManager.fetchBio(name: "Albert-EINSTEIN")
            return true
        } else {
            textField.placeholder = "Requrired*"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        searchTextField.text = ""
    }
}

// MARK: - QuoteDataDelegate
extension MainViewController: QuoteDataDelegate {
    func sendData(_ quoteModel: QuoteModel) {
        DispatchQueue.main.async {
            self.quoteLabel.text = quoteModel.randomQuote
            self.authorLabel.text = "-\(quoteModel.authorName)"
            self.quoteLabel.isHidden = false
            self.authorLabel.isHidden = false
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

// MARK: - UIViewController
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
