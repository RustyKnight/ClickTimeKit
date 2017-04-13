//
//  TestSessionFunciton.swift
//  ClickTimeKit
//
//  Created by Shane Whitehead on 13/4/17.
//  Copyright © 2017 KaiZen Enterprises. All rights reserved.
//

import XCTest
@testable import ClickTimeKit

class TestSessionFunciton: XCTestCase {
	
	override func setUp() {
		super.setUp()
		let credentials = Credentials(userName: "shane.whitehead@beamcommunications.com", password: "RustyKnight2001")
		ClickTime.shared.credentials = credentials
	}
	
	func testCanGetSession() {
		let asyncExpectation = expectation(description: "GetSession")
		ClickTime.shared.session()
			.then { (session: Session) in
				asyncExpectation.fulfill()
			}.catch { (error) -> (Void) in
				XCTFail("\(error)")
				asyncExpectation.fulfill()
		}
		waitForExpectations(timeout: 30.0, handler: nil)
	}
	
}
