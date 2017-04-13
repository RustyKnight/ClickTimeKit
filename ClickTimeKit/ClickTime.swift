//
// Created by Shane Whitehead on 13/4/17.
// Copyright (c) 2017 KaiZen Enterprises. All rights reserved.
//

import Foundation
import Hydra
import SwiftyBeaver

public struct Credentials {
	public let userName: String
	public let password: String

	internal var encoded: String {
		return "\(userName):\(password)".toBase64()
	}
}

public enum ClickTimeError: Error {
	case invalidSession
}

public class ClickTime {
	static public let shared: ClickTime = ClickTime()

	public var credentials: Credentials?
	
	private var availableSession: APISession?
	
	public func logout() {
		availableSession = nil
	}

	internal var urlSessionConfiguration: URLSessionConfiguration {
		let config = URLSessionConfiguration.default
		guard let credentials = credentials else {
			return config
		}
		let authString = "Basic \(credentials.encoded)"
		config.httpAdditionalHeaders = ["Authorization": authString]
//		let session = URLSession(configuration: config)

		return config
	}

	internal var urlSession: URLSession {
		return URLSession(configuration: urlSessionConfiguration)
	}

	internal lazy var sessionFunction: SessionAPIFunction = {
		return SessionAPIFunction()
	}()

	public func session() -> Promise<Session> {
		return sessionFunction.execute()
				.then({ (session: APISession) -> Promise<Session> in
					self.availableSession = session
					return Promise<Session>(resolved: session)
				})
	}

	public func jobs(withChildIDs: Bool = false,
	                 name: String? = nil,
	                 displayName: String? = nil,
	                 number: String? = nil) -> Promise<[Job]> {
		guard let apiSession = availableSession else {
			return Promise<[Job]>(rejected: ClickTimeError.invalidSession)
		}
		return JobsAPIFunction(
			session: apiSession,
			withChildIDs: withChildIDs,
			name: name,
			displayName: displayName,
			number: number).execute()
	}
	public func job(withID id: String, withChildIDs: Bool = false) -> Promise<Job> {
		guard let apiSession = availableSession else {
			return Promise<Job>(rejected: ClickTimeError.invalidSession)
		}
		return JobAPIFunction(
				session: apiSession,
				withID: id,
				withChildIDs: withChildIDs).execute()
	}
}
