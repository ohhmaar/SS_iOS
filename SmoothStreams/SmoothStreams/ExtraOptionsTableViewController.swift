//
//  ExtraOptionsTableViewController.swift
//  SmoothStreams
//
//  Created by Omar Basrawi on 3/14/16.
//  Copyright © 2016 Omar Basrawi. All rights reserved.
//

import UIKit

protocol ExtraOptionsDelegate {
	func testingSomeDelegate(data: String)
}

class ExtraOptionsTableViewController: UITableViewController {

	let QualityCellIdentifier = "QualityCellIdentifier"
	var delegate: ExtraOptionsDelegate?
	var AuthManager: AuthenticationManager?

	var streamType: String? {
		didSet {
			self.tableView.reloadData()
		}
	}

	@IBAction func dismissSettings(sender: UIBarButtonItem) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

		return ["quality", "logout"][section]
	}

	private func typeOfStreamQuality(type: String?) -> String? {
		if type == LOW_QUALITY_STREAM {
			return "Low Quality"
		} else if type == HIGH_QUALITY_STREAM {
			return "High Quality"
		}
		return "Select stream type"
	}

	enum ExtraOptionsTableViewSection: Int {
		case Quality = 0
		case Logout = 1
	}

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		switch (ExtraOptionsTableViewSection(rawValue: indexPath.section)!) {
		case .Quality:
			let cell = UITableViewCell(style: .Value1, reuseIdentifier: QualityCellIdentifier)
			cell.textLabel?.text = "Select the quality"
			cell.detailTextLabel?.text = typeOfStreamQuality(streamType)
			return cell
		case .Logout:
			let cell = tableView.dequeueReusableCellWithIdentifier("LogoutCellIdentifier") as! LogoutTableViewCell
			cell.logoutLabel.text = "Log Out"
			return cell
		}
    }

	private func clearSessionAndUnwindSegue() {
		self.AuthManager?.clearSessionAndLogout()
		performSegueWithIdentifier("LogoutToServicesViewControllerSegue", sender: self)
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		switch (ExtraOptionsTableViewSection(rawValue: indexPath.section)!) {
		case .Quality:
			let optionsSheet = UIAlertController(title: "Quality", message: "Select a quality", preferredStyle: .ActionSheet)
			let lowQualityAction = UIAlertAction(title: "Low Quality", style: .Default) { _ in
				self.streamType = LOW_QUALITY_STREAM
				self.delegate?.testingSomeDelegate(LOW_QUALITY_STREAM)

				optionsSheet.dismissViewControllerAnimated(true, completion: nil)
			}

			let highQualityAction = UIAlertAction(title: "High Quality", style: .Default) { _ in
				self.streamType = HIGH_QUALITY_STREAM
				self.delegate?.testingSomeDelegate(HIGH_QUALITY_STREAM)

				optionsSheet.dismissViewControllerAnimated(true, completion: nil)
			}

			let cancelAction = UIAlertAction(title: "Cancel", style: .Destructive) { (action) in
				optionsSheet.dismissViewControllerAnimated(true, completion: nil)
			}

			optionsSheet.addAction(lowQualityAction)
			optionsSheet.addAction(highQualityAction)
			optionsSheet.addAction(cancelAction)

			dispatch_async(dispatch_get_main_queue()) {
				self.presentViewController(optionsSheet, animated: true, completion: nil)
			}
		case .Logout:
			let logoutAlertController = UIAlertController(title: "Confirmation", message: "Are you sure you want to log out?", preferredStyle: .Alert)
			let okAction = UIAlertAction(title: "OK", style: .Default) { _ in
				self.clearSessionAndUnwindSegue()

				logoutAlertController.dismissViewControllerAnimated(true, completion: nil)
			}

			let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { _ in

				logoutAlertController.dismissViewControllerAnimated(true, completion: nil)
			}

			logoutAlertController.addAction(okAction)
			logoutAlertController.addAction(cancelAction)

			dispatch_async(dispatch_get_main_queue()) {
				self.presentViewController(logoutAlertController, animated: true, completion: nil)
			}
		}
	}
}

class LogoutTableViewCell: UITableViewCell {
	@IBOutlet weak var logoutLabel: UILabel!
}