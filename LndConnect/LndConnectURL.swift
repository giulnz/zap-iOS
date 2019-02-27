//
//  Lightning
//
//  Created by Otto Suess on 12.11.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

public final class LndConnectURL {
    public let rpcCredentials: RPCCredentials

    public init?(url: URL) {
        guard
            let queryParameters = url.queryParameters,
            let nodeHostString = url.host,
            let port = url.port,
            let nodeHostUrl = URL(string: "\(nodeHostString):\(port)"),
            let macaroonString = queryParameters["macaroon"]?.base64UrlToBase64(),
            let macaroon = Data(base64Encoded: macaroonString)
            else { return nil }

        let certString: String?
        if let certificate = queryParameters["cert"]?.base64UrlToBase64() {
            certString = Pem(key: certificate).string
        } else {
            certString = nil
        }

        rpcCredentials = RPCCredentials(certificate: certString, macaroon: macaroon, host: nodeHostUrl)
    }
}
