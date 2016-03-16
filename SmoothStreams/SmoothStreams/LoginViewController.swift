//
//  LoginViewController.swift
//  SmoothStreams
//
//  Created by Omar Basrawi on 2/24/16.
//  Copyright © 2016 Omar Basrawi. All rights reserved.
//

import UIKit
import Locksmith

class LoginViewController: UIViewController {
	let LoginToScheduleSegue = "LoginToScheduleSegue"

	// MARK - @IBOutlets
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

	@IBOutlet weak var loginButton: UIButton! {
		didSet {
			self.loginButton.layer.cornerRadius = CGFloat(5)
		}
	}

	var mode = Services()

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		if let email = emailTextField.text {
			if email.isEmpty {
				emailTextField.becomeFirstResponder()
			}
		}

		if let password = passwordTextField.text {
			if password.isEmpty {
				passwordTextField.becomeFirstResponder()
			}
		}
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		emailTextField.text = ""
		passwordTextField.text = ""

	}

	@IBAction func userLogin(sender: UIButton) {
		self.activityIndicator.hidden = false
		self.activityIndicator.startAnimating()
		login()
	}

	func login() {
		let prefs = NSUserDefaults.standardUserDefaults()
		let s = prefs.valueForKey("site") as! Int
		let a = mode.serviceDetailsForRow(s)

		guard let email = emailTextField.text else {
			return
		}

		guard let password = passwordTextField.text else {
			return
		}

		AuthenticationManager.request(email, password: password, host: a.host) { manager in
			guard let authManager = manager else {
				return
			}
			
			if authManager.code.getType {
				NSOperationQueue.mainQueue().addOperationWithBlock({
					self.activityIndicator.stopAnimating()
					self.performSegueWithIdentifier(self.LoginToScheduleSegue, sender: self)
				})

			} else {

				let alertVC = UIAlertController(title: "Hold up", message: authManager.error, preferredStyle: UIAlertControllerStyle.Alert)
				let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { _ in
					alertVC.dismissViewControllerAnimated(true, completion: nil)
				})
					alertVC.addAction(dismissAction)

				dispatch_async(dispatch_get_main_queue(), { () -> Void in
					self.activityIndicator.stopAnimating()
					self.presentViewController(alertVC, animated: true, completion: nil)
				})
			}
		}
	}
}

extension LoginViewController: UITextFieldDelegate {
	func textFieldShouldReturn(textField: UITextField) -> Bool {

		if textField == emailTextField {
			passwordTextField.becomeFirstResponder()
		} else if textField == passwordTextField {
			passwordTextField.resignFirstResponder()
		}

		return true
	}
}