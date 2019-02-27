//
//  LndConnect
//
//  Created by 0 on 27.02.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

extension URL {
    var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems
            else { return nil }

        var parameters = [String: String]()
        for item in queryItems {
            parameters[item.name] = item.value
        }
        return parameters
    }
}

extension String {
    func base64UrlToBase64() -> String {
        var base64 = self
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        if base64.count % 4 != 0 {
            base64.append(String(repeating: "=", count: 4 - base64.count % 4))
        }

        return base64
    }

    func separate(every: Int, with separator: String) -> String {
        let result = stride(from: 0, to: count, by: every)
            .map { Array(Array(self)[$0..<min($0 + every, count)]) }
            .joined(separator: separator)
        return String(result)
    }
}

extension Data {
    init?(hexadecimalString: String) {
        guard let regex = try? NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive) else { return nil }

        var data = Data(capacity: hexadecimalString.count / 2)
        regex.enumerateMatches(in: hexadecimalString, range: NSRange(location: 0, length: hexadecimalString.utf16.count)) { match, _, _ in
            guard let match = match else { return }
            let byteString = (hexadecimalString as NSString).substring(with: match.range)
            if var num = UInt8(byteString, radix: 16) {
                data.append(&num, count: 1)
            }
        }

        if data.isEmpty {
            return nil
        }

        self = data
    }
}
