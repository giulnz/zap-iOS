//
//  LndConnect
//
//  Created by 0 on 27.02.19.
//  Copyright © 2019 Zap. All rights reserved.
//

// REMOVE once there is the native Swift Result type

import Foundation

public enum Result<Success, Failure: Error> {
    /// A success, storing a `Success` value.
    case success(Success)

    /// A failure, storing a `Failure` value.
    case failure(Failure)

    public var value: Success? {
        switch self {
        case let .success(value):
            return value
        case .failure:
            return nil
        }
    }

    public var error: Error? {
        switch self {
        case .success:
            return nil
        case let .failure(error):
            return error
        }
    }

    public func map<NewSuccess>(_ transform: (Success) -> NewSuccess) -> Result<NewSuccess, Failure> {
        return flatMap { .success(transform($0)) }
    }

    public func flatMap<NewSuccess>(_ transform: (Success) -> Result<NewSuccess, Failure>) -> Result<NewSuccess, Failure> {
        switch self {
        case let .success(value):
            return transform(value)
        case let .failure(error):
            return .failure(error)
        }
    }
}

extension Result: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case let .success(value):
            return ".success(\(value))"
        case let .failure(error):
            return ".failure(\(error))"
        }
    }

    public var debugDescription: String {
        return description
    }
}
