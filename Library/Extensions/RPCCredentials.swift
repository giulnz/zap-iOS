//
//  Library
//
//  Created by 0 on 27.02.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import LndConnect
import SwiftLnd

extension RPCCredentials {
    var remoteRPCConfiguration: RemoteRPCConfiguration? {
        let macaroon = Macaroon(data: self.macaroon)
        return RemoteRPCConfiguration(certificate: certificate, macaroon: macaroon, url: host)
    }
}
