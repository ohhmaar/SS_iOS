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
	var tempModel = [Int]()
	let mode = Services()

	override func viewDidLoad() {
		super.viewDidLoad()

		self.navigationController?.title = "Schedule"

		// Temporary fix until I parse the schedule JSON
		for i in 1...50 {
			tempModel.append(i)
		}
	}

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
		if segue.identifier == "PlayRequestedChannelSegue" {
			let playerViewController = segue.destinationViewController as! AVPlayerViewController
			let path = tableView.indexPathForSelectedRow
			let channel = adjustChannelID(tempModel[(path?.row)!])

			getVideoURL(channel, success: { URL in

				print(URL)
				playerViewController.player = AVPlayer(URL: URL)
				do {
				try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
				} catch {
					print("failure")
				}
				playerViewController.player?.play()

			})
		}
	}

	// MARK: Helpers

	func getVideoURL(channel: String, success: (NSURL) -> ()) {
		let prefs = NSUserDefaults.standardUserDefaults()
		let s = prefs.valueForKey("site") as! Int
		let a = mode.serviceForRow(s)
		// FIXME: Introduce a option to select different hosts
		let host = "deu.nl2.smoothstreams.tv"

		getToken { token in
			success(NSURL(string: "http://\(host):\(a.port)/\(a.host)/ch\(channel).smil/playlist.m3u8?wmsAuthSign=\(token)")!)
		}
	}

	func adjustChannelID(channel: Int) -> String {
		if String(channel).characters.count == 1 {
			return "0\(channel)"
		}

		return String(channel)
	}

	func getToken(token: (String) -> ()) {
		if let dict = Locksmith.loadDataForUserAccount("ManagerAccount") {
			token(dict["hash"]! as! String)
		}
	}
}

// TableView Methods

extension ScheduleViewController {
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