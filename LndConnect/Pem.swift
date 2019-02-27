//
//  Lightning
//
//  Created by Otto Suess on 16.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

class Pem {
    private let prefix = "-----BEGIN CERTIFICATE-----"
    private let suffix = "-----END CERTIFICATE-----"
    let string: String

    init(key: String) {
        if key.hasPrefix(prefix) {
            string = key
        } else {
            string = "\(prefix)\n\(key.separate(every: 64, with: "\n"))\n\(suffix)\n"
        }
    }
}
