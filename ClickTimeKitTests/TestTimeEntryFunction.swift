//
//  TestTimeEntryFunction.swift
//  ClickTimeKit
//
//  Created by Shane Whitehead on 18/4/17.
//  Copyright © 2017 KaiZen Enterprises. All rights reserved.
//

import XCTest
@testable import ClickTimeKit
import SwiftyBeaver
import Hydra

class TestTimeEntryFunction: XCTestCase {
	
	override func setUp() {
		super.setUp()
		let credentials = Credentials(userName: "shane.whitehead@beamcommunications.com", password: "RustyKnight2001")
		ClickTime.shared.credentials = credentials
	}
	
	override func tearDown() {
		super.tearDown()
		ClickTime.shared.logout()
	}
	
	func testCanGetTimeEntries() {
		let asyncExpectation = expectation(description: "GetTimeEntries")
		ClickTime.shared.session()
			.then { (session: Session) -> Promise<[TimeEntry]> in
				return ClickTime.shared.timeEntries()
			}.then { (timeEntries: [TimeEntry]) in
				print("Processed \(timeEntries.count) work entries")
				asyncExpectation.fulfill()
			}.catch { (error) -> (Void) in
				XCTFail("\(error)")
				asyncExpectation.fulfill()
		}
		waitForExpectations(timeout: 30.0, handler: nil)
	}
	
}
