//
//  ServicesViewController.swift
//  SmoothStreams
//
//  Created by Omar Basrawi on 2/24/16.
//  Copyright © 2016 Omar Basrawi. All rights reserved.
//

import UIKit
import Locksmith

class ServicesViewController: UIViewController {

	let ServicesCellIdentifier = "ServicesCellIdentifier"

	//@IBOutlets

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var continueButton: UIButton! {
		didSet {
			 self.continueButton.layer.cornerRadius = CGFloat(5)
		}
	}

	var services = Services()

	let prefs = NSUserDefaults.standardUserDefaults()

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		guard let path = self.tableView.indexPathForSelectedRow else { return }

		// Clear selection disable continue button
		tableView.deselectRowAtIndexPath(path, animated: true)
		validateService()
	}

	private func validateService() {
		continueButton.enabled = validTableViewRow
	}

	private var validTableViewRow: Bool {
		return tableView.indexPathForSelectedRow != nil
	}

	@IBAction func unwindSegueFromLogout(segue: UIStoryboardSegue) {
		
	}

}

extension ServicesViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "Select your site"
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		prefs.setInteger(tableView.indexPathForSelectedRow!.row, forKey:"site")
		validateService()
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return services.test.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(ServicesCellIdentifier, forIndexPath: indexPath) as UITableViewCell

		let service = services.test[indexPath.row]
		cell.textLabel?.text = service.name

		return cell
	}
}