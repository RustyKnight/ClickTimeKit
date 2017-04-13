//
// Created by Shane Whitehead on 13/4/17.
// Copyright (c) 2017 KaiZen Enterprises. All rights reserved.
//

import Foundation
import SwiftyJSON

public protocol Session {
	var companyID: String {get}
	var userEmail: String {get}
	var userName: String {get}
	var securityLevel: String {get}
}

// This is stuff I'm not sure I should share
protocol APISession: Session {
	var token: String {get}
	var userID: String {get}
}

struct DefaultSession: APISession {
	let companyID: String
	let token: String
	let userEmail: String
	let userID: String
	let userName: String
	let securityLevel: String
}

public enum SessionError: Error {
	case missingCompanyID
	case missingSecurityLevel
	case missingToken
	case missingUserEmail
	case missingUserID
	case missingUserName
}

class SessionAPIFunction: AnyAPIFunction<APISession> {

	init() {
		super.init(url: URL(string: "https://app.clicktime.com/API/1.3/Session")!)
	}

	override func process(data: Data) throws -> APISession {
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