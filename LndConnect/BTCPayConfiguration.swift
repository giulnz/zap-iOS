//
//  Lightning
//
//  Created by Otto Suess on 23.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

struct BTCPayConfiguration: Decodable {
    let configurations: [BTCPayConfigurationItem]

    var grpcConfigurationItem: BTCPayConfigurationItem? {
        return configurations.first(where: { $0.type == "grpc" })
    }

    init?(data: Data) {
        guard let configuration = try? JSONDecoder().decode(BTCPayConfiguration.self, from: data) else { return nil }
        self = configuration
    }
}

struct BTCPayConfigurationItem: Decodable {
    let type: String
    let cryptoCode: String
    let host: String
    let port: Int
    let ssl: Bool
    let certificateThumbprint: String?
    let macaroon: String

    var rpcCredentials: RPCCredentials? {
        guard
            let url = URL(string: "\(host):\(port)"),
            let macaroon = Data(hexadecimalString: macaroon)
            else { return nil }
        return RPCCredentials(certificate: nil, macaroon: macaroon, host: url)
    }
}
