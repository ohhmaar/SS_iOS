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

	//@IBOutlets

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var continueButton: UIButton!

	var services = Services()

	let prefs = NSUserDefaults.standardUserDefaults()

	override func viewDidLoad() {
		super.viewDidLoad()

	}

//	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//		if segue.identifier == "ServicesToLoginSegue" {
//			if let destinationViewController = segue.destinationViewController as? LoginViewController {
//
////				let s = services.serviceForRow(tableView.indexPathForSelectedRow.flatMap {$0.row}!)
////				//prefs.setObject(s, forKey: "service")
//			}
//			
//		}
//	}

	private func validateService() {
		continueButton.enabled = validTableViewRow
	}

	private var validTableViewRow: Bool {
		return tableView.indexPathForSelectedRow != nil
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
		let cell = tableView.dequeueReusableCellWithIdentifier("test", forIndexPath: indexPath) as UITableViewCell

		let service = services.test[indexPath.row]
		cell.textLabel?.text = service.name
		return cell
	}
}