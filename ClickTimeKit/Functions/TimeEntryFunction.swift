//
// Created by Shane Whitehead on 13/4/17.
// Copyright (c) 2017 KaiZen Enterprises. All rights reserved.
//

import Foundation
import SwiftyJSON
import Hydra

public protocol BaseEntry {
	var comment: String? { get }
	var date: Date? { get }
	var duration: TimeInterval { get }
}

public protocol WorkEntry: BaseEntry {
	var breakTime: TimeInterval { get }
	var isoEndTime: String? { get }
	var isoStartTime: String? { get }
	var jobID: String? { get }
	var phaseID: String? { get }
	var subPhaseID: String? { get }
	var timeEntryID: String? { get }
	var taskID: String? { get }
	var optionalData: [String: String]? { get }
	var timer: Timer? { get }
	var timerEntryID: String? {get}
}

public protocol TimerInterval {
	var gmtOffset: Double { get }
	var isoEndDateTimeUTC: Date { get }
	var ISOStartDateTimeUTC: Date { get }
}

public protocol Timer {
	var initialTime: TimeInterval { get }
	var intervals: [TimerInterval] { get }
}

public protocol TimeOffEntry: BaseEntry {
	var timeOffEntryID: String? { get }
	var TimeOffTypeID: String? { get }
}

public protocol TimeEntry {
	var date: Date? { get }
	var locked: Bool { get }
	var workEntries: [WorkEntry] { get }
	var timeOffEntries: [TimeOffEntry] { get }
	var timers: [WorkEntry] { get }
}

struct DefaultTimeEntry: TimeEntry {
	let date: Date?
	let locked: Bool
	let workEntries: [WorkEntry]
	let timeOffEntries: [TimeOffEntry]
	let timers: [WorkEntry] = []
}

struct DefaultWorkEntry: WorkEntry {
	let breakTime: TimeInterval
	let isoEndTime: String?
	let isoStartTime: String?
	let jobID: String?
	let phaseID: String?
	let subPhaseID: String?
	let timeEntryID: String?
	let taskID: String?
	let optionalData: [String: String]?
	let timer: Timer?
	let comment: String?
	let date: Date?
	let duration: TimeInterval
	let timerEntryID: String?
}

struct DefaultTimer: Timer {
	let initialTime: TimeInterval
	let intervals: [TimerInterval]
}

struct DefaultTimeOffEntry: TimeOffEntry {
	let timeOffEntryID: String?
	let TimeOffTypeID: String?
	let comment: String?
	let date: Date?
	let duration: TimeInterval
}

public enum TimeEntriesError: Error {
	case missingLocked
	case missingBreakTime
	case missingHours
	case missingInitialTimerTime
	case missingGmtOffset
}

class TimeEntryAPIFunction: AnyAPIFunction<[TimeEntry]> {

	lazy var dateFormat: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyyMMdd"
		return formatter
	}()
	lazy var timeFormat: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "HH:mm:ss"
		return formatter
	}()

	init(session: APISession) {
		var urlComponents = URLComponents()
		urlComponents.scheme = "https"
		urlComponents.host = "app.clicktime.com"
		urlComponents.path = "/API/1.3/Companies/\(session.companyID)/Users/\(session.userID)/TimeEntries"
		super.init(url: urlComponents.url!)
	}
	
	func processTimers(from json: JSON) throws -> [Timer] {
		var timers: [Timer] = []
		for timeron in json.arrayValue {
			guard let timer = try processTimer(from: timeron) else {
				continue
			}
			timers.append(timer)
		}
		return timers
	}

	func processTimer(from json: JSON) throws -> Timer? {
		guard !json.isEmpty else {
			return nil
		}
		let initialTime = try getDecimal(from: json, withKey: "InitialTimeInSeconds", throwing: TimeEntriesError.missingInitialTimerTime) / 1000.0
//		for intervalon in json["Intervals"].arrayValue {
//			let offset = try getDecimal(from: json, withKey: "GMTOffset", throwing: TimeEntriesError.missingGmtOffset)
//		}
		return DefaultTimer(initialTime: initialTime, intervals: [])
	}

	func processWorkEntries(from json: JSON) throws -> [WorkEntry] {
		
		var entries: [WorkEntry] = []
		for entryon in json.arrayValue {

			let breakTime = try getDecimal(from: entryon, withKey: "BreakTime", throwing: TimeEntriesError.missingBreakTime)
			let comment = getStringOrNil(from: entryon, withKey: "Comment")
			let date = getDateOrNil(from: entryon, withKey: "Date", using: dateFormat)
			let hours = try getDecimal(from: entryon, withKey: "Hours", throwing: TimeEntriesError.missingHours)
			let startTime = getStringOrNil(from: entryon, withKey: "ISOStartTime")
			let endTime = getStringOrNil(from: entryon, withKey: "ISOEndTime")
			let jobID = getStringOrNil(from: entryon, withKey: "JobID")
			let phaseID = getStringOrNil(from: entryon, withKey: "PhaseID")
			let subPhaseID = getStringOrNil(from: entryon, withKey: "SubPhaseID")
			let taskID = getStringOrNil(from: entryon, withKey: "TaskID")
			let timeEntryID = getStringOrNil(from: entryon, withKey: "TimeEntryID")
			let timer = try processTimer(from: entryon["Timer"])
			let timerEntryID = getStringOrNil(from: entryon, withKey: "TimeEntryID")

			let entry = DefaultWorkEntry(
					breakTime: breakTime,
					isoEndTime: endTime,
					isoStartTime: startTime,
					jobID: jobID,
					phaseID: phaseID,
					subPhaseID: subPhaseID,
					timeEntryID: timeEntryID,
					taskID: taskID,
					optionalData: nil,
					timer: timer,
					comment: comment,
					date: date,
					duration: hours * 60.0,
					timerEntryID: timerEntryID)

			entries.append(entry)
		}

		return entries
	}

	func processTimeOffEntries(from json: JSON) throws -> [TimeOffEntry] {

		var entries: [TimeOffEntry] = []
		for entryon in json.arrayValue {

			let comment = getStringOrNil(from: entryon, withKey: "Comment")
			let date = getDateOrNil(from: entryon, withKey: "Date", using: dateFormat)
			let hours = try getDecimal(from: entryon, withKey: "Hours", throwing: TimeEntriesError.missingHours)
			let timeOffEntryID = getStringOrNil(from: entryon, withKey: "TimeOffEntryID")
			let timeOffTypeID = getStringOrNil(from: entryon, withKey: "TimeOffTypeID")

			let entry = DefaultTimeOffEntry(
				timeOffEntryID: timeOffEntryID,
				TimeOffTypeID: timeOffTypeID,
				comment: comment,
				date: date,
				duration: hours * 60.0)

			entries.append(entry)
		}

		return entries
	}

	override func process(data: Data) throws -> [TimeEntry] {
		let json = JSON(data: data)

		var entries: [TimeEntry] = []
		for entryon in json.arrayValue {
			
			let date = getDateOrNil(from: entryon, withKey: "Date", using: dateFormat)
			let locked = try getBool(from: entryon, withKey: "Locked", throwing: TimeEntriesError.missingLocked)
			
			let workEntries: [WorkEntry] = try processWorkEntries(from: entryon["TimeEntries"])
			//		let timers: [WorkEntry] = try processWorkEntries(from: json["Timers"])
			let timeOffEntries: [TimeOffEntry] = try processTimeOffEntries(from: entryon["TimeOffEntries"])
			
			entries.append(DefaultTimeEntry(
				date: date,
				locked: locked,
				workEntries: workEntries,
				timeOffEntries: timeOffEntries))
		}
		
		return entries
	}
}
