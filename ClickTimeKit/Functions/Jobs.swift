//
// Created by Shane Whitehead on 13/4/17.
// Copyright (c) 2017 KaiZen Enterprises. All rights reserved.
//

import Foundation
import SwiftyJSON
import Hydra

public protocol Job {
	var accountingPackageJobID: String? { get }
	var active: Bool { get }
	var billable: Bool? { get }
	var canEdit: Bool { get }
	var clientID: String? { get }
	var displayName: String? { get }
	var jobID: String? { get }
	var name: String? { get }
	var notes: String? { get }
	var number: String? { get }
	var permittedDivisions: String? { get }
	var permittedTasks: String? { get }
	var permittedUsers: String? { get }
	var recent: Bool { get }
}

struct DefaultJob: Job {
	let accountingPackageJobID: String?
	let active: Bool
	let billable: Bool?
	let canEdit: Bool
	let clientID: String?
	let displayName: String?
	let jobID: String?
	let name: String?
	let notes: String?
	let number: String?
	let permittedDivisions: String?
	let permittedTasks: String?
	let permittedUsers: String?
	let recent: Bool
}

public enum JobError: Error {
	case missingActive
	case missingCanEdit
	case missingRecent
}

class BaseJobsAPIFunction<TypeOfJob>: AnyAPIFunction<TypeOfJob> {
	override init(url: URL) {
		super.init(url: url)
	}

	func process(json: JSON) throws -> Job {
		let accountPackageJobID = getStringOrNil(from: json, withKey: "AccountingPackageJobID")
		let isActive = try getBool(from: json, withKey: "Active", throwing: JobError.missingActive)
		let isBillable = getBoolOrNil(from: json, withKey: "Billable")
		let isEditable = try getBool(from: json, withKey: "CanEdit", throwing: JobError.missingCanEdit)
		let clientID = getStringOrNil(from: json, withKey: "ClientID")
		let displayName = getStringOrNil(from: json, withKey: "DisplayName")
		let jobID = getStringOrNil(from: json, withKey: "JobID")
		let name = getStringOrNil(from: json, withKey: "Name")
		let notes = getStringOrNil(from: json, withKey: "Notes")
		let number = getStringOrNil(from: json, withKey: "Number")
		let divisions = getStringOrNil(from: json, withKey: "PermittedDivisions")
		let tasks = getStringOrNil(from: json, withKey: "PermittedTasks")
		let users = getStringOrNil(from: json, withKey: "PermittedUsers")
		let recent = try getBool(from: json, withKey: "Recent", throwing: JobError.missingRecent)

		return DefaultJob(
				accountingPackageJobID: accountPackageJobID,
				active: isActive,
				billable: isBillable,
				canEdit: isEditable,
				clientID: clientID,
				displayName: displayName,
				jobID: jobID,
				name: name,
				notes: notes,
				number: number,
				permittedDivisions: divisions,
				permittedTasks: tasks,
				permittedUsers: users,
				recent: recent)

	}
}

class JobsAPIFunction: BaseJobsAPIFunction<[Job]> {

	init(
			session: APISession,
			withChildIDs: Bool = false,
			name: String? = nil,
			displayName: String? = nil,
			number: String? = nil
	) {
		// /API/1.3/Companies/{CompanyID}/Users/{UserID}/JobsUPDATED
		var urlComponents = URLComponents()
		urlComponents.scheme = "https"
		urlComponents.host = "app.clicktime.com"
		urlComponents.path = "/API/1.3/Companies/\(session.companyID)/Users/\(session.userID)/Jobs"

		var queryItems: [URLQueryItem] = []
		if withChildIDs {
			queryItems.append(URLQueryItem(name: "withChildIDs", value: "true"))
		}
		if let name = name {
			queryItems.append(URLQueryItem(name: "name", value: name))
		}
		if let displayName = displayName {
			queryItems.append(URLQueryItem(name: "displayName", value: displayName))
		}
		if let number = number {
			queryItems.append(URLQueryItem(name: "number", value: number))
		}
		if queryItems.count > 0 {
			urlComponents.queryItems = queryItems
		}

		super.init(url: urlComponents.url!)
	}

	override func process(data: Data) throws -> [Job] {
		let json = JSON(data: data)

		var jobs: [Job] = []
		for jobson in json.arrayValue {
			let job = try process(json: jobson)
			jobs.append(job)
		}
//		{"CompanyID":"2WKe-QVTnODU",
//		"SecurityLevel":"user",
//		"Token":"Kg+TAXV0f2GmXcL1zWVT65TOw9vw0DxeIYeGIPcd3MU=",
//		"UserEmail":"shane.whitehead@beamcommunications.com",
//		"UserID":"2ftqN9ReYaZA",
//		"UserName":"Shane Whitehead"}

//		let companyID = try getString(from: json, withKey: "CompanyID", throwing: JobError.missingCompanyID)
//		let securityLevel = try getString(from: json, withKey: "SecurityLevel", throwing: JobError.missingSecurityLevel)
//		let token = try getString(from: json, withKey: "Token", throwing: JobError.missingToken)
//		let userEmail = try getString(from: json, withKey: "UserEmail", throwing: JobError.missingUserEmail)
//		let userID = try getString(from: json, withKey: "UserID", throwing: JobError.missingUserID)
//		let userName = try getString(from: json, withKey: "UserName", throwing: JobError.missingUserName)
//
//		return DefaultJob(
//				companyID: companyID,
//				token: token,
//				userEmail: userEmail,
//				userID: userID,
//				userName: userName,
//				securityLevel: securityLevel)

		return jobs
	}
}

class JobAPIFunction: BaseJobsAPIFunction<Job> {

	init(
			session: APISession,
			withID id: String,
			withChildIDs: Bool = false) {
		// /API/1.3/Companies/{CompanyID}/Users/{UserID}/JobsUPDATED
		var urlComponents = URLComponents()
		urlComponents.scheme = "https"
		urlComponents.host = "app.clicktime.com"
		urlComponents.path = "/API/1.3/Companies/\(session.companyID)/Users/\(session.userID)/Jobs/\(id)"

		var queryItems: [URLQueryItem] = []
		if withChildIDs {
			queryItems.append(URLQueryItem(name: "withChildIDs", value: "true"))
		}
		if queryItems.count > 0 {
			urlComponents.queryItems = queryItems
		}

		super.init(url: urlComponents.url!)
	}

	override func process(data: Data) throws -> Job {
		let json = JSON(data: data)
		return try process(json: json)
	}
}
