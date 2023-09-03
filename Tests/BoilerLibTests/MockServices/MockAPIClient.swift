//
//  MockAPIClient.swift
//  iOS-BoilerplateTests
//
//  Created by Daniel Vela Angulo on 05/12/2018.
//  Copyright © 2018 veladan. All rights reserved.
//

@testable import BoilerLib
import XCTest

class MockAPIClient: Http.Client {
    struct ResponseDto: Codable {
        var name: String
    }
    var objectToReturn: Http.Result<ResponseDto>?

    init() {
        super.init(baseURL: "http://www.server.com", basePath: "/path")
    }

    override func request<Response, Body>(_ endpoint: Http.Endpoint<Response, Body>, completion: @escaping (Http.Result<Response>) -> Void) {
        guard let object = objectToReturn as? Http.Result<Response> else {
            fatalError("Need to set 'objectToReturn' value before calling this method")
        }
        _ = completion(object)
    }
}
