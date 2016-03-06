//
//  SmoothStreamsAPI.swift
//  SmoothStreams
//
//  Created by Omar Basrawi on 3/1/16.
//  Copyright © 2016 Omar Basrawi. All rights reserved.
//

import Foundation
import Locksmith

class PossibleServices: NSObject, NSCoding {
	var name: String
	var host: String
	var port: Int

	init(title: String, host: String, port: Int) {
		self.name = title
		self.host = host
		self.port = port
	}

	func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(name, forKey: "name")
		aCoder.encodeObject(host, forKey: "site")
		aCoder.encodeInteger(port, forKey: "port")
	}

	required init(coder aDecoder: NSCoder) {
		name = aDecoder.decodeObjectForKey("name") as! String
		host = aDecoder.decodeObjectForKey("site") as! String
		port = aDecoder.decodeIntegerForKey("port")
	}
}

struct Services {
	var test: [PossibleServices]

	init() {
		self.test = [
			PossibleServices(title: "MyStreams & uSport", host: "viewms", port: 3655),
			PossibleServices(title: "Live 24/7", host: "view247", port: 3625),
			PossibleServices(title: "StarStreams", host: "viewss", port: 3665),
			PossibleServices(title: "MMA-TV / MyShout", host: "viewmma", port: 3645),
			PossibleServices(title: "StreamTVnow", host: "viewstvn", port: 3615)
		]
	}

	func serviceForRow(slot: Int) -> PossibleServices {
		let returnValue = self.test[slot]

		return returnValue
	}
}

enum Result: Int {
	case False = 0, True = 1

	var getType: Bool {
		switch self {
		case .False:
			return false
		case .True:
			return true
		}
	}
}

class AuthenticationManager {
	var code: Result
	var hash: String
	var valid: String
	var error: String?

	static let ManagerAccount = "ManagerAccount"

	init(JSON: [String: AnyObject]) {
		self.code = Result(rawValue: Int(JSON["code"] as! String)!)!
		self.hash = JSON["hash"] as? String ?? ""
		self.valid = String(JSON["valid"] as? Int)
		self.error = JSON["error"] as? String
	}

	init(code: Result, hash: String, valid: String) {
		self.code = code
		self.hash = hash
		self.valid = valid
	}

	func saveToKeychain() throws {
		try Locksmith.updateData([
			"code": (code.getType ? "true" : "false"),
			"hash": hash,
			"valid": valid
			], forUserAccount: AuthenticationManager.ManagerAccount)
	}

	static func loginFromKeychain(onSuccess: (AuthenticationManager) -> ()) {
		guard let dictionary = Locksmith.loadDataForUserAccount(AuthenticationManager.ManagerAccount) else {
			return
		}

		guard let code = dictionary["code"] as? Result else {
			return
		}

		guard let hash = dictionary["hash"] as? String else {
			return
		}

		guard let valid = dictionary["valid"] as? String else {
			return
		}

		let authenticationManager = AuthenticationManager(
			code: code,
			hash: hash,
			valid: valid)

		onSuccess(authenticationManager)
	}

	static func request(email: String, password: String, host: String, completionHandler: AuthenticationManager? -> ()) {
		let baseURL = NSURL(string: "http://smoothstreams.tv/schedule/admin/dash_new/hash_api.php?username=\(email)&password=\(password)&site=\(host)")!

		let session = NSURLSession.sharedSession()
		let task = session.dataTaskWithURL(baseURL) { data, response, error in

			if let http = response as? NSHTTPURLResponse {
				print("Received HTTP: \(http.statusCode)")

				do {

					let body = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [String: AnyObject]

					let manager = AuthenticationManager(JSON: body)

					// Checks if code from JSON is true(1) : false(0)
					if !manager.code.getType {
						print("Failure login")
					}

					completionHandler(manager)

					do {

						try manager.saveToKeychain()

					} catch {

						print("Failed to save keychain")
					}

				} catch {
					print(error)
				}

			}
			
		}
		
		task.resume()
	}
}