//
//  ScheduleViewController.swift
//  SmoothStreams
//
//  Created by Omar Basrawi on 2/26/16.
//  Copyright © 2016 Omar Basrawi. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Locksmith

class ScheduleViewController: UITableViewController {
	let ChannelCellIdentifier = "ChannelCellIdentifier"
	let ScheduleToOptionsSegue = "OptionsSegue"
	let ScheduleToPlayerSegue = "PlayRequestedChannelSegue"


	var tempModel = [Int]()
	let mode = Services()
	var qualityType = LOW_QUALITY_STREAM

	override func viewDidLoad() {
		super.viewDidLoad()
		// Temporary fix until I parse the schedule JSON
		for i in 1...50 {
			tempModel.append(i)
		}
	}

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == ScheduleToOptionsSegue {

			let navigationViewController = segue.destinationViewController as! UINavigationController
			let extraOptionsViewController = navigationViewController.topViewController as! ExtraOptionsTableViewController

			extraOptionsViewController.streamType = qualityType
			extraOptionsViewController.delegate = self

		} else if segue.identifier == ScheduleToPlayerSegue {
			let playerViewController = segue.destinationViewController as! AVPlayerViewController

			guard let path = tableView.indexPathForSelectedRow?.row else { return }

			let channel = adjustChannelID(tempModel[path])

			getVideoURL(channel, success: { URL in

				//print(URL)
				playerViewController.player = AVPlayer(URL: URL)

				do {
					try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)

				} catch { print("Could not play") }

				playerViewController.modalPresentationStyle = UIModalPresentationStyle.FullScreen
				playerViewController.player?.play()
			})
		}
	}

	// MARK: Helpers

	private func getVideoURL(channel: String, success: (NSURL) -> ()) {
		let prefs = NSUserDefaults.standardUserDefaults()
		let s = prefs.valueForKey("site") as! Int
		let a = mode.serviceDetailsForRow(s)
		// FIXME: Introduce a option to select different hosts
		let host = "deu.nl2.smoothstreams.tv"

		getToken { token in
			success(NSURL(string: "http://\(host):\(a.port)/\(a.host)/ch\(channel)\(self.qualityType).stream/playlist.m3u8?wmsAuthSign=\(token)")!)
		}
	}

	private func adjustChannelID(channel: Int) -> String {
		return String(channel).characters.count == 1 ? "0\(channel)" : String(channel)
	}

	private func getToken(token: (String) -> ()) {
		if let dict = Locksmith.loadDataForUserAccount(AuthenticationManager.ManagerAccount) {
			token(dict["hash"]! as! String)
		}
	}
}

// TableView Methods

extension ScheduleViewController: ExtraOptionsDelegate {
	func testingSomeDelegate(data: String) {
		//Grab value from ExtraOptionsTableViewController via Delegate
		self.qualityType = data
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// This is temporary until I parse the schedule JSON
		return 50
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(ChannelCellIdentifier, forIndexPath: indexPath)

		let model = tempModel[indexPath.row]
		cell.textLabel?.text = String(model)

		return cell
	}
}