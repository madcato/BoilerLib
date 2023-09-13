//
//  Configuration.swift
//  iOS-Boilerplate
//
//  Created by Daniel Vela Angulo on 21/11/2018.
//  Copyright © 2018 veladan. All rights reserved.
//

import UIKit

/// This class represents the run configuration of an app
/// It serves the values stored into th `Info.plist` project file
public class Configuration {
    public enum Key: String {
        case serverURL = "serverURL"
        case apiToken = "api-token"
        case apiPrivateToken = "private-api-token"
        case basePath = "basePath"
        case environment = "environment"
    }

  /// Call this method to access any variable stored into the `Info.plist`
  /// - Parameter key: Name of the property to load. This propery name must exists.
  /// - Returns: The value of the property, or if the loading fails, it produces a `fatalError`
  public static func value(for key: Key) -> String {
        guard let result = (Bundle.main.infoDictionary?[key.rawValue] as? String)?
            .replacingOccurrences(of: "\\", with: "") else {
            fatalError("Environment variable \(key.rawValue) not found or incorrect format in \"Info.plist\"")
        }
        return result
    }

    private init() {}
}
