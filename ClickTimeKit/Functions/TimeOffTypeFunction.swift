//
// Created by Shane Whitehead on 13/4/17.
// Copyright (c) 2017 KaiZen Enterprises. All rights reserved.
//

import Foundation
import SwiftyJSON
import Hydra

public protocol TimeOffType {
	var isActive: Bool {get}
	var name: String? {get}
	var timeOffTypeID: String? {get}
}

struct DefaultTimeOffType: TimeOffType {
	let isActive: Bool
	let name: String?
	let timeOffTypeID: String?
}

public enum TimeOffTypeError: Error {
	case missingActive
}

class TimeOffTypeAPIFunction: AnyAPIFunction<[TimeOffType]> {

	init(session: APISession) {
		var urlComponents = URLComponents()
		urlComponents.scheme = "https"
		urlComponents.host = "app.clicktime.com"
		urlComponents.path = "/API/1.3/Companies/\(session.companyID)/Users/\(session.userID)/TimeOffTypes"
		super.init(url: urlComponents.url!)
	}

	func process(json: JSON) throws -> TimeOffType {

		let isActive = try getBool(from: json, withKey: "Active", throwing: TaskError.missingActive)
		let name = getStringOrNil(from: json, withKey: "Name")
		let taskID = getStringOrNil(from: json, withKey: "TimeOffTypeID")

		return DefaultTimeOffType(
				isActive: isActive,
				name: name,
				timeOffTypeID: taskID)

	}

	override func process(data: Data) throws -> [TimeOffType] {
		let json = JSON(data: data)

		var types: [TimeOffType] = []
		for typeon in json.arrayValue {
			let type = try process(json: typeon)
			types.append(type)
		}
		return types
	}
}
