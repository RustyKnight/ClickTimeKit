//
// Created by Shane Whitehead on 13/4/17.
// Copyright (c) 2017 KaiZen Enterprises. All rights reserved.
//

import Foundation
import SwiftyJSON
import Hydra

public protocol Task {
	var isActive: Bool {get}
	var code: String? {get}
	var displayName: String? {get}
	var name: String? {get}
	var isRecent: Bool {get}
	var taskID: String? {get}
}

struct DefaultTask: Task {
	let isActive: Bool
	let code: String?
	let displayName: String?
	let name: String?
	let isRecent: Bool
	let taskID: String?
}

public enum TaskError: Error {
	case missingActive
	case missingRecent
}

class TaskAPIFunction: AnyAPIFunction<[Task]> {

	init(session: APISession) {
		var urlComponents = URLComponents()
		urlComponents.scheme = "https"
		urlComponents.host = "app.clicktime.com"
		urlComponents.path = "/API/1.3/Companies/\(session.companyID)/Users/\(session.userID)/Tasks"
		super.init(url: urlComponents.url!)
	}

	func process(json: JSON) throws -> Task {

		let isActive = try getBool(from: json, withKey: "Active", throwing: TaskError.missingActive)
		let code = getStringOrNil(from: json, withKey: "Code")
		let displayName = getStringOrNil(from: json, withKey: "DisplayName")
		let name = getStringOrNil(from: json, withKey: "Name")
		let isRecent = try getBool(from: json, withKey: "Recent", throwing: TaskError.missingRecent)
		let taskID = getStringOrNil(from: json, withKey: "TaskID")

		return DefaultTask(
				isActive: isActive,
				code: code,
				displayName: displayName,
				name: name,
				isRecent: isRecent,
				taskID: taskID)

	}

	override func process(data: Data) throws -> [Task] {
		let json = JSON(data: data)

		var tasks: [Task] = []
		for taskon in json.arrayValue {
			let task = try process(json: taskon)
			tasks.append(task)
		}
		return tasks
	}
}
