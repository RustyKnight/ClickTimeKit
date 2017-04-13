//
// Created by Shane Whitehead on 13/4/17.
// Copyright (c) 2017 KaiZen Enterprises. All rights reserved.
//

import Foundation

public extension String {

	public func fromBase64() -> String? {
		guard let data = Data(base64Encoded: self) else {
			return nil
		}

		return String(data: data, encoding: .utf8)
	}

	public func toBase64() -> String {
		return Data(self.utf8).base64EncodedString()
	}
}

