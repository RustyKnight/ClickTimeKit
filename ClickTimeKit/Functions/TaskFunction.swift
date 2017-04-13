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
	var recent: Bool {get}
	var taskID: String? {get}
}

struct DefaultTask: Task {
	let isActive: Bool
	let code: String?
	let displayName: String?
	let name: String?
	let recent: Bool
	let taskID: String?
}

public enum TaskError: Error {
	case missingCompanyID
	case missingSecurityLevel
	case missingToken
	case missingUserEmail
	case missingUserID
	case missingUserName
}

class TaskAPIFunction: AnyAPIFunction<Task> {

	init(session: APISession) {
		var urlComponents = URLComponents()
		urlComponents.scheme = "https"
		urlComponents.host = "app.clicktime.com"
		urlComponents.path = "/API/1.3/Companies/\(session.companyID)/Users/\(session.userID)/Tasks"
		super.init(url: urlComponents.url!)
	}

	override func process(data: Data) throws -> Task {
		let json = JSON(data: data)
//		{"CompanyID":"2WKe-QVTnODU",
//		"SecurityLevel":"user",
//		"Token":"Kg+TAXV0f2GmXcL1zWVT65TOw9vw0DxeIYeGIPcd3MU=",
//		"UserEmail":"shane.whitehead@beamcommunications.com",
//		"UserID":"2ftqN9ReYaZA",
//		"UserName":"Shane Whitehead"}

		let companyID = try getString(from: json, withKey: "CompanyID", throwing: SessionError.missingCompanyID)
		let securityLevel = try getString(from: json, withKey: "SecurityLevel", throwing: SessionError.missingSecurityLevel)
		let token = try getString(from: json, withKey: "Token", throwing: SessionError.missingToken)
		let userEmail = try getString(from: json, withKey: "UserEmail", throwing: SessionError.missingUserEmail)
		let userID = try getString(from: json, withKey: "UserID", throwing: SessionError.missingUserID)
		let userName = try getString(from: json, withKey: "UserName", throwing: SessionError.missingUserName)

		return DefaultSession(
				companyID: companyID,
				token: token,
				userEmail: userEmail,
				userID: userID,
				userName: userName,
				securityLevel: securityLevel)
	}
}