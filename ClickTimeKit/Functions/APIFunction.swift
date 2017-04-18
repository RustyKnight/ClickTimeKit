//
// Created by Shane Whitehead on 13/4/17.
// Copyright (c) 2017 KaiZen Enterprises. All rights reserved.
//

import Hydra
import SwiftyJSON

protocol APIFunction {
	associatedtype Result
	var url: URL { get }
	func execute() -> Promise<Result>
}

protocol APIPostFunction: APIFunction {
	var content: JSON {get}
}

public enum ClickTimeAPIError: Error {
	case noDataAvailable
	case unknownResponse
	case invalid(statusCode: Int)
}

class AnyAPIFunction<ExpectedResult>: APIFunction {

	typealias Result = ExpectedResult

	let url: URL

	init(url: URL) {
		self.url = url
	}

	func execute() -> Promise<ExpectedResult> {
		return Promise<ExpectedResult> { fulfil, fail in
			let session = ClickTime.shared.urlSession
			let task = session.dataTask(with: self.url) {
				(data, response, error) in
				if let error = error {
					fail(error)
				}
				guard let data = data else {
					fail(ClickTimeAPIError.noDataAvailable)
					return
				}
				guard let response = response as? HTTPURLResponse else {
					fail(ClickTimeAPIError.unknownResponse)
					return
				}
				guard response.statusCode == HTTPStatusCode.ok.rawValue else {
					fail(ClickTimeAPIError.invalid(statusCode: response.statusCode))
					return
				}

				do {
					let result = try self.process(data: data)
					fulfil(result)
				} catch let error {
					fail(error)
				}
			}

			task.resume()
		}
	}

	func process(data: Data) throws -> ExpectedResult {
		fatalError("Not yet implemented")
	}

}

class AnyAPIPostFunction<ExpectedResult>: AnyAPIFunction<ExpectedResult>, APIPostFunction {

	private(set) var content: JSON

	init(url: URL, content: JSON) {
		self.content = content
		super(url: url)
	}

	override func execute() -> Promise<ExpectedResult> {
		return Promise<ExpectedResult> { fulfil, fail in
			let data = try self.content.rawData()
			let session = ClickTime.shared.urlSession

			var request = URLRequest(url: self.url)
			request.httpMethod = "POST"
			request.httpBody = data

			let task = session.dataTask(with: request) {
				(data, response, error) in
				if let error = error {
					fail(error)
				}
				guard let data = data else {
					fail(ClickTimeAPIError.noDataAvailable)
					return
				}
				guard let response = response as? HTTPURLResponse else {
					fail(ClickTimeAPIError.unknownResponse)
					return
				}
				guard response.statusCode == HTTPStatusCode.ok.rawValue else {
					fail(ClickTimeAPIError.invalid(statusCode: response.statusCode))
					return
				}

				do {
					let result = try self.process(data: data)
					fulfil(result)
				} catch let error {
					fail(error)
				}
			}

			task.resume()
		}
	}

}


extension AnyAPIFunction {

	func getString(from json: JSON, withKey key: String, throwing error: Error) throws -> String {
		let path: [JSONSubscriptType] = [key]
		return try getString(from: json, fromPath: path, throwing: error)
	}

	func getString(from json: JSON, fromPath path: [JSONSubscriptType], throwing error: Error) throws -> String {
		guard let value = getStringOrNil(from: json, fromPath: path) else {
			throw error
		}
		return value
	}

	func getDecimal(from json: JSON, withKey key: String, throwing error: Error) throws -> Double {
		let path: [JSONSubscriptType] = [key]
		return try getDecimal(from: json, fromPath: path, throwing: error)
	}
	
	func getDecimal(from json: JSON, fromPath path: [JSONSubscriptType], throwing error: Error) throws -> Double {
		guard let value = json[path].double else {
			throw error
		}
		return value
	}

	func getStringOrNil(from json: JSON, withKey key: String) -> String? {
		let path: [JSONSubscriptType] = [key]
		return getStringOrNil(from: json, fromPath: path)
	}

	func getStringOrNil(from json: JSON, fromPath path: [JSONSubscriptType]) -> String? {
		return json[path].string
	}
	
	func getDateOrNil(from json: JSON, withKey key: String, using format: DateFormatter) -> Date? {
		let path: [JSONSubscriptType] = [key]
		return getDateOrNil(from: json, fromPath: path, using: format)
	}
	
	func getDateOrNil(from json: JSON, fromPath path: [JSONSubscriptType], using format: DateFormatter) -> Date? {
		guard let value = json[path].string else {
			return nil
		}
		return format.date(from: value)
	}

	func getBool(from json: JSON, withKey key: String, throwing error: Error) throws -> Bool {
		let path: [JSONSubscriptType] = [key]
		return try getBool(from: json, fromPath: path, throwing: error)
	}

	func getBool(from json: JSON, fromPath path: [JSONSubscriptType], throwing error: Error) throws -> Bool {
		guard let value = getBoolOrNil(from: json, fromPath: path) else {
			throw error
		}
		return value
	}

	func getBoolOrNil(from json: JSON, withKey key: String) -> Bool? {
		let path: [JSONSubscriptType] = [key]
		return getBoolOrNil(from: json, fromPath: path)
	}

	func getBoolOrNil(from json: JSON, fromPath path: [JSONSubscriptType]) -> Bool? {
		return json[path].bool
	}
}
