//
//  TestJobsFunction.swift
//  ClickTimeKit
//
//  Created by Shane Whitehead on 13/4/17.
//  Copyright © 2017 KaiZen Enterprises. All rights reserved.
//

import XCTest
@testable import ClickTimeKit
import SwiftyBeaver
import Hydra

class TestJobsFunction: XCTestCase {
    
	override func setUp() {
		super.setUp()
		let credentials = Credentials(userName: "shane.whitehead@beamcommunications.com", password: "RustyKnight2001")
		ClickTime.shared.credentials = credentials
		
//		let console = ConsoleDestination()  // log to Xcode Console
//		console.asynchronously = false
//		console.format = "[$L $DHH:mm:ss$d $T-$N:$F:$l]: $M"
//		console.levelString.debug = "🐞"
//		console.levelString.error = "☠️"
//		console.levelString.info = "💡"
//		console.levelString.verbose = "📢"
//		console.levelString.warning = "⚠️"
//		ClickTimeKit.log.addDestination(console)
	}
	
	override func tearDown() {
		super.tearDown()
		ClickTime.shared.logout()
	}
	
	func testCanGetJobs() {
		let asyncExpectation = expectation(description: "GetJobs")
		ClickTime.shared.session()
			.then { (session: Session) -> Promise<[Job]> in
				return ClickTime.shared.jobs(withChildIDs: true)
			}.then { (jobs: [Job]) in
				print("Processed \(jobs.count) jobs")
				asyncExpectation.fulfill()
			}.catch { (error) -> (Void) in
				XCTFail("\(error)")
				asyncExpectation.fulfill()
		}
		waitForExpectations(timeout: 30.0, handler: nil)
	}
	
}
