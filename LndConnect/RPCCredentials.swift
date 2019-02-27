//
//  LndConnect
//
//  Created by 0 on 26.02.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

public struct RPCCredentials {
    public let certificate: String?
    public let macaroon: Data
    public let host: URL
}
