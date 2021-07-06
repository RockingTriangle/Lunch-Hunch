//
//  ForgetPasswordViewController.swift
//  Lunch Hunch
//
//  Created by Lunch Hunch Team on 6/14/21.
//

import UIKit

class ForgetPasswordViewController: UIViewController {

    // MARK: - Properties
    let vm = ResetPasswordViewModel()
    
    // MARK: - IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        setupUI()
        initVM()
    }
    
    // MARK:- Init view model
    private func initVM() {
        vm.showAlertClosure = { [weak self] in
            guard let self = self else { return }
            if self.vm.isSuccess {
                self.navigationController?.popToRootViewController(animated: true)
                Alert.showAlert(at: self, title: self.vm.message!, message: "")
            } else {
                self.activityIndicator.stopAnimating()
                self.resetButton.isEnabled = true
                Alert.showAlert(at: self, title: self.vm.message!, message: "")
            }
        }
    }
    
    // MARK:- Actions
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        activityIndicator.startAnimating()
        sender.isEnabled = false
        vm.resetPassword(email: emailTextField.text!)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupUI() {
        resetButton.layer.cornerRadius = 27.5
        emailTextField.layer.cornerRadius = 27.5
        emailTextField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        setupTextFields(textField: emailTextField)
        tapGesture.addTarget(self, action: #selector(dismissKeyboard))
    }
    
    func setupTextFields(textField: UITextField) {
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: textField.frame.height))
        textField.rightViewMode = .always
    }
    
}
